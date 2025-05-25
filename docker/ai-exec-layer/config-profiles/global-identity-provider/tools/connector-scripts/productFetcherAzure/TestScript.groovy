/*
 * Copyright 2014-2018 ForgeRock AS. All Rights Reserved
 *
 * Use of this code requires a commercial software license with ForgeRock AS.
 * or with one of its affiliates. All use shall be exclusively subject
 * to such license between the licensee and ForgeRock AS.
 */
import groovyx.net.http.RESTClient
import groovyx.net.http.HttpResponseException
import static groovyx.net.http.ContentType.URLENC
import static groovyx.net.http.ContentType.JSON
import org.apache.http.client.HttpClient
import org.identityconnectors.common.logging.Log
import org.forgerock.openicf.connectors.groovy.OperationType
import org.forgerock.openicf.connectors.scriptedrest.ScriptedRESTConfiguration
import org.identityconnectors.framework.common.exceptions.ConnectorSecurityException

def operation = operation as OperationType
def configuration = configuration as ScriptedRESTConfiguration
def httpClient = connection as HttpClient
def connection = customizedConnection as RESTClient
def log = log as Log

log.info("Entering TEST Script")

try {
    log.info("Entering TEST Script - Test connection with explicit OAuth2 Authentication")

    // Test Aufruf gegen IG Test-Endpoint
    def response = connection.get(
        path: "/ig/productFetcher/test",
        headers: [
            'Accept'       : 'application/json'
        ]
    )

    if (response.status == 200) {
        log.info("✅ Connection Test successful: IG responded with 200 OK")
    } else {
        log.error("❌ Test failed: Unexpected response: ${response.status}")
        throw new ConnectorSecurityException("Test failed: IG responded with ${response.status}")
    }

} catch (HttpResponseException e) {
    log.error("❌ Connection test failed: ${e.statusCode} - ${e.message}")
    throw new ConnectorSecurityException("Connection test failed: HTTP ${e.statusCode}")
}
