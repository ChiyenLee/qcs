#include <ViconDriverZMQ.h>


bool ViconDriverZMQ::initialize() {
    context_ = zmq::context_t(1);
    socket_ = zmq::socket_t(context_, ZMQ_PUB);
    socket_.bind("tcp://127.0.0.1:5000");

    // allocate the message 
    vicon_ = messaging::Vicon_msg();  
    messaging::Vector3_msg* v;
    messaging::Quaternion_msg* q;
    vicon_.set_allocated_position(v);
    vicon_.set_allocated_quaternion(q);

    vicon_.SerializeToString(&msg_str_);	 
    msg_ = zmq::message_t(msg_str_.size());
    msg_.rebuild(msg_str_.size());
    socket_.send(msg_);
 
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
            messaging::Vector3_msg* pos(vicon_.mutable_position());
            messaging::Quaternion_msg* quat(vicon_.mutable_quaternion());

            pos->set_x(vicon_pose.pos[0]);
            pos->set_y(vicon_pose.pos[1]);
            pos->set_z(vicon_pose.pos[2]);

            quat->set_w(vicon_pose.quat[0]);
            quat->set_x(vicon_pose.quat[1]);
            quat->set_y(vicon_pose.quat[2]);
            quat->set_z(vicon_pose.quat[3]);
        }
    }
    vicon_.set_time(res.time);
    vicon_.SerializeToString(&msg_str_);
    msg_.rebuild(msg_str_.size());
    memcpy((void *) msg_.data(), msg_str_.c_str(), msg_str_.size());
    socket_.send(msg_);
}