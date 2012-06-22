import subprocess
import socket
import urlparse

UDP_IP="127.0.0.1"
UDP_PORT=8019

sock = socket.socket( socket.AF_INET, # Internet
                      socket.SOCK_DGRAM ) # UDP
sock.bind( (UDP_IP,UDP_PORT) )

last_ticker_state = None

def handle_message(data, addr):
    global last_ticker_state
    
    params = urlparse.parse_qs(data)
    print(data)
    
    try:
        if params["type"][0] == "log" and str(params["log"][0]) and str(params["message"][0]):
            open(params["log"][0],"a+").write(params["message"][0]+"\n")
    except IOError:
        pass
    except KeyError:
        pass
    
    try:
        if params["type"][0] == "ticker_state" and str(params["message"][0]):
            last_ticker_state = str(params["message"][0])
    except KeyError:
        pass
    
    try:
        if params["type"][0] == "startup" and last_ticker_state:
            open("crashlog.txt","a+").write("Server exited, last ticker state was: "+last_ticker_state+"\n")
    except KeyError:
        pass
            

while True:
    data, addr = sock.recvfrom( 1024 ) # buffer size is 1024 bytes
    handle_message(data,addr)