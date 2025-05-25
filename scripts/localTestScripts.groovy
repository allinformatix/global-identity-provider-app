#!/usr/bin/env groovy

@Grab(group='org.codehaus.groovy.modules.http-builder', module='http-builder', version='0.7')
@Grab(group='org.codehaus.groovy', module='groovy-json', version='2.4.15')

import groovyx.net.http.RESTClient
import groovyx.net.http.HttpResponseException
import static groovyx.net.http.ContentType.URLENC
import static groovyx.net.http.ContentType.JSON
import org.apache.http.util.EntityUtils
import org.apache.http.client.HttpResponseException
import java.util.Base64

def envStage = System.getenv("STAGE") ?: "stg"
println "🔍 Verwende Stage: $envStage"

def envFile = new File(".env.${envStage}")
if (!envFile.exists()) {
    println "❌ Die Datei .env.${envStage} wurde nicht gefunden."
    System.exit(1)
}

println "📄 Lade Umgebungsvariablen aus ${envFile.name}..."

envFile.eachLine { line ->
    // println "🔸 Ursprünglich: $line"
    if (!line.trim().startsWith("#") && line.contains("=")) {
        def (key, value) = line.split("=", 2)
        key = key.trim()
        value = value.trim()
        System.setProperty(key, value)
        // println "✅ Setze: $key = $value"
    } else {
        println "⏭️  Ignoriere Zeile"
    }
}

// Optional: einmal alles ausgeben
// println "\n📦 Aktuelle Properties:"
// System.properties.each { key, value ->
//     if (key.startsWith("OAUTH_") || key.startsWith("MY_") || key == "STAGE") {
//         println "🔐 $key = $value"
//     }
// }


def demoUserName = System.getProperty("DEMO_USER_NAME")
def demoUserPassword = System.getProperty("DEMO_USER_PASSWORD")
def idpAuthnUrl = System.getProperty("IDP_AUTHN_URL")
def clientId = System.getProperty("OAUTH_CLIENT_ID") ?: "allinformatix-global-idp"
def rawSecret = System.getProperty("REALMS_ROOT_OAUTH2CLIENTS_ALLINFORMATIX_GLOBALIDP") ?: "allinformatix-global-idp"
rawSecret = rawSecret.trim().replaceAll(/^"|"$/, "")
def decodedSecret = new String(Base64.decoder.decode(rawSecret), "UTF-8")

println "📡 IDP URL: ${idpAuthnUrl}"
println "📡 decodedSecret: ${decodedSecret}"

def postBody = [
    grant_type   : 'password',
    client_id    : clientId,
    client_secret: decodedSecret,
    username     : demoUserName,
    password     : demoUserPassword,
    scope        : 'mail'
]

def client = new RESTClient(idpAuthnUrl)
String responseBody = ""
try {
    def response = client.post(
        requestContentType : URLENC,
        body               : postBody
    )

    println "✅ Status: ${response.status}"
    // println "🔐 Access Token: ${response.data?.access_token}"
    println "🔐 Access Token: ${response.data}"

} catch (HttpResponseException e) {
    println "❌ Request failed: ${e.statusCode}"
    println "⛔ Response Body: ${e.message}"
}