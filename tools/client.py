import sys 
sys.path.append("..")
from pymessaging import messaging
from pymessaging import logger
import zmq 
import time 
import pymessaging.message_pb2 as msg

ctx = zmq.Context()
vicon_sub = messaging.create_sub(ctx, "5001", host="192.168.3.123")
imu_sub = messaging.create_sub(ctx, "5002", host="192.168.3.123")
ekf_sub = messaging.create_sub(ctx, "5003", host="192.168.3.123")
vicon = msg.Vicon_msg()
imu = msg.IMU_msg()
ekf = msg.EKF_msg()

print("waiting for data")
poller = zmq.Poller()
poller.register(imu_sub, zmq.POLLIN)
poller.register(vicon_sub, zmq.POLLIN)
poller.register(ekf_sub, zmq.POLLIN)

t_vicon = 0
#f = open("out.bin", "wb")
try: 
    while True: 
        socks = dict(poller.poll())
        if imu_sub in socks.keys() and socks[imu_sub] == zmq.POLLIN:
            data = imu_sub.recv(zmq.DONTWAIT) 
            imu.ParseFromString(data)
            # print(imu)

        if vicon_sub in socks.keys() and socks[vicon_sub] == zmq.POLLIN:
            data = vicon_sub.recv(zmq.DONTWAIT)
            vicon.ParseFromString(data)
            # print("vicon " )
            # print(vicon)
        
        if ekf_sub in socks.keys() and socks[ekf_sub] == zmq.POLLIN:
            # print(1/(time.time() - t_vicon))
            data = ekf_sub.recv(zmq.DONTWAIT)
            ekf.ParseFromString(data)
            t_vicon = time.time()
            print(ekf)
            
        

except KeyboardInterrupt:
    #f.close()
    print("interrupted!")
    
