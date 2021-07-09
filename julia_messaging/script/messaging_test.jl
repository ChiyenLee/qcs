using Pkg
Pkg.activate(".")
using ZMQ 
using ProtoBuf
using julia_messaging

### Subscribing example with ZMQ and Protobuf 
function main()
    ctx = Context(1)
    imu = IMU_msg(); 
    imu_sub() = subscriber_thread(ctx,imu,5001)
    imu_thread = Task(imu_sub)
    schedule(imu_thread)
    try
        while true 
            if hasproperty(imu, :gyroscope)
                println(imu.gyroscope.x)
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