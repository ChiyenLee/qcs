## This noddoublee drive the motor, listen for commands, and publish IMU + motor data 
# using Pkg 
# Pkg.activate(".")
using Revise
using quadruped_control
using julia_messaging
using julia_messaging: ZMQ
using StaticArrays
include("jetson/proto_utils.jl")

# interface = A1Robot.RobotInterface() 
# A1Robot.InitSend(interface)

function main() 
	ctx = ZMQ.Context(1)	
	# Publisher 
	imu_pub = create_pub(ctx,  5002, "*")
	motor_pub = create_pub(ctx, 5004, "*")
	imu_msg = init_imu_msg()
	motorReadings_msg = init_motor_readings()

	# preallocate 
	accel_imu = zeros(3);
	gyro_imu = zeros(3);
	iob = IOBuffer()

	# Subscriber for motor commands  
	motorCmds_msg = init_motor_commands()
	motorCmds_sub() = subscriber_thread(ctx, motorCmds_msg,5005)
	motorCmds_thread = Task(motorCmds_sub)
	schedule(motorCmds_thread)
	qs = zeros(12)
	dqs = zeros(12)
	τs = zeros(12)

	h = 0.002
	try 
		while true 
			############### Reading data for pubslihing ##############
			# IMU publishing
			# A1Robot.getAcceleration(interface, accel_imu);
			# A1Robot.getGyroscope(interface, gyro_imu);
			accel_imu[:] = randn(3)
			imu_msg.gyroscope.x, imu_msg.gyroscope.y, imu_msg.gyroscope.z = gyro_imu
			imu_msg.acceleration.x, imu_msg.acceleration.y, imu_msg.acceleration.z = accel_imu
			imu_msg.time = time()
			publish(imu_pub, imu_msg, iob)

			# motor publishing 
			# qs, dqs, τs =  A1Robot.getMotorReadings(interface)
			for (i, field) in enumerate(propertynames(motorReadings_msg.positions)[1:12])
				setproperty!(motorReadings_msg.positions, field, qs[i]) 
				setproperty!(motorReadings_msg.velocities, field, dqs[i])
				setproperty!(motorReadings_msg.torques, field, τs[i] )
			end 
			motorReadings_msg.time = time()
			publish(motor_pub, motorReadings_msg, iob) 

			############### Controlling the motors #################### 
			for (i, motor) in enumerate(propertynames(motorCmds_msg)[1:12])
				m = getproperty(motorCmds_msg, motor)
				# A1Robot.setMotorCmd(interface, i-1, m.pos, m.vel, m.Kp, m.Kd, m.tau)
			end 

			# Make sure the robot have the latest command. If not, just drop
			recieve_time = getproperty(motorCmds_msg, :time)
			if time() - recieve_time >= 0.05
				println("time out!")
					# A1Robot.setPositionCommands(interface, SVector{12}(zeros(12)), 0, 0)
			end 
			# println(recieve_time)
			# A1Robot.SendCommand(interface)

			sleep(0.002)
			GC.gc(false)
		end
	catch e  
		close(imu_pub)
		close(motor_pub)
		close(ctx)
		# Base.throwto(motorCmds_thread, InterruptException)
		schedule(motorCmds_thread, InterruptException(), error=true)
		if e isa InterruptException
            println("control loop terminated by the user")
        else
            rethrow(e)
        end 
	end 


end 

main()