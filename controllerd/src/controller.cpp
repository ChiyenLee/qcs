#include "unitree_legged_sdk/unitree_legged_sdk.h"
#include <math.h>
#include <zmq.hpp>
#include "message.pb.h"
#include "printf.h"

using namespace UNITREE_LEGGED_SDK;

class Controller 
{
public:
	Controller(uint8_t level) : udp(level) {
		context_ = zmq::context_t(1); 
		socket_ = zmq::socket_t(context_, ZMQ_PUB); 
		socket_.bind("tcp://*:5004");

		// allocate the message 
		imu_msg_ = messaging::IMU_msg(); 
		messaging::Vector3_msg* gyro; 
		messaging::Vector3_msg* accel;
		imu_msg_.set_allocated_acceleration(accel); 
		imu_msg_.set_allocated_gyroscope(gyro); 

	}

	void UDPRecv() {
		udp.Recv();
	}
	void UDPSend() {
		udp.Send();
	}
	void ZMQRecv(); 
	void ZMQSend();
	void RobotControl(); 

	// ZMQ 
	zmq::context_t context_; 
	zmq::socket_t socket_; 
	zmq::message_t z_msg_; 
	messaging::IMU_msg imu_msg_; 
	std::string msg_str_; 
	
	// Unitree 
	UDP udp;
	LowCmd cmd = {0};
	LowState state = {0};	
};

void Controller::ZMQSend() 
{
	// udp.GetRecv(state);
	messaging::Vector3_msg* acc(imu_msg_.mutable_acceleration());
	messaging::Vector3_msg* gyro(imu_msg_.mutable_gyroscope());
	gyro->set_x(state.imu.gyroscope[0]); 
	gyro->set_y(state.imu.gyroscope[1]);
	gyro->set_z(state.imu.gyroscope[2]);
	acc->set_x(state.imu.accelerometer[0]);
	acc->set_y(state.imu.accelerometer[1]);
	acc->set_z(state.imu.accelerometer[2]);

	imu_msg_.SerializeToString(&msg_str_);
	z_msg_.rebuild(msg_str_.size());
	memcpy((void *) z_msg_.data(), msg_str_.c_str(), msg_str_.size());
	socket_.send(z_msg_);
}


int main(void)
{
	Controller controller(LOWLEVEL);
	// LoopFunc loop_zmqSend("ZMQ_send", 0.002, 3, boost::bind(&Controller::ZMQSend, &controller));
	// printf("?? \n");
	return 0;
}