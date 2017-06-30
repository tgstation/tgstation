#!/usr/bin/env python3
import sys
import pickle
import socket


def pack():
    port = int(sys.argv[1])
    data = sys.argv[2]

    nudge(str.encode(data), port)


def nudge(data, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(("localhost", port))
    s.send(data)
    s.close()

if __name__ == "__main__" and len(sys.argv) > 1:
    pack()
