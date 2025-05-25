import org.forgerock.http.protocol.*
import groovy.json.*
import java.net.URLEncoder
import java.net.URLDecoder
import java.nio.file.Files
import java.nio.file.Paths
import org.forgerock.util.promise.Promises
import java.sql.DriverManager

// Debugging aktivieren
def debugging = true
def debugLog = { msg -> if (debugging) logger.info("[DEBUG] $msg") }

logger.info("[fetchProductsAzure] 🟢 Starte Azure Produktweiterleitung mit Paging, Cache und PostgreSQL")

def baseUrl = 'https://prices.azure.com/api/retail/prices'
def TTL_MILLIS = 300_000

def dbHost = System.getenv("POSTGRES_HOST")
def dbPort = System.getenv("POSTGRES_PORT")
def dbName = System.getenv("API_PRODUCT_PRICES_AZURE_DB")
def dbUser = System.getenv("API_PRODUCT_PRICES_AZURE_USER")
def dbPass = System.getenv("API_PRODUCT_PRICES_AZURE_PASSWORD")
def dbUrl = "jdbc:postgresql://${dbHost}:${dbPort}/${dbName}"

debugLog("DB-Verbindung: ${dbUrl}, Benutzer: ${dbUser}")

// Query-Parameter verarbeiten
def queryString = request.uri.query
debugLog("Eingehender Query-String: ${queryString}")

def queryMap = [:]
if (queryString) {
    queryString.split('&').each { param ->
        def parts = param.split('=', 2)
        if (parts.size() == 2) {
            queryMap[parts[0]] = URLDecoder.decode(parts[1], "UTF-8")
        }
    }
    debugLog("Parste Query-Parameter: ${queryMap}")
}

def skip = 0
try {
    if (queryMap['_pagedResultsCookie']) {
        def decoded = new String(queryMap['_pagedResultsCookie'].decodeBase64())
        debugLog("Decoded pagedResultsCookie: ${decoded}")
        def matcher = decoded.replace("\$", "__DOLLAR__") =~ /[?&]__DOLLAR__skip=(\d+)/
        if (matcher.find()) skip = matcher.group(1).toInteger()
        else if (decoded.isInteger()) skip = decoded.toInteger()
    } else if (queryMap['_pagedResultsOffset']) {
        skip = queryMap['_pagedResultsOffset'].toInteger() * 20
    }
} catch (Exception e) {
    logger.warn("[fetchProductsAzure] ⚠️ Fehler bei Skip-Verarbeitung: ${e.message}")
}
debugLog("Skip = ${skip}")

def top = 1000
try {
    if (queryMap['_pageSize']) top = queryMap['_pageSize'].toInteger()
} catch (Exception e) {
    logger.warn("[fetchProductsAzure] ⚠️ Fehler beim Parsen von pageSize: ${e.message}")
}
debugLog("PageSize = ${top}")

// Cache-Dateien vorbereiten
def cacheDir = new File("/tmp/azure-cache")
cacheDir.mkdirs()
def cacheFile = new File(cacheDir, "offset-${skip}.json")
def timestampFile = new File(cacheDir, "timestamp.txt")
def now = System.currentTimeMillis()

def cacheValid = false
try {
    if (timestampFile.exists()) {
        def lastTs = timestampFile.text.toLong()
        cacheValid = (now - lastTs < TTL_MILLIS)
        debugLog("Letzter Cache-Zeitstempel: ${lastTs}, gültig: ${cacheValid}")
        if (!cacheValid) {
            cacheDir.listFiles().each { it.delete() }
            timestampFile.delete()
        }
    }
} catch (Exception e) {
    logger.warn("[fetchProductsAzure] ⚠️ Fehler beim Cache-Zugriff: ${e.message}")
}

if (cacheValid && cacheFile.exists()) {
    try {
        def cached = new JsonSlurper().parse(cacheFile)
        debugLog("Cache-Hit für skip=${skip}, Rückgabe von Cache-Daten")
        def response = new Response(Status.OK)
        response.headers.put("Content-Type", "application/json")
        response.entity.json = cached
        return Promises.newResultPromise(response)
    } catch (Exception e) {
        logger.warn("[fetchProductsAzure] ⚠️ Fehler beim Lesen der Cache-Datei: ${e.message}")
    }
}

// Azure-Request aufbauen
def azureQuery = ["\$skip=${skip}", "\$top=${top}"]
if (queryMap['_queryFilter']) {
    azureQuery.add("\$filter=" + URLEncoder.encode(queryMap['_queryFilter'], "UTF-8"))
}
def requestUrl = baseUrl + "?" + azureQuery.join("&")

logger.info("[fetchProductsAzure] 🌐 Anfrage an Azure: ${requestUrl}")

def azureRequest = new Request()
azureRequest.uri = requestUrl
azureRequest.method = 'GET'
azureRequest.headers['Accept'] = 'application/json'

return next.handle(context, azureRequest).thenAsync { azureResponse ->
    def responseCode = azureResponse.status.code
    debugLog("HTTP-Status Azure: ${responseCode}")

    def remaining = azureResponse.headers.getFirst('x-ms-ratelimit-remaining-retailprices-requests')?.toInteger()
    def retryAfterHeader = azureResponse.headers.getFirst('x-ms-ratelimit-retailprices-retry-after')
    def retryAfter = retryAfterHeader?.isInteger() ? retryAfterHeader.toInteger() * 1000 : 1000
    debugLog("Rate-Limit Header: Remaining=${remaining}, Retry-After=${retryAfter}")

    if (responseCode == 429 || (remaining != null && remaining <= 1)) {
        logger.warn("[fetchProductsAzure] ⛔ Rate Limit erreicht, warte ${retryAfter}ms")
        Thread.sleep(retryAfter)
        return next.handle(context, azureRequest).thenAsync(this)
    }

    def json = new JsonSlurper().parseText(azureResponse.entity.string)
    def result = json?.Items ?: json?.items ?: []
    debugLog("Anzahl empfangener Produkte: ${result.size()}")

    // PostgreSQL-Zugriff
    try {
        def conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)
        def stmt = conn.prepareStatement('''
            INSERT INTO "product_prices" (
                "uidVal", "productId", "productName", "skuName", "skuId", "armSkuName", "serviceName", "serviceFamily",
                "serviceId", "armRegionName", "location", "tierMinimumUnits", "currencyCode", "meterId", "meterName",
                "availabilityId", "type", "unitOfMeasure", "reservationTerm", "priceType", "retailPrice", "unitPrice",
                "savingsPlan", "isPrimaryMeterRegion", "effectiveStartDate", "lastModified"
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?::jsonb, ?, ?, ?)
            ON CONFLICT ("uidVal") DO UPDATE
            SET "retailPrice" = EXCLUDED."retailPrice",
                "lastModified" = EXCLUDED."lastModified"
        ''')

        result.eachWithIndex { item, i ->
            // uidVal berechnen
            def tierClean = item?.tierMinimumUnits?.toString()
            if (tierClean?.endsWith('.0')) {
                tierClean = tierClean[0..-3] // ".0" abschneiden
            }
            def uidVal = "${item?.meterId ?: ''}_${item?.skuId ?: ''}_${item?.serviceId ?: ''}_${item?.type ?: ''}_${tierClean ?: ''}"

            // Parameter setzen
            stmt.setString(1, uidVal)
            stmt.setString(2, item?.productId)
            stmt.setString(3, item?.productName)
            stmt.setString(4, item?.skuName)
            stmt.setString(5, item?.skuId)
            stmt.setString(6, item?.armSkuName)
            stmt.setString(7, item?.serviceName)
            stmt.setString(8, item?.serviceFamily)
            stmt.setString(9, item?.serviceId)
            stmt.setString(10, item?.armRegionName)
            stmt.setString(11, item?.location)
            stmt.setObject(12, item?.tierMinimumUnits)
            stmt.setString(13, item?.currencyCode)
            stmt.setString(14, item?.meterId)
            stmt.setString(15, item?.meterName)
            stmt.setString(16, item?.availabilityId)
            stmt.setString(17, item?.type)
            stmt.setString(18, item?.unitOfMeasure)
            stmt.setString(19, item?.reservationTerm)
            stmt.setString(20, item?.priceType)
            stmt.setObject(21, item?.retailPrice)
            stmt.setObject(22, item?.unitPrice)
            stmt.setString(23, JsonOutput.toJson(item?.savingsPlan))
            stmt.setObject(24, item?.isPrimaryMeterRegion)
            stmt.setString(25, item?.effectiveStartDate)
            stmt.setString(26, item?.lastModified)

            stmt.executeUpdate()
            if (debugging && i < 3) debugLog("Beispiel-Datensatz ${i + 1} verarbeitet: uidVal=${uidVal}")
        }
        conn.close()
        debugLog("PostgreSQL-Verbindung geschlossen.")
    } catch (Exception e) {
        logger.error("[fetchProductsAzure] Fehler beim Schreiben in PostgreSQL: ${e.message}")
    }

    def nextLink = json?.NextPageLink
    def nextAzureSkip = null
    if (nextLink) {
        def matcher = nextLink.replace("\$", "__DOLLAR__") =~ /[?&]__DOLLAR__skip=(\d+)/
        if (matcher.find()) nextAzureSkip = matcher.group(1).toInteger()
    }

    def nextOffset = nextAzureSkip ? (nextAzureSkip.intdiv(20)) : null
    debugLog("NextPageLink: ${nextLink}, nextOffset: ${nextOffset}")

    def wrapper = [
        result               : result,
        pagedResultsCookie   : nextLink ? nextLink.toString().bytes.encodeBase64().toString() : null,
        remainingPagedResults: result.size()
    ]
    if (nextOffset != null) wrapper['_pagedResultsOffset'] = nextOffset

    def response = new Response(Status.OK)
    response.headers.put("Content-Type", "application/json")
    response.entity.json = wrapper

    try {
        cacheFile.text = JsonOutput.toJson(wrapper)
        timestampFile.text = now.toString()
        debugLog("Daten im Cache gespeichert.")
    } catch (Exception e) {
        logger.warn("[fetchProductsAzure] Fehler beim Schreiben in Cache: ${e.message}")
    }

    return Promises.newResultPromise(response)
}