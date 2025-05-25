import groovy.json.*

logger.info("[normalizeProductsResponse] Normalizing supplier response...")

def body = response.entity.json

def normalizedProducts = body?.Items?.collect { item ->
    [
        currencyCode: item?.currencyCode,
        retailPrice: item?.retailPrice,
        unitPrice: item?.unitPrice,
        armRegionName: item?.armRegionName,
        location: item?.location,
        effectiveStartDate: item?.effectiveStartDate,
        meterId: item?.meterId,
        meterName: item?.meterName,
        productId: item?.productId,
        skuId: item?.skuId,
        productName: item?.productName,
        skuName: item?.skuName,
        serviceName: item?.serviceName,
        serviceFamily: item?.serviceFamily,
        unitOfMeasure: item?.unitOfMeasure,
        type: item?.type,
        isPrimaryMeterRegion: item?.isPrimaryMeterRegion,
        armSkuName: item?.armSkuName,
        savingsPlan: item?.savingsPlan
    ]
}

response.headers.put('Content-Type', 'application/json')
response.entity = JsonOutput.toJson([
    success: true,
    count: normalizedProducts?.size() ?: 0,
    products: normalizedProducts
])

return response
