import SocketServer

class UDPHandler(SocketServer.BaseRequestHandler):
    def handle(self):
        data = self.request[0].strip()
        socket = self.request[1]
        print "{} wrote:".format(self.client_address[0])
        print data
        socket.sendto(data.upper(), self.client_address)

if __name__ == "__main__":
    HOST, PORT = "localhost", 8019
    server = SocketServer.UDPServer((HOST, PORT), UDPHandler)
    server.serve_forever()