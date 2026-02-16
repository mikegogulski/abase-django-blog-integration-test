#!/usr/bin/env python3
"""HTTP server that returns 503 for first N requests to /health/readiness, then 200.
For testing ensure_agent_mail.sh retry loop. Usage: mock_delayed_health_server.py <port> [fail_count]"""
import http.server
import socketserver
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 9876
FAIL_COUNT = int(sys.argv[2]) if len(sys.argv) > 2 else 2

request_count = [0]  # mutable for closure


class DelayedHealthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.rstrip("/") == "/health/readiness":
            request_count[0] += 1
            if request_count[0] <= FAIL_COUNT:
                self.send_response(503)
                self.send_header("Content-Type", "text/plain")
                self.end_headers()
                self.wfile.write(b"Not ready")
            else:
                self.send_response(200)
                self.send_header("Content-Type", "text/plain")
                self.end_headers()
                self.wfile.write(b"OK")
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        pass


with socketserver.TCPServer(("", PORT), DelayedHealthHandler) as httpd:
    httpd.serve_forever()
