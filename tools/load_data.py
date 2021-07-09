import pymessaging.message_pb2 as msg
import pdb
imu = msg.IMU()
vicon = msg.VICON()
f = open("out.bin","rb")
data = f.read(2)
print(data)
print(int.from_bytes(data, "big"))
data = f.read(95)
imu.ParseFromString(data)
print(imu)
f.close()