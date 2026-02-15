#!/usr/bin/env python3
"""Minimal HTTP server returning 200 on /health/readiness. For testing test_agent_mail.sh."""
import http.server
import socketserver
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 9876


class HealthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.rstrip("/") == "/health/readiness":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"OK")
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        pass


with socketserver.TCPServer(("", PORT), HealthHandler) as httpd:
    httpd.serve_forever()
