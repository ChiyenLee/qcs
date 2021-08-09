## This noddoublee drive the motor, listen for commands, and publish IMU + motor data 
# using Pkg 
# Pkg.activate(".")

# using DaemonMode 
# using Pkg 
# Pkg.activate(".")

using Revise
using quadruped_control
using julia_messaging
using julia_messaging: ZMQ
using StaticArrays
include("proto_utils.jl")

# interface = A1Robot.RobotInterface() 
# A1Robot.InitSend(interface)
# COMMAND = ["1"]

function main() 
	ctx = ZMQ.Context(1)	
	# Publisher 
	imu_pub = create_pub(ctx,  5002, "*")
	motor_pub = create_pub(ctx, 5004, "*")
	imu_msg = init_imu_msg()
	motorRead_msg = init_motor_readings()

	# preallocate 
	accel_imu = zeros(3);
	gyro_imu = zeros(3);
	iob = IOBuffer()

	# Subscriber for motor commands  
	motorCmd_msg = init_motor_commands()
	motorCmd_sub() = subscriber_thread(ctx, motorCmd_msg,5005)
	motorCmds_thread = Task(motorCmd_sub)
	schedule(motorCmds_thread)

	command = ["run"]
    command_reader() = while true command[1] = readline() end 
    command_thread = Task(command_reader)
    schedule(command_thread)
    

	# Control timeout 
	controlTimeout = false 
	posStopF = 2.146e9
	h = 0.008
	t = time()
	try 
		while true 
			############### Reading data for pubslihing ##############
			# IMU publishing
			A1Robot.getAcceleration(Main.interface, accel_imu);
			A1Robot.getGyroscope(Main.interface, gyro_imu);
			imu_msg.gyroscope.x, imu_msg.gyroscope.y, imu_msg.gyroscope.z = gyro_imu
			imu_msg.acceleration.x, imu_msg.acceleration.y, imu_msg.acceleration.z = accel_imu
			imu_msg.time = time()
			publish(imu_pub, imu_msg, iob)

			# motor publishing 
			qs, dqs, τs =  A1Robot.getMotorReadings(Main.interface)
			for (i, field) in enumerate(propertynames(motorRead_msg.positions)[1:12])
				setproperty!(motorRead_msg.positions, field, qs[i]) 
				setproperty!(motorRead_msg.velocities, field, dqs[i])
				setproperty!(motorRead_msg.torques, field, τs[i] )
			end 
			motorRead_msg.time = time()
			publish(motor_pub, motorRead_msg, iob) 

			############### Controlling the motors #################### 
			for (i, motor) in enumerate(propertynames(motorCmd_msg)[1:12])
				m = getproperty(motorCmd_msg, motor)
				A1Robot.setMotorCmd(Main.interface, i-1, m.pos, m.vel, m.Kp, m.Kd, m.tau)
			end 

			# Make sure the robot have the latest command. If not, just drop
			recieve_time = getproperty(motorCmd_msg, :time)
			if time() - recieve_time >= 0.1
				if controlTimeout == false 
					println("control time out! ")
				end 
				controlTimeout = true 
				A1Robot.setPositionCommands(Main.interface, SVector{12}(ones(12) * posStopF), 0, 5) # pure damping 
			else 
				if controlTimeout == true 
					println("starting control!")
				end 
				controlTimeout = false 
			end 
			
			
			if command[1] != "reset"
				A1Robot.SendCommand(interface)
			end

			# if Main.COMMAND[1] == "kill interface"
			# 	Main.COMMAND[1] = "waiting"
			# 	throw(InterruptException())
			# end 
			# println(1/(time() - t))
			# t = time() 
			sleep(0.008)

			# GC.gc(false)
		end
	catch e  
		close(imu_pub)
		close(motor_pub)
		close(ctx)
		# Base.throwto(motorCmds_thread, InterruptException)
		        schedule(command_thread, ErrorException("stop"), error=true)
		schedule(motorCmds_thread, InterruptException(), error=true)
		if e isa InterruptException
            println("control loop terminated by the user")
        else
            rethrow(e)
        end 
	end 


end 

main()