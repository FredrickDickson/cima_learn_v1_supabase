#!/usr/bin/env python3
"""
Custom HTTP server for Flutter web apps that handles client-side routing.
Serves index.html for all routes that don't exist as physical files.
"""
import http.server
import socketserver
import os
import mimetypes
from urllib.parse import urlparse

class FlutterHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="build/web", **kwargs)
    
    def do_GET(self):
        # Parse the URL
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        
        # Remove leading slash
        if path.startswith('/'):
            path = path[1:]
        
        # If path is empty, serve index.html
        if not path:
            path = 'index.html'
        
        # Full file path
        full_path = os.path.join(self.directory, path)
        
        # If file exists, serve it normally
        if os.path.exists(full_path) and os.path.isfile(full_path):
            return super().do_GET()
        
        # If it's a Flutter route (no file extension or doesn't exist), serve index.html
        if '.' not in os.path.basename(path) or not os.path.exists(full_path):
            self.path = '/index.html'
            return super().do_GET()
        
        # Otherwise, serve normally (will result in 404 if file doesn't exist)
        return super().do_GET()

def run_server(port=5000):
    # Enable port reuse
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("0.0.0.0", port), FlutterHandler) as httpd:
        print(f"Serving Flutter web app on port {port}")
        print(f"Visit http://localhost:{port} to view the app")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped")

if __name__ == "__main__":
    run_server()