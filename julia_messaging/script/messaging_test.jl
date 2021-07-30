using Pkg
# Pkg.activate(".")
# using ZMQ 
using Revise
using ProtoBuf
using julia_messaging
using julia_messaging.ZMQ

### Subscribing example with ZMQ and Protobuf 
function main()
    ctx = Context(1)
    imu = IMU_msg(); 
    v3 = Vector3_msg();

    v3_sub() = subscriber_thread(ctx,v3,5003)
    v3_thread = Task(v3_sub)
    schedule(v3_thread)

    try
        while true 
            # if hasproperty(imu, :gyroscope)
            #     println(imu.gyroscope.x)
            # end
            # println(v3)
            sleep(0.01)
        end    
    catch e
        if e isa InterruptException
            # clean up 
            println("Process terminated by you")
            Base.throwto(imu_thread, InterruptException())
        else 
            rethrow(e)
        end 
    finally 
        close(ctx)
        close(sub)
    end
end 

main()