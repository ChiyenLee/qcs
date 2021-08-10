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
bag_name = "A1data-2021-08-09--17-00-04"
files = os.listdir(bag_name)
msg_dict = {}

for f in files: 
    msg_name = f.split(".")[0] # automate this and actually use the message name 
    msg_class = getattr(messaging, msg_name)
    msg_dict[msg_name] = DataPack(f, msg_class())

error_bag = msg_dict["ErrorMsg"]
cmd_bsg = msg_dict["MotorCmds_msg"]
errors = []

# load 
# for m in bag: 
    # for i, descriptor in enumerate(m.DESCRIPTOR.fields[:12]): 
#         # print(descriptor.name)
#         # pos[i] = getattr(m.q, descriptor.name)
#         # vel[i] = getattr(m.dq, descriptor.name)
#         torques[i] = getattr(m, descriptor.name).tau
#     # motor_pos.append(np.copy(pos))
#     # motor_v.append(np.copy(vel))
#     motor_torques.append(np.copy(torques))
