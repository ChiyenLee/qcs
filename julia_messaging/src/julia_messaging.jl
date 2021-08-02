module julia_messaging

using ProtoBuf 
using ZMQ 

# ProtoBuf.protoc(`-I=../ --julia_out=. message.proto`);
dir_path = @__DIR__
ProtoBuf.protoc(`-I=$dir_path/../../ --julia_out=. message.proto`);
include("../message_pb.jl")
include("messaging.jl")
export create_pub, create_sub, subscriber_thread, publish

end # module
