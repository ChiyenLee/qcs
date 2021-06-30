using Pkg
Pkg.activate(".")
using ZMQ 
using ProtoBuf
using julia_messaging

""" subscriber 
subcriber thread that updates a protobuf message in a thread
"""
function subscriber(ctx, proto_msg, port_num)
    sub = create_sub(ctx, port_num) 
    try 
        println("waiting..")
        while true 
            bin_data = recv(sub)
            io = seek(convert(IOStream, bin_data),0)
            data = readproto(io, IMU())
            for n in propertynames(proto_msg)
                setproperty!(proto_msg, n, getproperty(data,n))
            end
        end 
    catch e 
        close(sub)
        println(stacktrace())
        println(e)
    end 
end 

### Subscribing example with ZMQ and Protobuf 
function main()
    ctx = Context(1)
    imu = IMU(); 
    imu_sub() = subscriber(ctx,imu,5001)
    imu_thread = Task(imu_sub)
    schedule(imu_thread)
    try
        while true 
            if hasproperty(imu, :quaternion)
                println(imu.quaternion)
            end
            sleep(0.01)
        end    
    catch e
        close(ctx)
        if e isa InterruptException
            # clean up 
            println("Process terminated by you")
            Base.throwto(imu_thread, InterruptException())
        else 
            rethrow(e)
        end 
    end
end 

main()