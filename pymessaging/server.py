from messaging import * 
import zmq 
import time 
import message_pb2 as msg

# Creating a publisher
ctx = zmq.Context() 
pub = create_pub(ctx, "5000")

# Creating a message 
imu = msg.IMU()
imu.quaternion[:] = [1.,0,0,0]
imu.rpy[:] = [0,0,0]
imu.gyro[:] = [0,0,0]
# imu.quaternion.extend([0,0,0,0])

# SerializeToString() 
# ParseFromString()
while True:
    print('sending data')
    imu.time = time.time()
    data = imu.SerializeToString()
    pub.send(data) 
    time.sleep(0.01)