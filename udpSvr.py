#!/usr/bin/python
# -*- coding: UTF-8 -*-

import socket

localIP     = "192.168.1.200"
localPort   = 20001
bufferSize  = 1024

# Create a datagram socket
UDPServerSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)

# Bind to address and ip
UDPServerSocket.bind((localIP, localPort))

print("UDP server up and listening")

# Listen for incoming datagrams
while(True):
    bytesAddressPair = UDPServerSocket.recvfrom(bufferSize)
    message = bytesAddressPair[0]
    clientMsg = format(message)
    keyword = clientMsg.split()
    print(keyword)

    with open("/etc/hosts", "r+") as f:
       lines = f.readlines()
       f.seek(0)
       for line in lines:
          if keyword[1] not in line:
             f.write(line)
       f.write(clientMsg)
       f.truncate()

    # Sending a reply to client
    #UDPServerSocket.sendto(bytesToSend, address)