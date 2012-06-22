import subprocess
import socket
import urlparse

UDP_IP="127.0.0.1"
UDP_PORT=8019

sock = socket.socket( socket.AF_INET, # Internet
                      socket.SOCK_DGRAM ) # UDP
sock.bind( (UDP_IP,UDP_PORT) )

def handle_message(data, addr):
    params = urlparse.parse_qs(data)
    print(data)
    
    try:
        if params["type"][0] == "log" and str(params["log"][0]) and str(params["message"][0]):
            open(params["log"][0],"a+").write(params["message"][0]+"\n")
    except IOError:
        pass
    except KeyError:
        pass

while True:
    try:
        data, addr = sock.recvfrom( 1024 ) # buffer size is 1024 bytes
        handle_message(data,addr)
    except socket.timeout:
        print("No response in 120 seconds.. Trying to reboot server.")
        subprocess.call("./restart")
    
    # start expecting a message after the first timeout
    sock.settimeout(120)