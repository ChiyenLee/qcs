import sys 
sys.path.append("..")
from pymessaging import messaging
import pymessaging.message_pb2 as msg
import zmq 
import pdb
import os 
from datetime import datetime

def main():
#     # Creating subscribers and poller
    ctx = zmq.Context()

    vicon_sub = messaging.create_sub(ctx, "5001", host="192.168.3.123")
    imu_sub = messaging.create_sub(ctx, "5002", host="192.168.3.123")
    ekf_sub = messaging.create_sub(ctx, "5003", host="192.168.3.123")
    motor_state_sub = messaging.create_sub(ctx, "5004", host="192.168.3.123")
    motor_cmd_sub = messaging.create_sub(ctx, "5005", host="192.168.3.123")
    error_sub = messaging.create_sub(ctx,"5006", host="192.168.3.123")

    poller = zmq.Poller()
    poller.register(imu_sub, zmq.POLLIN)    
    poller.register(ekf_sub, zmq.POLLIN)
    poller.register(vicon_sub, zmq.POLLIN)
    poller.register(motor_state_sub, zmq.POLLIN)
    poller.register(motor_cmd_sub, zmq.POLLIN)
    poller.register(error_sub, zmq.POLLIN)


    # Main loop for logging data 
    now = datetime.now()
    foldername = now.strftime("A1data-%Y-%m-%d--%H-%M-%S")
    os.mkdir(foldername)
    imu_f = open(os.path.join(foldername,"IMU_msg.bin"), "wb")
    ekf_f = open(os.path.join(foldername,"EKF_msg.bin"), "wb")
    vicon_f = open(os.path.join(foldername,"Vicon_msg.bin"), "wb")
    motor_state_f = open(os.path.join(foldername, "MotorReadings_msg.bin"), "wb")
    motor_cmd_f = open(os.path.join(foldername, "MotorCmds_msg.bin"), "wb")
    error_f = open(os.path.join(foldername, "ErrorMsg.bin"), "wb")
    

    try:
        while True: 
            socks = dict(poller.poll(0.01))

            if imu_sub in socks.keys() and socks[imu_sub] == zmq.POLLIN:
                # non blocking 
                data = imu_sub.recv(zmq.DONTWAIT)
                msg_size = len(data)
                msg_size_b = (msg_size).to_bytes(4, byteorder="big")
                imu_f.write(msg_size_b + data)
            
            if ekf_sub in socks.keys() and socks[ekf_sub] == zmq.POLLIN: 
                data = ekf_sub.recv(zmq.DONTWAIT)
                msg_size = len(data)
                msg_size_b = (msg_size).to_bytes(4, byteorder="big")
                ekf_f.write(msg_size_b + data)

            if vicon_sub in socks.keys() and socks[vicon_sub] == zmq.POLLIN: 
                data = vicon_sub.recv(zmq.DONTWAIT)
                msg_size = len(data)
                msg_size_b = (msg_size).to_bytes(4, byteorder="big")
                vicon_f.write(msg_size_b + data)
            
            if motor_state_sub in socks.keys() and socks[motor_state_sub] == zmq.POLLIN: 
                data = motor_state_sub.recv(zmq.DONTWAIT)
                msg_size = len(data)
                msg_size_b = (msg_size).to_bytes(4, byteorder="big")
                motor_state_f.write(msg_size_b + data)

            if motor_cmd_sub in socks.keys() and socks[motor_cmd_sub] == zmq.POLLIN: 
                data = motor_cmd_sub.recv(zmq.DONTWAIT)
                msg_size = len(data)
                msg_size_b = (msg_size).to_bytes(4, byteorder="big")
                motor_cmd_f.write(msg_size_b + data)

            if error_sub in socks.keys() and socks[error_sub] == zmq.POLLIN: 
                data = error_sub.recv(zmq.DONTWAIT)
                msg_size = len(data)
                msg_size_b = (msg_size).to_bytes(4, byteorder="big")
                motor_cmd_f.write(msg_size_b + data)
            

    except KeyboardInterrupt:
        imu_f.close()
        vicon_f.close()
        ekf_f.close()
        motor_state_f.close() 
        motor_cmd_f.close()
        error_f.close()

        print("interrupted!")



if __name__ == "__main__":
	main()