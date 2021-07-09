PROJECT(vicond)
CMAKE_MINIMUM_REQUIRED (VERSION 2.8.3)
# SET(CMAKE_CXX_FLAGS "-g -Wall -Werror -std=c++11")
set(CMAKE_CXX_STANDARD 17)


find_package(cppzmq REQUIRED)
find_package(Protobuf REQUIRED)

# add_subdirectory(extern/simple_vicon)
add_subdirectory(extern/simple_vicon/extern/vicon-datastream-sdk)
add_library(vicon_driver
  extern/simple_vicon/src/ViconDriver.cpp
)
target_include_directories(vicon_driver PUBLIC extern/simple_vicon/include ${catkin_INCLUDE_DIRS})
target_link_libraries(vicon_driver PUBLIC
  ViconDataStreamSDK_CPP
)

set(HEADERS proto/message.pb.h proto/message.pb.cc)

add_library(vicon_driver_zmq src/ViconDriverZMQ.cpp include/ViconDriverZMQ.h ${HEADERS})
target_include_directories(vicon_driver_zmq PUBLIC include proto)
target_link_libraries(vicon_driver_zmq PUBLIC vicon_driver)

add_executable(example src/server.cpp ${HEADERS})
target_include_directories(example PUBLIC ${PROTOBUF_INCLUDE_DIRS} proto)
target_link_libraries(example ${PROTOBUF_LIBRARIES} cppzmq vicon_driver_zmq)
