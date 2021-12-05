#!/usr/bin/env python3
## 
## Copyright (c) 2021 Robert Ryszard Paciorek <rrp@opcode.eu.org>
## 
## MIT License
## 
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.
## 
## 
## prosty serwer HTTP z użyciem Pythona
## pozwalający na uruchomienie na skutek żądania jakiejś akcji po stronie serwera
## 
## prosty serwer serwujący pliki to `python3 -m http.server` :)

from http.server import HTTPServer, BaseHTTPRequestHandler

class HttpHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/plain;charset=utf-8')
        self.end_headers()
        # tu możemy wykonać jakąś akcję
        # (w oparciu o argumenty żądania GET zawarte w self.path)
        # i odesłać odpowiedź:
        self.wfile.write(('Hello, world!\nŻądanie:' + self.path).encode())

httpd = HTTPServer(('localhost', 8000), HttpHandler)
httpd.serve_forever()
