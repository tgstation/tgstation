#!/usr/bin/env python3

#This method of service communication is deprecated, you should be using the interface dll method
import sys
import pickle
import socket


def pack():
    data = sys.argv[1]

    nudge(str.encode(data))


def nudge(data):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    with open('config/server_to_tool_bridge_port.txt', 'r') as myfile:
        portstr=myfile.read().replace('\n', '').strip()
    s.connect(("localhost", int(portstr)))
    s.send(data)
    s.close()

if __name__ == "__main__" and len(sys.argv) > 1:
    pack()
