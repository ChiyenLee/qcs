using julia_messaging
using quadruped_control

## Subscribing example with ZMQ and Protobuf 
function main()
	ctx = julia_messaging.ZMQ.Context(1)
	vicon = Vicon_msg()
	vicon_sub() = subscriber_thread(ctx,vicon,5000)
	vicon_thread = Task(vicon_sub)
	schedule(vicon_thread)

	vicon_time = 0.0
    try
        while true 
            if hasproperty(vicon, :time)
                println(vicon.quaternion.x)
            end
            sleep(0.01)
        end    
    catch e
        close(ctx)
        if e isa InterruptException
            # clean up 
            println("Process terminated by you")
            Base.throwto(vicon_thread, InterruptException())
        else 
            rethrow(e)
        end 
    end
end 

main()