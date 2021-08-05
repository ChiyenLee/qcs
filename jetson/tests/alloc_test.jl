using Revise
using quadruped_control.StaticArrays
using julia_messaging 
using julia_messaging: ZMQ
include("../proto_utils.jl")

function main() 
	command = ["position"]
    command_reader() = while true command[1] = readline() end 
    command_thread = Task(command_reader)
    schedule(command_thread)

	ctx = ZMQ.Context(1)
	ekf_msg = init_ekf_msg()
    ekf_sub() = subscriber_thread(ctx, ekf_msg, 5003)
    ekf_thread = Task(ekf_sub)
    schedule(ekf_thread)

	vicon_msg = init_vicon_msg() 
	vicon_sub() = subscriber_thread(ctx, vicon_msg, 5000)
	vicon_thread = Task(vicon_sub)
	schedule(vicon_thread)

	try 
		while true 
			# println(vicon_msg.quaternion.y)
			sleep(0.002)
		end 
	catch e 
		# Base.throwto(command_thread, InterruptException())
		schedule(command_thread, ErrorException("stop"), error=true)
		schedule(ekf_thread, InterruptException(), error=true)
		println("terminated")
	end 
end 
main()