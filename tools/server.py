import sys 
sys.path.append("..")
from pymessaging import messaging
import pymessaging.message_pb2 as msg
import zmq 
import time 
import random

# Creating a publisher
ctx = zmq.Context() 
pub = messaging.create_pub(ctx, "5001")
vicon_pub = messaging.create_pub(ctx, "5000")

# Creating a message 
imu = msg.IMU_msg()
vicon = msg.Vicon_msg()
imu.gyroscope.x = 1.0
vicon.quaternion.x = 1.0
vicon.quaternion.y = 0.5

# imu.acceleration.x = 1.0
while True:
    imu.gyroscope.x = random.normalvariate(0,1)
    print('sending data')
    imu.time = time.time()
    data = imu.SerializeToString()
    pub.send(data) 

    vicon.quaternion.y = random.normalvariate(0,1)
    vicon.time = time.time()
    data = vicon.SerializeToString()
    vicon_pub.send(data)

    time.sleep(0.005)