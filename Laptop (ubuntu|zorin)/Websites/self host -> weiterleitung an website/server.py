from http.server import BaseHTTPRequestHandler, HTTPServer

HTML = """
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="utf-8">
<title>Sicherheitswarnung</title>
<style>
body {
  background:black;
  color:red;
  font-family:monospace;
  text-align:center;
  padding-top:20vh;
}
.blink { animation: blink 1s infinite; }
@keyframes blink { 50% { opacity: 0; } }
</style>
</head>
<body>
<h1 class="blink">⚠ SYSTEMWARNUNG ⚠</h1>
<p>Ungewöhnliche Netzwerkaktivität erkannt.</p>
<p>Analyse läuft…</p>
</body>
</html>
"""

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        content = HTML.encode("utf-8")

        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        self.wfile.write(content)

    def log_message(self, format, *args):
        pass

HTTPServer(("0.0.0.0", 80), Handler).serve_forever()

