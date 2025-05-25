/*
 * Copyright 2014-2018 ForgeRock AS. All Rights Reserved
 *
 * Use of this code requires a commercial software license with ForgeRock AS.
 * or with one of its affiliates. All use shall be exclusively subject
 * to such license between the licensee and ForgeRock AS.
 */

import static groovyx.net.http.Method.GET
import groovyx.net.http.RESTClient
import groovyx.net.http.HttpResponseException
import org.apache.http.client.HttpClient
import org.forgerock.openicf.connectors.groovy.OperationType
import org.forgerock.openicf.connectors.scriptedrest.ScriptedRESTConfiguration
import org.identityconnectors.common.logging.Log
import org.identityconnectors.framework.common.objects.*
import org.identityconnectors.framework.common.objects.ObjectClass

def operation = operation as OperationType
def configuration = configuration as ScriptedRESTConfiguration
def httpClient = connection as HttpClient
def connection = customizedConnection as RESTClient
def objectClass = objectClass as ObjectClass
def log = log as Log
// def handler = handler as ResultsHandler
def resultHandler = handler

log.info("Entering " + operation + " Script for objectClass " + objectClass.objectClassValue)

if (objectClass.objectClassValue == "realms") {
    try {
        connection.get(
            path: "/json/global-config/realms",
            query: [_queryFilter: "true"],
            requestContentType: "application/json"
        ) { response, json ->

            json.result.each { realm ->
                resultHandler {
                    uid realm._id
                    id realm._id
                    attribute 'name', realm.name
                    attribute 'parentPath', realm.parentPath
                    attribute 'active', realm.active
                    attribute 'aliases', realm.aliases
                }
            }
        }
    } catch (HttpResponseException e) {
        log.error("Search failed: " + e.response?.status + " " + e.response?.statusLine?.reasonPhrase)
        throw e
    }
}

return new SearchResult(null, -1)
