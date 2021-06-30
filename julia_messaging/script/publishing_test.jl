using Pkg 
Pkg.activate(".")
using ZMQ
using ProtoBuf 
using julia_messaging 
using Statistics

# Publishing example with protobuf and julia
function main()
	ctx = Context(1)
	pub = create_pub(ctx, 5002)
	imu = IMU(quaternion=zeros(4)) 
	iob = PipeBuffer()
	try 
		while true 
			writeproto(iob, imu)
			setproperty!(imu, :quaternion, randn(4) )
			ZMQ.send(pub,take!(iob))
			println(length(iob.data))

			sleep(0.1)
		end 
	catch e 
		close(ctx)
		if e isa InterruptException 
			println("Process terminated by you")
			
		else 
			rethrow(e)
		end 
	end 
end 	

main()