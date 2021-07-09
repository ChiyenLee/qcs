function create_sub(ctx, portname, host="127.0.0.1")
    s = Socket(ctx, SUB)
    ZMQ.subscribe(s)
    ZMQ.connect(s, "tcp://$host:$portname")
    return s 
end 

function create_pub(ctx, portname, host="127.0.0.1")
    p = Socket(ctx, PUB)
    ZMQ.bind(p, "tcp://$host:$portname")
    return p 
end

""" subscriber 
subcriber thread that updates a protobuf message in a thread
"""
function subscriber_thread(ctx::ZMQ.Context, proto_msg::ProtoBuf.ProtoType, port_num::Int64)
    sub = create_sub(ctx, port_num) 

    setproperty!(proto_msg, :time, 0.)
    try 
        println("waiting..")
        while true 
            bin_data = recv(sub)
            io = seek(convert(IOStream, bin_data),0)
            data = readproto(io, proto_msg)
            for n in propertynames(proto_msg)
                if hasproperty(proto_msg,n)
                    setproperty!(proto_msg, n, getproperty(data,n))
                end
            end
        end 
    catch e 
        close(sub)
        println(stacktrace())
        println(e)
    end 
end 

