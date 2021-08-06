import sys 
sys.path.append("..")
from pymessaging import messaging
import pymessaging.message_pb2 as msg
import zmq 
import time 
import random

# Creating a publisher
ctx = zmq.Context() 
pub = messaging.create_pub(ctx, "5002")
# vicon_pub = messaging.create_pub(ctx, "5000")

# Creating a message 
imu = msg.IMU_msg()
vicon = msg.Vicon_msg()
imu.gyroscope.x = 1.0
imu.gyroscope.y = 2.0 
imu.gyroscope.z = 3.0 
imu.acceleration.x = 1.0 
imu.acceleration.y = 2.0 
imu.acceleration.z = 3.0 
imu.time= 0.0

vicon.quaternion.w = 1.0
vicon.quaternion.z = 0.0
vicon.quaternion.x = 0.0
vicon.quaternion.y = 0.0
vicon.position.x = 3.0
vicon.position.z = 2.0
vicon.position.y = 1.0
vicon.time = 0.0

# imu.acceleration.x = 1.0
while True:
    # imu.gyroscope.x = random.normalvariate(0,1)
    print('sending data')
    imu.time = time.time()
    data = imu.SerializeToString()
    pub.send(data) 

    # vicon.quaternion.y = random.normalvariate(0,1)
    # vicon.time = time.time()
    # data = vicon.SerializeToString()
    # vicon_pub.send(data)

    time.sleep(0.002)