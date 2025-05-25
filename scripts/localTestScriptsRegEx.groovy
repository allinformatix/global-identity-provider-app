// def nextPageLink = "https://example.com/api/data?\$skip=3000"

// // Schritt 1: Platzhalter setzen
// def sanitizedUrl = nextPageLink.replace("\$", "__DOLLAR__")

// // Schritt 2: Regex anwenden
// def matcher = sanitizedUrl =~ /[\?&]__DOLLAR__skip=(\d+)/

// if (matcher.find()) {
//     def skipValue = matcher.group(1)
//     println "✅ Gefundener skip-Wert: ${skipValue}"

//     // Schritt 3: Optional wieder mit $ zusammensetzen
//     def newCookie = sanitizedUrl.replace("__DOLLAR__", "\$")
//     println "➡️ Wiederhergestellte URL: ${newCookie}"
// } else {
//     println "❌ Kein __DOLLAR__skip=... gefunden"
// }
def nextLink = "https://prices.azure.com/api/retail/prices?\$skip=2000"
println "Gefundener nextLink: ${nextLink}"
def matcher = nextLink =~ /[?&]\$skip=(\d+)/
if (matcher.find()) {
    println "Gefundener skip-Wert: ${matcher.group(1)}"
}