using Revise
using julia_messaging
using quadruped_control 
using LinearAlgebra
using julia_messaging: writeproto, ZMQ
using julia_messaging: ProtoBuf

function main()

    ################## Controller stuff ##########
    # Equilibrium pose 
    xf = [0.9250087650676135, 0.00820427564681016, -0.3797694610033162, -0.00816277516843245, 0.11172124479696591, -0.0008058608042655944, 0.44969568972519774, -0.011312524917513934, 0.00612999960696473, -0.026098431577256127, -0.026300826444390895, 0.29186645738457084, 0.3011565891540206, 0.8355314412321065, 0.8526119637361341, -0.916297857297, -0.916297857297, -0.9825729401405727, -0.9826692125518477, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    uf = [-0.5687407426035559, 0.6038632976405194, 3.0620134375539556, -3.1685288124879816, -0.5963893983544176, -0.5900199238480763, 8.903600886868457, 8.584255474441395, -0.2902253141866037, -0.28979532471656183, 9.52330678392854, 9.400048025157087]
    joint_pos_rgb = xf[8:20] # rigidbody indexing
    Kp = 5
    Kd = 5

    torques = zeros(12)
    torques[MotorIDs_c.FR_Calf] = 1.0

    ctx = ZMQ.Context(1)

    # Publisher 
    motor_state_pub = create_pub(ctx, 5004, "*")
    iob = PipeBuffer()
    motorR_msg = MotorReadings_msg()
    motor_position_msg = Motor_msg() # these are in C indices 
    motor_vel_msg = Motor_msg()
    motor_torque_msg = Motor_msg()
    motor_ddq_msg = Motor_msg()
    [setproperty!(motor_position_msg, field,0) for field in propertynames(motor_position_msg)]
    [setproperty!(motor_vel_msg, field,0) for field in propertynames(motor_vel_msg)]
    [setproperty!(motor_torque_msg, field,0) for field in propertynames(motor_torque_msg)]

    ################## EKF stuff  ############
	vicon = Vicon_msg()
	vicon_sub() = subscriber_thread(ctx,vicon,5000)
	vicon_thread = Task(vicon_sub)
	schedule(vicon_thread)

     # IMU readings 
    accel_imu = zeros(3);
    gyro_imu = zeros(3);

    # Timing 
    h = 0.005
    vicon_time = 0.0

    # Initialize EKF
    state = TrunkState(zeros(length(TrunkState))); state.qw = 1.0
    vicon_measurement = Vicon(zeros(length(Vicon))); vicon_measurement.qw = 1.0;
    input = ImuInput(zeros(length(ImuInput)))

    P = Matrix(1.0I(length(TrunkError))) * 1e10; 
    W = Matrix(1.0I(length(TrunkError))) * 1e-3;
    W[4:6, 4:6] .= I(3) * 1e-2 * h^2 
    W[end-5:end,end-5:end] = I(6)*1e2
    R = Matrix(1.0I(length(ViconError))) * 1e-3;
    ekf = ErrorStateFilter{TrunkState, TrunkError, ImuInput, Vicon, ViconError}(state, P, W, R) 

    # Publisher 
    ekf_pub = create_pub(ctx,5003, "*")
    imu_pub = create_pub(ctx,5002, "*")
    vicon_pub = create_pub(ctx,5001, "*")
    ekf_msg = EKF_msg()
    imu_msg = IMU_msg()
    vicon_msg = Vicon_msg()


    ############ Control loop ###########
    try
        while true 
            ################## EKF ########################
            A1Robot.getAcceleration(interface, accel_imu);
            A1Robot.getGyroscope(interface, gyro_imu); 

            # Prediction 
            input[1:3] .= copy(accel_imu)    
            input[4:end] .= copy(gyro_imu)
            prediction!(ekf, input, dt=h)

            # Update 
            if hasproperty(vicon, :quaternion)
               if vicon.time != vicon_time 
                    vicon_measurement[4:end] .= [vicon.quaternion.w, vicon.quaternion.x, vicon.quaternion.y, vicon.quaternion.z]
                    vicon_measurement[1:3] .= [vicon.position.x, vicon.position.y, vicon.position.z]
                    @time update!(ekf, vicon_measurement)
                    vicon_time = vicon.time

                    # Publishing 
                    # setproperty!(vicon_msg, :quaternion, Quaternion_msg(w=vicon_measurement[4], 
                    #             x=vicon_measurement[5], y=vicon_measurement[6], z=vicon_measurement[4]))
                    # setproperty!(vicon_msg, :position, Vector3_msg(x=vicon_measurement[1], y=vicon_measurement[2], z=vicon_measurement[3]))
                    # setproperty!(vicon_msg, :time, time())
                    # writeproto(iob, vicon_msg)
                    # ZMQ.send(vicon_pub,take!(iob))
               end  
            end

            ################ Controller #################
            joint_pos_c = mapMotorArrays(joint_pos_rgb, MotorIDs_rgb, MotorIDs_c)
            qs, dqs, ddqs, τs = A1Robot.getMotorReadings(interface) 

            # setting the values 
            A1Robot.setPositionCommands(interface, joint_pos_c, Kp, Kd)
            # A1Robot.setTorqueCommands(interface, torques)
            A1Robot.SendCommand(interface)
            
            ######## Controller  Publishing  ############
            [setproperty!(motor_position_msg, field, qs[i]) for (i, field) in enumerate(propertynames(motor_position_msg)[1:12])]
            setproperty!(motorR_msg, :q, motor_position_msg) 
            [setproperty!(motor_vel_msg, field, dqs[i]) for (i, field) in enumerate(propertynames(motor_vel_msg)[1:12])]
            setproperty!(motorR_msg, :dq, motor_vel_msg) 
            # [setproperty!(motor_torque_msg, field, τs[i]) for (i, field) in enumerate(propertynames(motor_torque_msg)[1:12])]
            # setproperty!(motorR_msg, :torques, motor_torque_msg) 
            writeproto(iob, motorR_msg)
            data = take!(iob)
            
            ######### EKF Publishing ##################
            # r, v, q, α, β = getComponents(ekf.est_state)
            # setproperty!(ekf_msg, :quaternion, Quaternion_msg(w=q[1],x=q[2], y=q[3], z=q[4]))
            # setproperty!(ekf_msg, :position, Vector3_msg(x=r[1], y=r[2], z=r[3]))
            # setproperty!(ekf_msg, :acceleration_bias, Vector3_msg(x=α[1], y=α[2], z=α[3]))
            # setproperty!(ekf_msg, :angular_velocity_bias, Vector3_msg(x=β[1], y=β[2], z=β[3]))
            # setproperty!(ekf_msg, :velocity, Vector3_msg(x=v[1], y=v[2], z=v[3]))
            # setproperty!(ekf_msg, :time, time())
            # writeproto(iob, ekf_msg)
			# ZMQ.send(ekf_pub,take!(iob))

            # setproperty!(imu_msg, :gyroscope, Vector3_msg(x=input[4],y=input[5], z=input[6]))
            # setproperty!(imu_msg, :acceleration, Vector3_msg(x=input[1], y=input[2], z=input[3]))
            # setproperty!(imu_msg, :time, time())
            # writeproto(iob, imu_msg)
            # ZMQ.send(imu_pub,take!(iob))
            
            
            try 
                ZMQ.send(motor_state_pub, data)
            catch e 
                if e isa ZMQ.StateError
                    # some times it closes randomly. Use this to keep it open
                    motor_state_pub = create_pub(ctx, 5055, "*")
                    rethrow(e)
                    break
                end 
            end 
            sleep(h)
        end 
    catch e
        close(ctx)
        if e isa InterruptException
        # cleanup
            println("control loop terminated by the user")
            close(motor_state_pub)
            close(imu_pub)
            close(ekf_pub)
            close(vicon_pub)
            Base.throwto(vicon_thread, InterruptException())
        else
            println(e)
            rethrow(e)
            # println("some other error")
        end
    end
end 

main()