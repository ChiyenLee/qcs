from pymessaging import messaging
import zmq 
import time 
import pymessaging.message_pb2 as msg

ctx = zmq.Context()
sub = messaging.create_sub(ctx, "5000")
vicon = msg.VICON()
print("waiting for data")
while True: 
    data = sub.recv()
    vicon.ParseFromString(data)
    print(vicon) 