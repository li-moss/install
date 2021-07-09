# @Author: Li Yuan Rong
# @Date:   2021-06-19 08:52:02
# @Last Modified by:   Li Yuan Rong
# @Last Modified time: 2021-07-08 18:32:49
#!/usr/bin/python


import socket
import os

localIP     = "0.0.0.0"
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
   clientMsg = message.decode("utf-8")
   keyword = clientMsg.split()

   with open("/etc/hosts", "r+") as f:
      lines = f.readlines()
      f.seek(0)
      for line in lines:
         if keyword[2] not in line:
            f.write(line)
      f.write(clientMsg)
      f.truncate()
       
   os.system('sudo service dnsmasq restart')
    # Sending a reply to client
    #UDPServerSocket.sendto(bytesToSend, address)
