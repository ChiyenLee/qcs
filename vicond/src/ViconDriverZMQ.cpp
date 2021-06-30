#include <ViconDriverZMQ.h>


bool ViconDriverZMQ::initialize() {
    context_ = zmq::context_t(1);
    socket_ = zmq::socket_t(context_, ZMQ_PUB);
    socket_.bind("tcp://127.0.0.1:5000");

    vicon_ = messaging::VICON();
    std::vector<double> vicon_quat(4,0);
    std::vector<double> vicon_pos(3,0);
    *vicon_.mutable_quaternion() = {vicon_quat.begin(), vicon_quat.end()};
    *vicon_.mutable_position() = {vicon_pos.begin(), vicon_pos.end()};
      
    vicon_.SerializeToString(&msg_str_);	 
    msg_ = zmq::message_t(msg_str_.size());
    socket_.send(msg_);
    msg_.rebuild(msg_str_.size());
 
    vicon_driver_params_t params;
    params.server_ip = "192.168.3.249";
    params.stream_mode = ViconSDK::StreamMode::ServerPush;
    if (!driver_.init(params, std::bind(&ViconDriverZMQ::vicon_callback, this, std::placeholders::_1))) {
        printf("failed");
        return false;
    }

    vicon_thread_ = std::thread(&ViconDriver::run_loop, &driver_);
    vicon_thread_.join();
    return true;
}

void ViconDriverZMQ::finalize() {
    driver_.stop();
    vicon_thread_.join();
    socket_.close();
}

void ViconDriverZMQ::vicon_callback(vicon_result_t res) {
    for (const auto& vicon_pose : res.data) {
        if (vicon_pose.subject == "UnitreeA1") {
            vicon_.set_quaternion(0, vicon_pose.quat[0]);
            vicon_.set_quaternion(1, vicon_pose.quat[1]);
            vicon_.set_quaternion(2, vicon_pose.quat[2]);
            vicon_.set_quaternion(3, vicon_pose.quat[3]);
            
            vicon_.set_position(0, vicon_pose.pos[0]);
            vicon_.set_position(1, vicon_pose.pos[1]);
            vicon_.set_position(2, vicon_pose.pos[2]);
        }
    }
    vicon_.set_time(res.time);
    vicon_.SerializeToString(&msg_str_);
    memcpy((void *) msg_.data(), msg_str_.c_str(), msg_str_.size());
    socket_.send(msg_);
    printf("%d \n", msg_str_.size());
    msg_.rebuild(msg_str_.size());
}