import socket
import threading

class SocketHandler(threading.Thread):
	
	def __init__(self):
		threading.Thread.__init__(self)
		HOST = '127.0.0.1'                 # Symbolic name meaning all available interfaces
		PORT = 1301             # Arbitrary non-privileged port
		s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		s.bind((HOST, PORT))
		s.listen(1)
		conn, addr = s.accept()
	
	def run(self):
		while 1:
			data = conn.recv(1024)
			if not data: break
			print(data)
		conn.close()
		print("Socket Closed")

socketHandler = SocketHandler()
socketHandler.start()

