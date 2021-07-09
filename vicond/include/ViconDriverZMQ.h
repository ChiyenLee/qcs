#include <simple_vicon/ViconDriver.h>

#include <thread>
#include <utility>
#include <vector>
#include <zmq.hpp>
#include "message.pb.h"
#include <stdio.h>
#include <vector>
#include <unistd.h>

class ViconDriverZMQ {
	public:
        bool initialize();
        void finalize();
        void vicon_callback(vicon_result_t res);

        zmq::context_t context_;
        zmq::socket_t socket_; 

    private: 
        void viconCallback(vicon_result_t vicon_result);
        ViconDriver driver_;
        std::thread vicon_thread_;
        messaging::Vicon_msg vicon_;
        std::string msg_str_;
        zmq::message_t msg_;

};