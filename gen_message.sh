protoc -I=. --python_out=pymessaging --cpp_out=vicond/proto message.proto
protoc -I=. --plugin=$HOME/.julia/packages/ProtoBuf/TYEdo/plugin/protoc-gen-julia --julia_out=julia_messaging message.proto 
