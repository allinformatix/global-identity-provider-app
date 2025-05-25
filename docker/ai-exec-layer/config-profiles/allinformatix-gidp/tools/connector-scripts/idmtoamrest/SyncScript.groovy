/*
 * Copyright 2014-2018 ForgeRock AS. All Rights Reserved
 *
 * Use of this code requires a commercial software license with ForgeRock AS.
 * or with one of its affiliates. All use shall be exclusively subject
 * to such license between the licensee and ForgeRock AS.
 */

import static groovyx.net.http.Method.GET

import groovyx.net.http.RESTClient
import org.apache.http.client.HttpClient
import org.forgerock.openicf.connectors.groovy.OperationType
import org.forgerock.openicf.connectors.scriptedrest.ScriptedRESTConfiguration
import org.identityconnectors.common.logging.Log
import org.identityconnectors.framework.common.objects.*
import org.identityconnectors.framework.common.objects.SyncToken

def operation = operation as OperationType
def configuration = configuration as ScriptedRESTConfiguration
def httpClient = connection as HttpClient
def connection = customizedConnection as RESTClient
def log = log as Log
def objectClass = objectClass as ObjectClass

log.info("Entering " + operation + " Script");

def schemaBuilder = schema()

// HTTP-Aufruf an die AM-Instanz
def response = connection.request(GET) { req ->
    uri.path = "/json/global-config/realms"
    uri.query = [_queryFilter: "true"]
    headers["accept-api-version"] = "protocol=2.0,resource=1.0"

    response.success = { resp, json ->
        def first = json?.result?.getAt(0)
        if (!first) throw new Exception("No realms found to infer schema.")

        def objClassBuilder = objectClass {
            type "realms"

            // UID und NAME setzen
            uid "name"
            id "name"

            first.keySet().each { key ->
                def value = first[key]
                switch (value) {
                    case String:
                        attribute String.class, key
                        break
                    case Boolean:
                        attribute Boolean.class, key
                        break
                    case List:
                        attribute List.class, key
                        break
                    case Map:
                        attribute Map.class, key
                        break
                    case Number:
                        attribute Long.class, key
                        break
                    default:
                        attribute Object.class, key
                        break
                }
            }
        }

        schemaBuilder.defineObjectClass objClassBuilder.build()
    }

    response.failure = { resp, json ->
        throw new ConnectException("Failed to get schema from AM: ${json.message}")
    }
}

return schemaBuilder.build()
