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
motor_msg = messaging.MotorReadings_msg()

# file = os.path.join("A1data-2021-07-16--16-29-44", "imu.bin") # lots of turns and some lifting 
# file = os.path.join("A1data-2021-07-16--16-22-05", "vicon.bin") # move around in the cage 
# file = os.path.join("A1data-2021-07-21--14-00-18", "ekf.bin")
file = os.path.join("A1data-2021-07-26--10-54-48", "motor_state.bin")
# bag = DataPack(file, vicon)
# bag = DataPack(file, ekf)
bag = DataPack(file, motor_msg)


ang_bias = []
acc_bias = []
velocity = []
position = []
ang_velocity = []
acc = []
motor_pos = []
for m in bag:
	# ang_velocity.append([m.gyroscope.x, m.gyroscope.y, m.gyroscope.z])
	# acc.append([m.acceleration.x, m.acceleration.y, m.acceleration.z])
	# position.append([m.position.x, m.position.y, m.position.z])
	# velocity.append([m.velocity.x, m.velocity.y, m.velocity.z])
	motor_pos.append([m.q.FR_Hip, m.q.FR_Thigh])
ang_velocity = np.array(ang_velocity)
acc = np.array(acc)
position = np.array(position)
velocity = np.array(velocity)
# plt.plot(velocity[2000:4000,2])
# plt.plot(velocity[:,1])
# plt.plot(position[:2000,2], label="position")
# plt.plot(velocity[:2000,2], label="velocity")

plt.plot(position[:,2], label="position")
plt.plot(velocity[:,2], label="velocity")
plt.legend()
plt.show()


print(np.var(velocity[:2000,2]))