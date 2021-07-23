using Revise
using julia_messaging
using quadruped_control 
using LinearAlgebra
using julia_messaging: writeproto, ZMQ

function main()
    # Equilibrium pose 
    xf = [0.9250087650676135, 0.00820427564681016, -0.3797694610033162, -0.00816277516843245, 0.11172124479696591, -0.0008058608042655944, 0.44969568972519774, -0.011312524917513934, 0.00612999960696473, -0.026098431577256127, -0.026300826444390895, 0.29186645738457084, 0.3011565891540206, 0.8355314412321065, 0.8526119637361341, -0.916297857297, -0.916297857297, -0.9825729401405727, -0.9826692125518477, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    uf = [-0.5687407426035559, 0.6038632976405194, 3.0620134375539556, -3.1685288124879816, -0.5963893983544176, -0.5900199238480763, 8.903600886868457, 8.584255474441395, -0.2902253141866037, -0.28979532471656183, 9.52330678392854, 9.400048025157087]

    joint_pos_rgb = xf[8:20] # rigidbody indexing

    Kp = 100
    Kd = 5
    
    # Subscribe to ekf topic 
    ctx = julia_messaging.ZMQ.Context(1)
    ekf_msg = EKF_msg() 
    ekf_sub() = subscriber_thread(ctx, ekf_msg, 5003)
    ekf_thread= Task(vicon_sub)
    schedule(ekf_thread)

    # Publisher 
    motor_state_pub = create_pub(ctx, 5004, "*")
    iob = PipeBuffer()
    motorR_msg = MotorReadings_msg()
    motor_msg = Motor_msg() # these are in C indices 
    [setproperty!(motor_msg, field,0) for field in propertynames(motor_msg)]

    # timing  
    h = 0.005

    # Control loop 

    try
        while true 
            joint_pos_c = mapMotorArrays(joint_pos_rgb, MotorIDs_rgb, MotorIDs_c)
            qs, dqs, ddqs, τs = A1Robot.getMotorReadings(interface) 

            # setting the values 
            # A1Robot.setPositionCommands(interface, joint_pos_c, Kp, Kd)
            # A1Robot.SendCommand(interface)

            # Publishing 
            [setproperty!(motor_msg, field, qs[i+1]) for (i, field) in propertynames(motor_msg) ]
            setproperty!(motorR_msg, :q, motor_msg) 
            [setproperty!(motor_msg, field, dqs[i+1]) for (i, field) in propertynames(motor_msg) ]
            setproperty!(motorR_msg, :dq, motor_msg) 
            [setproperty!(motor_msg, field, ddqs[i+1]) for (i, field) in propertynames(motor_msg) ]  
            setproperty!(motorR_msg, :ddq, motor_msg) 
            [setproperty!(motor_msg, field, torques[i+1]) for (i, field) in propertynames(motor_msg) ]
            setproperty!(motorR_msg, :torques, motor_msg) 
            writeproto!(iob, motorR_msg)
            ZMQ.send(motor_state_pub, take!(iob))

            sleep(h)
        end 
    catch e
        if e isa InterruptException
        # cleanup
        println("control loop terminated by the user")
        #    rethrow(e)
        else
            println(e)
            rethrow(e)
            # println("some other error")
        end
    end
end 

main()