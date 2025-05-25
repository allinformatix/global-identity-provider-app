cat << 'EOF' > conf/provisioner.openicf-productFetcherAzure.json
{
    "connectorRef" : {
        "displayName" : "Scripted REST Connector",
        "bundleVersion" : "1.5.20.21",
        "systemType" : "provisioner.openicf",
        "bundleName" : "org.forgerock.openicf.connectors.scriptedrest-connector",
        "connectorName" : "org.forgerock.openicf.connectors.scriptedrest.ScriptedRESTConnector"
    },
    "operationTimeout" : {
        "CREATE" : -1,
        "UPDATE" : -1,
        "DELETE" : -1,
        "TEST" : -1,
        "SCRIPT_ON_CONNECTOR" : -1,
        "SCRIPT_ON_RESOURCE" : -1,
        "GET" : -1,
        "RESOLVEUSERNAME" : -1,
        "AUTHENTICATE" : -1,
        "SEARCH" : -1,
        "VALIDATE" : -1,
        "SYNC" : -1,
        "SCHEMA" : -1
    },
    "configurationProperties" : {
        "username" : null,
        "password" : null,
        "serviceAddress" : "http://ig/ig/productFetcher/azure",
        "proxyAddress" : null,
        "proxyUsername" : null,
        "proxyPassword" : null,
        "defaultAuthMethod" : "OAUTH",
        "OAuthGrantType" : "client_credentials",
        "OAuthClientId" : "allinformatix-global-idp",
        "OAuthClientSecret" : "JoneSIjBPeuv6f8xMj1COVOKAHtl1YfuPVbjBZpkYcN5t0GwllToNuEbpT65DTJ3",
        "OAuthScope" : "mail",
        "OAuthTokenEndpoint" : "http://am/am/oauth2/access_token",
        "defaultRequestHeaders" : [ ],
        "defaultContentType" : "application/json",
        "scriptExtensions" : [
            "groovy"
        ],
        "sourceEncoding" : "UTF-8",
        "authenticateScriptFileName" : "AuthenticateScript.groovy",
        "customizerScriptFileName" : "CustomizerScript.groovy",
        "createScriptFileName" : "CreateScript.groovy",
        "deleteScriptFileName" : "DeleteScript.groovy",
        "schemaScriptFileName" : "SchemaScript.groovy",
        "scriptOnResourceScriptFileName" : "ScriptOnResourceScript.groovy",
        "searchScriptFileName" : "SearchScript.groovy",
        "syncScriptFileName" : null,
        "testScriptFileName" : "TestScript.groovy",
        "updateScriptFileName" : "UpdateScript.groovy",
        "scriptBaseClass" : null,
        "recompileGroovySource" : false,
        "minimumRecompilationInterval" : 100,
        "debug" : true,
        "verbose" : false,
        "warningLevel" : 1,
        "tolerance" : 10,
        "disabledGlobalASTTransformations" : null,
        "targetDirectory" : null,
        "scriptRoots" : [
            "&{idm.instance.dir}/tools/connector-scripts/productFetcherAzure"
        ]
    },
    "objectTypes" : { },
    "resultsHandlerConfig" : {
        "enableNormalizingResultsHandler" : true,
        "enableFilteredResultsHandler" : true,
        "enableCaseInsensitiveFilter" : false,
        "enableAttributesToGetSearchResultsHandler" : true
    }
}
EOF