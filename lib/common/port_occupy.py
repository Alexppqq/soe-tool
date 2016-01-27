#!/usr/bin/python
import socket
import sys

host='127.0.0.1'
port=int(sys.argv[1])
s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
s.bind((host,port))
s.listen(2)
try:

      while True:
              conn,add=s.accept()
              while True:
                      data1=conn.recv(3)
except KeyboardInterrupt:
      print "you have CTRL+C,Now quit"
      s.close()
