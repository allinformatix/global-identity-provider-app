import org.forgerock.http.protocol.*
import groovy.json.*

def debug = (System.getenv("IG_DEBUG_AI") == "true")
if (debug) logger.info("🚀 [runpodPrompt] Script started")

// Nur POST erlauben
if (request.method != 'POST') {
    def error = new Response(Status.METHOD_NOT_ALLOWED)
    error.headers.add("Content-Type", ["text/plain"])
    error.entity = new Entity(error)
    error.entity.setString("❌ Only POST requests are allowed.")
    return error
}

// Body lesen oder Fallback setzen
def inputText = request.entity?.string?.trim()
if (!inputText) {
    inputText = '{"goal":"Create a basic AWS Lambda function","services":["lambda"]}'
    if (debug) logger.info("ℹ️ Using default input: " + inputText)
} else if (debug) {
    logger.info("📩 Incoming raw body: " + inputText)
}

// JSON parsen
def json = new JsonSlurper().parseText(inputText)
def userGoal = json.goal ?: "Create a simple AWS Lambda function"
def services = json.services ?: ["lambda"]

if (debug) {
    logger.info("📝 Goal: ${userGoal}")
    logger.info("📦 Services: ${services}")
}

// Prompt vorbereiten
def promptText = """
You are a DevOps AI assistant. The user wants to build an AWS infrastructure.
Goal: ${userGoal}
Services: ${services.join(", ")}
Respond with a JSON-formatted Terraform recommendation.
"""

def runpodPayload = [
  input: [
    prompt         : promptText,
    temperature    : 0.7,
    max_new_tokens : 512,
    system_prompt  : "You are a helpful assistant specialized in cloud infrastructure and infrastructure-as-code."
  ]
]

// API Key holen
def apiKey = System.getenv("RUNPOD_API_KEY")
if (!apiKey) {
    logger.warn("❌ Missing API key")
    def error = new Response(Status.INTERNAL_SERVER_ERROR)
    error.headers.add("Content-Type", ["text/plain"])
    error.entity = new Entity(error)
    error.entity.setString("Missing API key in env var RUNPOD_API_KEY")
    return error
}

// Anfrage anpassen
request.uri.scheme = "https"
request.uri.host = "api.runpod.ai"
request.uri.path = "/v2/a0ln1b3e89wmet/run"
request.method = "POST"
request.headers.clear()
request.headers.add("Content-Type", ["application/json"])
request.headers.add("Authorization", ["Bearer " + apiKey])

// Entity erzeugen
def bodyJson = new JsonBuilder(runpodPayload).toPrettyString()
def entity = new Entity(request)
entity.setString(bodyJson)
request.entity = entity

if (debug) {
    logger.info("📤 Forwarding request to: ${request.uri}")
    logger.info("📤 Body:\n${bodyJson}")
}

return next.handle(context, request)