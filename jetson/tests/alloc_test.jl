using Revise
using quadruped_control.StaticArrays
using julia_messaging 
using julia_messaging: ZMQ
include("../proto_utils.jl")

function test_alloc()
	test = @MVector zeros(10)
	test[1] = 1.0
	test[2] = 2.0
	test = SVector(test)
	return test
end 

# command = ["a"]
# @async while true command[1] = readline();  end

# while true 
# 	sleep(0.01)
# 	println(command)
# end 

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
	try 
		while true 
			println(command)
			sleep(0.1)
		end 
	catch e 
		# Base.throwto(command_thread, InterruptException())
		schedule(command_thread, ErrorException("stop"), error=true)
		schedule(ekf_thread, InterruptException(), error=true)
		println("terminated")
	end 
end 
main()