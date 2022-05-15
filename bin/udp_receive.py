#!/usr/bin/env python3

import pdb
import socket
import struct
import sys

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server_address = ("127.0.0.1", 4444)
s.bind(server_address)
print("Ctrl-C to exit")

while True:
	print("Listening on 127.0.0.1:4444")
	data, address = s.recvfrom(36)
	pdb.set_trace()
	(t,m1,m2,m3,m4) = struct.unpack('f4d', data)
