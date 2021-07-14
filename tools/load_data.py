import sys 
sys.path.append("..")
import pymessaging.message_pb2 as msg
import pdb

# Initialize message 
imu = msg.IMU_msg()
vicon = msg.Vicon_msg()

def read_messages(filename, proto_msg):
	f = open(filename, "rb")
	while True:
		first_msg_length = f.read(4)

		if len(first_msg_length) == 0:
			break

		first_msg_length = int.from_bytes(first_msg_length, "big")
		data = f.read(first_msg_length)
		proto_msg.ParseFromString(data)
		print(proto_msg)
		pdb.set_trace()
		# print(first_msg_length)
	
	f.close()


read_messages("imu.bin", imu)