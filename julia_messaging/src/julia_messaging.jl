module julia_messaging

using ProtoBuf 
using ZMQ 

ProtoBuf.protoc(`-I=../ --julia_out=. message.proto`);
include("../message_pb.jl")
include("messaging.jl")
export create_pub, create_sub

end # module
