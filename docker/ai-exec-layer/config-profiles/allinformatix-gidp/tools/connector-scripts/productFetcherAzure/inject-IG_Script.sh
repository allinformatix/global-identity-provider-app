cat << 'EOF' > /var/ig/scripts/groovy/fetchProductsAzure.groovy
import org.forgerock.http.protocol.*
import groovy.json.*
import java.net.URLEncoder
import java.net.URLDecoder

logger.info("[fetchProductsAzure] 🟢 Preparing dynamic request to Azure Pricing API...")

def debugging = true
if (debugging) {
    logger.info("[fetchProductsAzure] 🐛 Debugging aktiviert")
}

def baseUrl = 'https://prices.azure.com/api/retail/prices'

def queryString = request.uri.query
logger.info("[fetchProductsAzure] 🔍 QueryString erhalten: ${queryString}")

def queryMap = [:]
if (queryString) {
    queryString.split('&').each { param ->
        def parts = param.split('=', 2)
        if (parts.length == 2) {
            def key = parts[0]
            def value = URLDecoder.decode(parts[1], 'UTF-8')
            queryMap[key] = value
            logger.info("[fetchProductsAzure] queryMap[${key}] = ${value}")
        } else {
            logger.warn("[fetchProductsAzure] ⚠️ Ungültiger Query-Parameter: ${param}")
        }
    }
}

logger.info("[fetchProductsAzure] 🧩 Parsed queryMap keys: ${queryMap.keySet()}")

def filterFields = [
    "armRegionName", "location", "meterId", "meterName", "productId", "skuId",
    "productName", "skuName", "serviceName", "serviceId", "serviceFamily",
    "priceType", "armSkuName"
]

def filterParts = []
filterFields.each { field ->
    if (queryMap[field]) {
        def encoded = URLEncoder.encode(queryMap[field], 'UTF-8')
        filterParts.add("${field} eq '${encoded}'")
        logger.info("[fetchProductsAzure] ✅ Filter hinzugefügt: ${field} eq '${queryMap[field]}'")
    }
}

def queryParams = []

if (queryMap['\$filter']) {
    logger.info("[fetchProductsAzure] 🧾 Übernehme externen \$filter direkt: ${queryMap['$filter']}")
    queryParams.add("\$filter=" + URLEncoder.encode(queryMap['$filter'], 'UTF-8'))
} else if (!filterParts.isEmpty()) {
    def finalFilter = filterParts.join(' and ')
    queryParams.add("$filter=" + finalFilter)
    logger.info("[fetchProductsAzure] 🔧 Generierter Filter: ${finalFilter}")
}

if (queryMap["currencyCode"]) {
    def currency = URLEncoder.encode(queryMap["currencyCode"], "UTF-8")
    queryParams.add("currencyCode=" + currency)
    logger.info("[fetchProductsAzure] 💱 currencyCode hinzugefügt: ${currency}")
}

def requestUrl = baseUrl
if (!queryParams.isEmpty()) {
    requestUrl += "?" + queryParams.join('&')
    logger.info("[fetchProductsAzure] 🚀 Final Azure Request-URL: ${requestUrl}")
} else {
    logger.warn("[fetchProductsAzure] ⚠️ Keine Filter-Parameter gesetzt. Es wird ein kompletter Dump der Preise geladen!")
}

// Baue neuen Request
def newRequest = new Request()
newRequest.method = 'GET'
newRequest.uri = requestUrl
newRequest.headers.add('Accept', 'application/json')
logger.info("[fetchProductsAzure] 📡 Request vorbereitet und wird gesendet...")

return next.handle(context, newRequest)
    .thenOnResult { response ->
        logger.info("[fetchProductsAzure] 📥 Antwort erhalten mit Status ${response.status.code}")

        def remaining = response.headers.getFirst('x-ms-ratelimit-remaining-retailprices-requests')?.toInteger()
        def retryAfter = response.headers.getFirst('x-ms-ratelimit-retailprices-retry-after')?.toInteger()

        if (remaining != null && retryAfter != null) {
            if (remaining <= 1) {
                logger.warn("[fetchProductsAzure] ⛔ Azure Rate Limit erreicht! Remaining: ${remaining}, Retry-After: ${retryAfter}s")
                throw new Exception("Azure Rate Limit erreicht. Bitte nach ${retryAfter} Sekunden erneut versuchen.")
            } else {
                logger.info("[fetchProductsAzure] ✅ Remaining Requests: ${remaining}, Retry After (optional): ${retryAfter}s")
            }
        }

        return response
    }
EOF