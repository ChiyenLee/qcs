PROJECT(controllerd)
CMAKE_MINIMUM_REQUIRED (VERSION 2.8.3)

add_compile_options(-std=c++11)

find_package(cppzmq REQUIRED)
find_package(Protobuf REQUIRED)
find_package(Boost REQUIRED)
include_directories(
    ${Boost_INCLUDE_DIR}    
    $ENV{UNITREE_SDK_PATH}/include
)

set(EXTRA_LIBS -pthread libunitree_legged_sdk_amd64.so cppzmq ${PROTOBUF_LIBRARIES} lcm)
set(HEADERS proto/message.pb.h proto/message.pb.cc)

link_directories($ENV{UNITREE_SDK_PATH}/lib)
add_executable(controller src/controller.cpp ${HEADERS})
target_include_directories(controller PUBLIC proto)
target_link_libraries(controller ${EXTRA_LIBS} lcm)