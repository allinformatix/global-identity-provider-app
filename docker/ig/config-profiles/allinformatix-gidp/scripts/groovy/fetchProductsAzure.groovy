import org.forgerock.http.protocol.*
import groovy.json.*
import java.net.URLEncoder
import java.net.URLDecoder
import java.nio.file.Files
import java.nio.file.Paths
import org.forgerock.util.promise.Promises

logger.info("[fetchProductsAzure] 🟢 Starte Azure Produktweiterleitung mit Paging- & File-Cache")

def baseUrl = 'https://prices.azure.com/api/retail/prices'
def TTL_MILLIS = 300_000 // 5 Minuten

// === Query verarbeiten ===
def queryString = request.uri.query
def queryMap = [:]
if (queryString) {
    queryString.split('&').each { param ->
        def parts = param.split('=', 2)
        if (parts.size() == 2) {
            queryMap[parts[0]] = URLDecoder.decode(parts[1], "UTF-8")
        }
    }
}

// === Paging: Cookie oder Offset ===
def skip = 0
if (queryMap['_pagedResultsCookie']) {
    try {
        def decoded = new String(queryMap['_pagedResultsCookie'].decodeBase64())
        logger.info("[fetchProductsAzure] 🧭 Reconcile → decoded Link = ${decoded}")
        def matcher = decoded.replace("\$", "__DOLLAR__") =~ /[?&]__DOLLAR__skip=(\d+)/
        if (matcher.find()) {
            skip = matcher.group(1).toInteger()
            logger.info("[fetchProductsAzure] ✅ Gefundener NextPage skip = ${skip}")
        } else if (decoded.isInteger()) {
            skip = decoded.toInteger()
            logger.info("[fetchProductsAzure] 🧭 Reconcile → decoded integer skip = ${skip}")
        }
    } catch (Exception e) {
        logger.warn("[fetchProductsAzure] ⚠️ Fehler beim Dekodieren von pagedResultsCookie: ${e.message}")
    }
} else if (queryMap['_pagedResultsOffset']) {
    try {
        skip = queryMap['_pagedResultsOffset'].toInteger() * 20
        logger.info("[fetchProductsAzure] 🧭 UI Offset → skip = ${skip}")
    } catch (Exception e) {
        logger.warn("[fetchProductsAzure] ⚠️ Fehler beim Verarbeiten von pagedResultsOffset")
    }
}

def top = 1000
if (queryMap['_pageSize']) {
    try {
        top = queryMap['_pageSize'].toInteger()
        logger.info("[fetchProductsAzure] 📐 Verwende pageSize = ${top}")
    } catch (Exception e) {
        logger.warn("[fetchProductsAzure] ⚠️ Fehler beim Parsen von pageSize")
    }
}

// === Cache-Dateien vorbereiten ===
def cacheDir = new File("/tmp/azure-cache")
cacheDir.mkdirs()
def cacheFile = new File(cacheDir, "offset-${skip}.json")
def timestampFile = new File(cacheDir, "timestamp.txt")
def now = System.currentTimeMillis()

def cacheValid = false
if (timestampFile.exists()) {
    try {
        def lastTs = timestampFile.text.toLong()
        if (now - lastTs < TTL_MILLIS) {
            cacheValid = true
        } else {
            logger.info("[fetchProductsAzure] 🕒 Cache abgelaufen – leere Cache-Dateien")
            cacheDir.listFiles().each { it.delete() }
            timestampFile.delete()
        }
    } catch (Exception e) {
        logger.warn("[fetchProductsAzure] ⚠️ Fehler beim Lesen des Timestamp-Files: ${e.message}")
    }
}

if (cacheValid && cacheFile.exists()) {
    try {
        logger.info("[fetchProductsAzure] 💾 Cache-Hit für skip = ${skip}")
        def cached = new JsonSlurper().parse(cacheFile)
        def response = new Response(Status.OK)
        response.headers['Content-Type'] = 'application/json'
        response.entity.json = cached
        return Promises.newResultPromise(response)
    } catch (Exception e) {
        logger.warn("[fetchProductsAzure] ⚠️ Fehler beim Lesen der Cache-Datei: ${e.message}")
    }
}

// === Azure-Request aufbauen ===
def azureQuery = ["\$skip=${skip}", "\$top=${top}"]
if (queryMap['_queryFilter']) {
    def filter = queryMap['_queryFilter']
    azureQuery.add("\$filter=" + URLEncoder.encode(filter, "UTF-8"))
}
def requestUrl = baseUrl + "?" + azureQuery.join("&")
logger.info("[fetchProductsAzure] 🌐 Anfrage an Azure: ${requestUrl}")

def azureRequest = new Request()
azureRequest.uri = requestUrl
azureRequest.method = 'GET'
azureRequest.headers['Accept'] = 'application/json'

// === Azure-Request senden und Response verarbeiten ===
return next.handle(context, azureRequest).thenAsync { azureResponse ->
    def responseCode = azureResponse.status.code

    // === Microsoft-Header auslesen ===
    def remaining = azureResponse.headers.getFirst('x-ms-ratelimit-remaining-retailprices-requests')?.toInteger()
    def retryAfterHeader = azureResponse.headers.getFirst('x-ms-ratelimit-retailprices-retry-after')
    def retryAfter = retryAfterHeader?.isInteger() ? retryAfterHeader.toInteger() * 1000 : MIN_WAIT_TIME

    if (responseCode == 429 || (remaining != null && remaining <= 1)) {
        logger.warn("[fetchProductsAzure] ⛔ Azure Rate-Limit erreicht. Warte ${retryAfter}ms …")
        Thread.sleep(retryAfter)
        return next.handle(context, azureRequest).thenAsync(this)
    }
    
    logger.info("[fetchProductsAzure] 📊 Remaining: ${remaining} – Retry-After: ${retryAfterHeader}")

    def json = new JsonSlurper().parseText(azureResponse.entity.string)
    def result = json?.Items ?: json?.items ?: []

    def nextLink = json?.NextPageLink
    def nextAzureSkip = null
    if (nextLink) {
        def matcher = nextLink.replace("\$", "__DOLLAR__") =~ /[?&]__DOLLAR__skip=(\d+)/
        if (matcher.find()) {
            nextAzureSkip = matcher.group(1).toInteger()
            logger.info("[fetchProductsAzure] ✅ Gefundener NextPage skip = ${nextAzureSkip}")
        }
    }
    def nextOffset = nextAzureSkip ? (nextAzureSkip.intdiv(20)) : null

    def wrapper = [
        result               : result,
        pagedResultsCookie   : nextLink != null ? nextLink.toString().bytes.encodeBase64().toString() : null,
        remainingPagedResults: result.size()
    ]
    if (nextOffset != null) {
        wrapper['_pagedResultsOffset'] = nextOffset
    }

    def response = new Response(Status.OK)
    response.headers['Content-Type'] = 'application/json'
    response.entity.json = wrapper

    try {
        cacheFile.text = JsonOutput.toJson(wrapper)
        timestampFile.text = now.toString()
        logger.info("[fetchProductsAzure] 📝 Cache gespeichert für skip = ${skip}")
    } catch (Exception e) {
        logger.warn("[fetchProductsAzure] ⚠️ Fehler beim Schreiben in Cache: ${e.message}")
    }

    return Promises.newResultPromise(response)
}