import sys 
sys.path.append("..")
import pymessaging.message_pb2 as messaging
import pdb

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
vicon = messaging.Vicon_msg()
bag = DataPack("data.bin", imu)

i = 0
# for m in bag: