import sys 
sys.path.append("..")
from pymessaging import messaging
import pymessaging.message_pb2 as msg
import zmq 
import pdb

def main():
#     # Creating subscribers and poller
    ctx = zmq.Context()
    imu_sub = messaging.create_sub(ctx, 5001)
    ekf_sub = messaging.create_sub(ctx, 5002)
    vicon_sub = messaging.create_sub(ctx,5000)

    poller = zmq.Poller()
    poller.register(imu_sub, zmq.POLLIN)    
    poller.register(ekf_sub, zmq.POLLIN)
    poller.register(vicon_sub, zmq.POLLIN)

    # Main loop for logging data 
    imu_f = open("imu.bin", "wb")
    vicon_f = open("vicon.bin", "wb")
    ekf_f = open("ekf.bin", "wb")
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

            

    except KeyboardInterrupt:
        imu_f.close()
        vicon_f.close()
        ekf_f.close()
        print("interrupted!")



if __name__ == "__main__":
	main()