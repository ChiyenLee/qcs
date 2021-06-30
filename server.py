from pymessaging import messaging
import pymessaging.message_pb2 as msg
import zmq 
import time 
import random

# Creating a publisher
ctx = zmq.Context() 
pub = messaging.create_pub(ctx, "5002")

# Creating a message 
imu = msg.IMU()
imu.quaternion[:] = [1.,0,0,0]
imu.rpy[:] = [0,0,0]
imu.gyro[:] = [0,0,0]

while True:
    print('sending data')
    imu.time = time.time()
    imu.quaternion[0] = random.gauss(0,1)
    data = imu.SerializeToString()
    pub.send(data) 
    time.sleep(0.01)