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
# bag_name = "A1data-2021-08-10--15-30-01"
bag_name = sys.argv[1]
files = os.listdir(bag_name)
msg_dict = {}

for f in files: 
    msg_name = f.split(".")[0] # automate this and actually use the message name
    print(msg_name) 
    msg_class = getattr(messaging, msg_name)
    msg_dict[msg_name] = DataPack(os.path.join(bag_name,f), msg_class())

error_bag = msg_dict["ErrorMsg"]
cmd_bag = msg_dict["MotorCmds_msg"]
motor_state_bag = msg_dict["MotorReadings_msg"]

#################### Error ########################
state_errors = []
for m in error_bag: 
    err = np.zeros(36)
    err[:3] = m.orientation.x, m.orientation.y, m.orientation.z
    err[3:6] = m.position.x, m.position.y, m.position.z

    # load motor errors
    for i, descriptor in enumerate(m.motor_pos.DESCRIPTOR.fields[:11]):
        err[6+i] = getattr(m.motor_pos, descriptor.name)
        err[18+i] = getattr(m.motor_pos, descriptor.name)
    state_errors.append(err)
state_errors = np.array(state_errors)

##################### Command ############################
commands = []
for m in cmd_bag:
    command = np.zeros(12)
    for i, descriptor in enumerate(m.DESCRIPTOR.fields[:11]):
        motor = getattr(m, descriptor.name) 
        command[i] = motor.tau
    commands.append(command)
commands = np.array(commands)

###################### motor states #######################

torques = []
for m in motor_state_bag:
    torque = np.zeros(12)
    # print(m.time)
    for i, descriptor in enumerate(m.torques.DESCRIPTOR.fields[:12]):
        torque[i] = getattr(m.torques, descriptor.name) 
        # print(i, " ", descriptor.name)
    torques.append(torque)
torques = np.array(torques)

# plt.plot(torques[:,8])
# plt.plot(torques[:,11])


plt.plot(state_errors)
# plt.plot(commands)

plt.show()
