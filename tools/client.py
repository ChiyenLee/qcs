import sys 
sys.path.append("..")
from pymessaging import messaging
from pymessaging import logger
import zmq 
import time 
import pymessaging.message_pb2 as msg

ctx = zmq.Context()
host = "127.0.0.1"
# host = "192.168.3.123"
vicon_sub = messaging.create_sub(ctx, "5001", host=host)
imu_sub = messaging.create_sub(ctx, "5002", host=host)
ekf_sub = messaging.create_sub(ctx, "5003", host=host)
motor_sub = messaging.create_sub(ctx, "5004", host=host)
# motor_sub = messaging.create_sub(ctx, "5055")
# v3_sub = messaging.create_sub(ctx, "5003", host="192.168.3.191")

vicon = msg.Vicon_msg()
imu = msg.IMU_msg()
ekf = msg.EKF_msg()
motor_msg = msg.MotorReadings_msg()
v3 = msg.Vector3_msg()

print("waiting for data")
poller = zmq.Poller()
poller.register(imu_sub, zmq.POLLIN)
poller.register(vicon_sub, zmq.POLLIN)
poller.register(ekf_sub, zmq.POLLIN)
poller.register(motor_sub, zmq.POLLIN)
# poller.register(v3_sub, zmq.POLLIN)

t_vicon = 0
#f = open("out.bin", "wb")
try: 
    t = time.time()
    while True: 
        socks = dict(poller.poll())
        if imu_sub in socks.keys() and socks[imu_sub] == zmq.POLLIN:
            data = imu_sub.recv(zmq.DONTWAIT) 
            imu.ParseFromString(data)
            # print(imu)
            print(imu)

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
            # print(ekf)
            # print(time.time() - t)
            # t = time.time()
        
        if motor_sub in socks.keys() and socks[motor_sub] == zmq.POLLIN:
            # print(1/(time.time() - t_vicon))
            data = motor_sub.recv(zmq.DONTWAIT)
            motor_msg.ParseFromString(data)
            # print(motor_msg)

        # if v3_sub in socks.keys() and socks[v3_sub] == zmq.POLLIN:
        #     # print(1/(time.time() - t_vicon))
        #     data = v3_sub.recv(zmq.DONTWAIT)
        #     v3.ParseFromString(data)
        #     # t_vicon = time.time()
        #     print(v3)

except KeyboardInterrupt:
    #f.close()
    print("interrupted!")
    
