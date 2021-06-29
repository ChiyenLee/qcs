using Pkg
Pkg.activate(".")
using ZMQ 
using ProtoBuf
using julia_messaging

function get_message()
    ctx = ZMQ.Context() 
    sub = create_sub(ctx, 5000)
    
    
    try 
        while true 
            data = recv(sub)
            io = convert(IOStream, data)
            data= readproto(io, IMU())
            println(data.rpy)
        end 
    catch e 
        println(stacktrace())
        println(e)
    end 
end 

t = Task(get_message)
schedule(t)
try
    while true 
        sleep(1)
    end    
catch e
    if e isa InterruptException
        # clean up 
        println("Process terminated by you")
        Base.throwto(t, InterruptException())
    else 
        rethrow(e)
    end 
end