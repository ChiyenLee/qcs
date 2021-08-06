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
function subscriber_thread(ctx::ZMQ.Context, proto_msg::ProtoBuf.ProtoType, port_num::Int64, host="127.0.0.1")
    println(host)
    sub = create_sub(ctx, port_num, host) 
    # setproperty!(proto_msg, :time, 0.)
    try 
        println("waiting..")
        gc_interval = 100
        gc_counter = 0
        while true 
            bin_data = recv(sub)
            io = seek(convert(IOStream, bin_data),0)
            readproto(io, proto_msg)

            if gc_counter > gc_interval 
                GC.gc(false) # does incremental garbage collection 
                gc_counter = 0
            end
            gc_counter += 1

            # not sure if this is the right way to do it. 
            # readproto isn't allocation free, so instead of 
            # letting the allocation accumulate, we're just clearing it 
            # every step to avoid having it do gc in one single 
            # time consuming step

            # edit: ok that's messing up. If we run it every single 
            # time step, it will clog up the script and cause the 
            # queue to build up 

            # if we do a clean up everyone 100 cycle (100 is a sketchy
            # heuristic), then it seems to be a sweet middle ground between
            # speed and garbage collection 
        end 
    catch e 
        close(sub)
        GC.gc()
        if e isa InterruptException
            println("sub terminated by interruption")
        else
            rethrow(e)
        end 
    end 
end 

function publish(pub::ZMQ.Socket, proto_msg::ProtoBuf.ProtoType, iob::IOBuffer)
    msg_size = writeproto(iob, proto_msg)
    msg = Message(msg_size)
    msg[:] = iob.data[1:msg_size]
    send(pub, msg)
    seek(iob, 0)
    return nothing 
end 