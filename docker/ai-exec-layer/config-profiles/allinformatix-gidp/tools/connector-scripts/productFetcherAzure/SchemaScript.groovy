import static org.identityconnectors.framework.common.objects.AttributeInfo.Flags.*
import org.forgerock.openicf.connectors.groovy.ICFObjectBuilder
import org.forgerock.openicf.connectors.groovy.OperationType
import org.forgerock.openicf.connectors.scriptedrest.ScriptedRESTConfiguration
import org.identityconnectors.common.logging.Log

def operation = operation as OperationType
def configuration = configuration as ScriptedRESTConfiguration
def log = log as Log
def builder = builder as ICFObjectBuilder

log.info("Schema script, operation = ${operation}")

log.info("Entering " + operation + " Script");

builder.schema {
    objectClass {
        type "allProducts"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Compute"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "AI_Machine_Learning"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Analytics"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Azure_Arc"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Storage"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Databases"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Networking"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Azure_Communication_Services"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Azure_Security"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Azure_Stack"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Data"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Developer_Tools"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Dynamics"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Gaming"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Integration"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Internet_of_Things"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }    
    objectClass {
        type "Management_and_Governance"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Microsoft_Syntex"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Mixed_Reality"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Other"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Power_Platform"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Quantum_Computing"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Security"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Telecommunications"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Web"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
    objectClass {
        type "Windows_Virtual_Desktop"
        attributes {
            productId String.class
            productName String.class
            skuName String.class
            skuId String.class
            armSkuName String.class
            serviceName String.class
            serviceFamily String.class
            serviceId String.class
            armRegionName String.class
            location String.class
            tierMinimumUnits Double.class
            currencyCode String.class
            meterId String.class
            meterName String.class
            availabilityId String.class
            type String.class
            unitOfMeasure String.class
            reservationTerm String.class
            priceType String.class
            retailPrice Double.class
            unitPrice Double.class
            savingsPlan Map.class, MULTIVALUED
            isPrimaryMeterRegion Boolean.class
            effectiveStartDate String.class
            lastModified String.class
        }
    }
}
