#!/usr/bin/env python3
from http.server import HTTPServer, SimpleHTTPRequestHandler
import os

class CORSRequestHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET')
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        return super(CORSRequestHandler, self).end_headers()

os.makedirs('../data/asset-store/', exist_ok=True)
os.chdir('../data/asset-store/')
httpd = HTTPServer(('localhost', 58715), CORSRequestHandler)
httpd.serve_forever()
