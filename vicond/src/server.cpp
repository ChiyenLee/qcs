#include <zmq.hpp>
#include <stdio.h>
#include "message.pb.h"
#include <vector>
#include <unistd.h>
#include <thread>
#include <csignal>
#include <simple_vicon/ViconDriver.h>
#include <ViconDriverZMQ.h>
using namespace std;

ViconDriverZMQ viconZMQ;
void signal_handler(int signal) { 
    viconZMQ.finalize();
}

int main()
{
    if (!viconZMQ.initialize()) {
        std::cerr << "Failed to init driver" << std::endl;
    }
    std::signal(SIGINT, signal_handler);
    std::signal(SIGTERM, signal_handler);
    std::signal(SIGHUP, signal_handler);
}

