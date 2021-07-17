import sys 
sys.path.append("..")
import pymessaging.message_pb2 as messaging
import pdb
import matplotlib.pyplot as plt
import numpy as np
import os 
class DataPack:
	def __init__(self, filename, proto_msg):
		self.filename = filename
		self.f = open(self.filename, "rb")
		self.proto_msg = proto_msg

	def __iter__(self):
		return self

	def __next__(self):
		msg_length_bytes = self.f.read(4)
		print(msg_length_bytes)
		print(int.from_bytes(msg_length_bytes, "big"))
		if len(msg_length_bytes) == 0:
			raise StopIteration
		else: 
			msg_length = int.from_bytes(msg_length_bytes, "big")
			data = self.f.read(msg_length)
			self.proto_msg.ParseFromString(data)
		return self.proto_msg
	
	def close(self):
		self.f.close()

# Initialize message 
imu = messaging.IMU_msg()
ekf = messaging.EKF_msg()
vicon = messaging.Vicon_msg()
# file = os.path.join("A1data-2021-07-16--16-29-44", "imu.bin") # lots of turns and some lifting 
file = os.path.join("A1data-2021-07-16--16-33-55", "imu.bin") # move around in the cage 
bag = DataPack(file, imu)


ang_bias = []
acc_bias = []
velocity = []
position = []
ang_velocity = []
acc = []
for m in bag:
	ang_velocity.append([m.gyroscope.x, m.gyroscope.y, m.gyroscope.z])
	acc.append([m.acceleration.x, m.acceleration.y, m.acceleration.z])
ang_velocity = np.array(ang_velocity)
acc = np.array(acc)
# plt.plot(velocity)
plt.plot(acc[:,1])
plt.show()