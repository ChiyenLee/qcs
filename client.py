from pymessaging import messaging
from pymessaging import logger
import zmq 
import time 
import pymessaging.message_pb2 as msg

ctx = zmq.Context()
vicon_sub = messaging.create_sub(ctx, "5000")
imu_sub = messaging.create_sub(ctx, "5002")
vicon = msg.VICON()
imu = msg.IMU()

print("waiting for data")
poller = zmq.Poller()
poller.register(imu_sub, zmq.POLLIN)
poller.register(vicon_sub, zmq.POLLIN)

f = open("out.bin", "wb")
try: 
    while True: 
        socks = dict(poller.poll())
        if imu_sub in socks.keys() and socks[imu_sub] == zmq.POLLIN:
            data = imu_sub.recv(zmq.DONTWAIT) 
            imu.ParseFromString(data)
            print(imu)

        if vicon_sub in socks.keys() and socks[vicon_sub] == zmq.POLLIN:
            data = vicon_sub.recv(zmq.DONTWAIT)
            vicon.ParseFromString(data)
            
        

except KeyboardInterrupt:
    f.close()
    print("interrupted!")
    
