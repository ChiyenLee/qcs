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
motor_msg = messaging.MotorReadings_msg()

file = os.path.join("A1data-2021-07-27--17-23-25", "motor_state.bin")
bag = DataPack(file, motor_msg)

motor_pos = []
motor_v = []
motor_torques = []

pos = np.zeros(12)
vel = np.zeros(12)
torques = np.zeros(12)
for m in bag:
    for i, descriptor in enumerate(m.q.DESCRIPTOR.fields[:12]):
        
        pos[i] = getattr(m.q, descriptor.name)
        vel[i] = getattr(m.dq, descriptor.name)
        torques[i] = getattr(m.torques, descriptor.name)
    motor_pos.append(np.copy(pos))
    motor_v.append(np.copy(vel))
    motor_torques.append(np.copy(torques))

# pdb.set_trace()
qs = np.array(motor_pos)
dqs = np.array(motor_v)
taus = np.array(motor_torques)
# plt.plot(qs)
plt.plot(qs)
# plt.plot(dqs[:,0])
# plt.legend()
plt.show()

# pdb.set_trace()