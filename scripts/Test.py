import socket

HOST = '127.0.0.1'                 # Symbolic name meaning all available interfaces
PORT = 1301             # Arbitrary non-privileged port

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))

s.sendall('Hello, world')
data = s.recv(1024)
s.close()
print 'Received', repr(data)