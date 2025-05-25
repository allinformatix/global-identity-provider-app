import static groovyx.net.http.Method.GET
import groovyx.net.http.RESTClient
import org.identityconnectors.framework.common.objects.*
import org.identityconnectors.framework.common.exceptions.ConnectorException
import org.forgerock.openicf.connectors.groovy.OperationType
import org.forgerock.openicf.connectors.scriptedrest.ScriptedRESTConfiguration
import org.identityconnectors.common.logging.Log
import groovyx.net.http.HttpResponseException
import org.identityconnectors.framework.common.objects.filter.Filter
import org.forgerock.openicf.connectors.scriptedrest.SimpleCRESTFilterVisitor
import org.forgerock.openicf.connectors.scriptedrest.VisitorParameter
import groovy.json.*

def operation = operation as OperationType
def configuration = configuration as ScriptedRESTConfiguration
def connection = customizedConnection as RESTClient
def log = log as Log
def options = options as OperationOptions
def objectClass = objectClass as ObjectClass
def filter = filter as Filter

log.info("📥 Entering Azure SearchScript with IG Paging Emulation")

def basePath = "/ig/productFetcher/azure"
def queryParams = [:]

// === Filter-Verarbeitung ===
if (filter != null) {
    def queryFilter = filter.accept(SimpleCRESTFilterVisitor.INSTANCE, [
        translateName: { name ->
            if (AttributeUtil.namesEqual(name, Uid.NAME) || AttributeUtil.namesEqual(name, Name.NAME)) {
                return "meterId"
            }
            return name
        },
        convertValue: { Attribute value ->
            return AttributeUtil.getStringValue(value)
        }
    ] as VisitorParameter)

    queryParams["_queryFilter"] = queryFilter.toString()
    log.info("🔍 _queryFilter → ${queryParams['_queryFilter']}")
}

// === Paging-Parameter ===
if (null != options.pageSize) {
    queryParams['_pageSize'] = options.pageSize
    log.info("📐 Using _pageSize: ${options.pageSize}")
    if (null != options.pagedResultsCookie) {
        queryParams['_pagedResultsCookie'] = options.pagedResultsCookie
        log.info("➡️ Using _pagedResultsCookie: ${options.pagedResultsCookie}")
    }
    if (null != options.pagedResultsOffset) {
        queryParams['_pagedResultsOffset'] = options.pagedResultsOffset
        log.info("➡️ Using _pagedResultsOffset: ${options.pagedResultsOffset}")
    }
}

def cookie = null
def totalCount = -1
def items = []

try {
    def seenUids = new HashSet()
    def searchResult = connection.request(GET) { req ->
        uri.path = basePath
        uri.query = queryParams

        response.success = { resp, json ->
            log.info("📨 Raw response from IG received")
          
            def rawItems = json?.result ?: []
            log.info("📨 received Items --> ${rawItems.size()}")
            if (!(rawItems instanceof List)) rawItems = []

            rawItems.each { item ->
                def tier = item?.tierMinimumUnits
                def tierClean = (tier instanceof Number && tier.toDouble() % 1 == 0) ? tier.intValue() : tier
                def uidComponents = [item?.meterId, item?.skuId, item?.serviceId, item?.type, tierClean]
                if (uidComponents.any { it == null }) {
                    log.warn("❌ Skip item due to missing UID component: ${uidComponents}")
                    return
                }
                def uidVal = uidComponents.join("_")

                if (seenUids.contains(uidVal)) {
                    log.warn("❌ Duplicate UID skipped: ${uidVal}")
                    return
                }
                seenUids << uidVal

                handler {
                    uid uidVal
                    id uidVal
                    item.each { k, v -> attribute k, v }
                }
            }
            json
        }
    }
    log.info("PageInformation --> ${searchResult.pagedResultsCookie}")
    log.info("remainingPagedResults --> ${searchResult.remainingPagedResults}")

    return new SearchResult(searchResult.pagedResultsCookie, searchResult.remainingPagedResults)

} catch (HttpResponseException e) {
    log.error("❌ HTTP ${e.response?.status}: ${e.response?.statusLine?.reasonPhrase}")
    throw new ConnectorException("HTTP ${e.response?.status}: ${e.response?.statusLine?.reasonPhrase}")
} catch (Exception e) {
    log.error("❌ Unexpected error: ${e.message}")
    throw new ConnectorException("Search error: ${e.message}", e)
}