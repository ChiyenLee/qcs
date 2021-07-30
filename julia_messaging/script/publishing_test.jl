using Pkg 
Pkg.activate(".")
using ProtoBuf 
using julia_messaging
using julia_messaging.ZMQ
using Statistics

# Publishing example with protobuf and julia
function main()
	ctx = Context(1)
	pub = create_pub(ctx, 5003, "*")
	imu = IMU_msg() 
	v3 = Vector3_msg(x = 1, y = 2., z = 3.)
	iob = IOBuffer()

	try 
		# setproperty!(imu, :gyroscope, Vector3_msg(x=1., y=0., z=0.))
		# writeproto(iob, imu)
		# msg = Message(iob.size)
        # msg[:] = iob.data
		t = 0.001
		t_now = time()
		while true 
			@time begin 
				# writeproto(iob, imu)
				# msg = Message(iob.size)
				writeproto(iob, v3)
				msg = Message(iob.size)
        		msg[:] = @view iob.data[1:iob.size]
				ZMQ.send(pub, msg)
				seek(iob, 0)


				# while time() - t_now < t
				# 	nothing
				# end 

				# t_now = time()
				sleep(t)
				GC.gc(false)
			end 
		end 
	catch e 
		if e isa InterruptException 
			println("Process terminated by you")
			
		else 
			rethrow(e)
		end 
	finally 
		close(ctx)
		close(pub)
	end 
end 	

main()