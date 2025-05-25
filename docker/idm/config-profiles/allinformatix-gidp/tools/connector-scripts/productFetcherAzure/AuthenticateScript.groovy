/*
 * Copyright 2014-2018 ForgeRock AS. All Rights Reserved
 *
 * Use of this code requires a commercial software license with ForgeRock AS.
 * or with one of its affiliates. All use shall be exclusively subject
 * to such license between the licensee and ForgeRock AS.
 */
/*
 * Extension Copyright 2025 by Fehmi M'Barek of allinformatix e.K. GERMANY
 */

import groovy.json.JsonSlurper
import groovyx.net.http.RESTClient
import groovyx.net.http.HttpResponseException
import static groovyx.net.http.ContentType.URLENC
import static org.forgerock.json.JsonValue.json

import org.apache.http.client.HttpClient
import org.identityconnectors.common.logging.Log
import org.identityconnectors.common.security.GuardedString
import org.identityconnectors.common.security.SecurityUtil
import org.forgerock.openicf.connectors.groovy.OperationType
import org.forgerock.openicf.connectors.scriptedrest.ScriptedRESTConfiguration
import org.identityconnectors.framework.common.exceptions.ConnectorSecurityException

def operation = operation as OperationType
def configuration = configuration as ScriptedRESTConfiguration
def httpClient = connection as HttpClient
def customizedConnection = customizedConnection as RESTClient
def username = username as String
def password = password as Object
def log = log as Log

log.info("Entering ${operation} script for OAuth2 Authentication")

// // Lese System Properties (über openidm.setup.json oder system.properties bereitgestellt)
// def idpAuthnUrl = "http://am/am/oauth2/access_token"
// def clientId = "allinformatix-global-idp"
// def rawSecret = System.getenv("REALMS_ROOT_OAUTH2CLIENTS_ALLINFORMATIX_GLOBALIDP") ?: "allinformatix-global-idp"
// rawSecret = rawSecret.trim().replaceAll(/^"|"$/, "")
// def decodedSecret = new String(Base64.decoder.decode(rawSecret), "UTF-8")

// // Wenn Username und Passwort gesetzt sind → Resource Owner Password Grant
// // sonst → Client Credentials Grant
// def postBody
// if (username && password) {
//     def pwd = password instanceof GuardedString ? SecurityUtil.decrypt(password) : password as String
//     postBody = [
//         grant_type    : 'password',
//         client_id     : clientId,
//         client_secret : decodedSecret,
//         username      : username,
//         password      : pwd,
//         scope         : 'mail'
//     ]
// } else {
//     postBody = [
//         grant_type    : 'client_credentials',
//         client_id     : clientId,
//         client_secret : decodedSecret,
//         scope         : 'mail'
//     ]
// }

// // API-Call an IDP/AM
// def client = new RESTClient(idpAuthnUrl)
// client.headers.'Accept' = 'application/json'

// try {
//     def response = client.post(
//         requestContentType : URLENC,
//         body               : postBody
//     )

//     if (response.status == 200) {
//         def accessToken = response.data?.access_token
//         if (!accessToken) {
//             throw new ConnectorSecurityException("Access Token not found in response")
//         }
//         // Setze das AccessToken in den Authorization Header für zukünftige Requests
//         customizedConnection.defaultRequestHeaders.'Authorization' = "Bearer ${accessToken}"

//         log.info("✅ Successfully authenticated, token applied.")
//     } else {
//         log.error("❌ Authentication failed with status ${response.status}")
//         throw new ConnectorSecurityException("Authentication failed: ${response.status}")
//     }
// } catch (HttpResponseException e) {
//     log.error("❌ Authentication request failed: HTTP ${e.statusCode} - ${e.message}")
//     throw new ConnectorSecurityException("Authentication request failed: HTTP ${e.statusCode}")
// }
