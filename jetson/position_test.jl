using Revise
using julia_messaging
using quadruped_control 
using LinearAlgebra
using julia_messaging: writeproto, ZMQ
using julia_messaging: ProtoBuf
using EKF 
include("../EKF.jl/test/imu_grav_comp/imu_dynamics_discrete.jl")
include("proto_utils.jl")

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
    motor_state_pub = create_pub(ctx, 5004, "*")
    ekf_msg = init_ekf_msg()
    imu_msg = init_imu_msg()
    vicon_msg = init_vicon_msg()
    iob = IOBuffer()


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
                    vicon_msg.quaternion.w, vicon_msg.quatenrion.x, vicon_msg.quaternion.y, vicon_msg.quaternion.z = vicon_measurement[4:end]
                    vicon_msg.position.x, vicon_msg.position.y, vicon_msg.position.z = vicon_measurement[1:3]
                    vicon_msg.time = time()

                    publish(vicon_pub, vicon_msg, iob)
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
            for (i, field) in enumerate(propertynames(motorR_msg.q))
                setproperty!(motorR_msg.q, field, qs[i]) 
                setproperty!(motorR_msg.dq, field, dqs[i])
                setproperty!(motorR_msg.torques, field, τs[i] )
            end 
            publish(motor_state_pub, motorR_msg, iob) 

            ######### EKF Publishing ##################
            r, v, q, α, β = getComponents(ekf.est_state)
            ekf_msg.quaternion.w, ekf_msg.quaternion.x, ekf_msg.quaternion.y, ekf_msg.quaternion.z = q
            ekf_msg.position.x, ekf_msg.position.y, ekf_msg.position.z = r 
            ekf_msg.acceleration_bias.x, ekf_msg.acceleration_bias.y, ekf_msg.acceleration_bias.z = α
            ekf_msg.angular_velocity_bias.x, ekf_msg.angular_velocity_bias.y, ekf_msg.angular_velocity_bias.z = β
            ekf_msg.velocity.x, ekf_msg.velocity.y, ekf_msg.velocity.z = v 
            ekf_msg.time = time()
            publish(ekf_pub, ekf_msg, iob)            

            imu_msg.gyroscope.x, imu_msg.gyroscope.y, imu_msg.gyroscope.z = input[4:6]
            imu_msg.acceleration.x, imu_msg.acceleration.y, imu_msg.acceleration.z = input[1:3]
            imu_msg.time = time()
            publish(imu_pub, imu_msg, iob)
            
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

            GC.gc(false) # collect garbage 
        end 
    catch e
        if e isa InterruptException
        # cleanup
            println("control loop terminated by the user")
            Base.throwto(vicon_thread, InterruptException())
        else
            println(e)
            rethrow(e)
            # println("some other error")
        end
    finally 
        close(ctx)
        close(imu_pub)
        close(ekf_pub)
        close(vicon_pub)
        close(motor_state_pub)
    end
end 

main()