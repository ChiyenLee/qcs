using Pkg 
Pkg.activate(".")
using Revise
using StaticArrays
using quadruped_control
using quadruped_control: UnitQuaternion, rotation_error, CayleyMap
using quadruped_control: JLD
using julia_messaging 
using julia_messaging: ZMQ
using Logging

include("proto_utils.jl")
function setPositionCmds!(cmds_msg::MotorCmds_msg, pos::AbstractVector, Kp::Real, Kd::Real)
	for (i,motor) in enumerate(fieldnames(MotorIDs))
		m = getproperty(cmds_msg, motor)
		m.Kp = Kp 
		m.Kd = Kd 
		m.pos = pos[i]
		m.tau = 0.0
        m.vel = 0.0
	end 
end 

function setTorqueCmds!(cmds_msg::MotorCmds_msg, torques::AbstractVector)
    posStopF = 2.146e9
    velStopF = 16000.0e0
    for (i, motor) in enumerate(fieldnames(MotorIDs))
    	    m = getproperty(cmds_msg, motor)
    	    m.Kp = 0.0 
    	    m.Kd = 0.0
    	    m.pos = posStopF 
    	    m.vel = velStopF 
    	    m.tau = torques[i]
    	end 
end 	
	
function getMotorReadings(motorR_msg::MotorReadings_msg)
    vs = SVector{12}([getproperty(motorR_msg.velocities, motor) for motor in fieldnames(MotorIDs)]) # MotorIDs is exported from quadruped control
    qs = SVector{12}([getproperty(motorR_msg.positions, motor) for motor in fieldnames(MotorIDs)]) # MotorIDs is exported from quadruped control
    τs = SVector{12}([getproperty(motorR_msg.torques, motor) for motor in fieldnames(MotorIDs)]) # MotorIDs is exported from quadruped control
    return qs, vs, τs
end 

function main()
    ################## Controller stuff ##########
    # Equilibrium pose 
    xf = [0.9250087650676135, 0.00820427564681016, -0.3797694610033162, -0.00816277516843245, 0.11172124479696591, -0.0008058608042655944, 0.44969568972519774, -0.011312524917513934, 0.00612999960696473, -0.026098431577256127, -0.026300826444390895, 0.29186645738457084, 0.3011565891540206, 0.8355314412321065, 0.8526119637361341, -0.916297857297, -0.916297857297, -0.9825729401405727, -0.9826692125518477, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    uf = [-0.5687407426035559, 0.6038632976405194, 3.0620134375539556, -3.1685288124879816, -0.5963893983544176, -0.5900199238480763, 8.903600886868457, 8.584255474441395, -0.2902253141866037, -0.28979532471656183, 9.52330678392854, 9.400048025157087]
    Δx = zeros(36)    # Errors 
    u_now = zero(uf)  # control signal 
	u_fb = zero(uf)   # feedback signal 
    joint_pos_rgb = copy(xf[8:19]) # rigidbody indexing

    Kp = 0 # gains for position hold 
    Kd = 5
    K_dict = JLD.load("jetson/LQR_gain2.jld") # gains for equilibrium 
    K = K_dict["K"]
    torques = zeros(12)

    ################## Subscribers  ############
    ctx = ZMQ.Context(1)
    # motor readings 
    motorReadings_msg = init_motor_readings()
    motor_sub() = subscriber_thread(ctx, motorReadings_msg, 5004)
    motor_thread = Task(motor_sub)
    schedule(motor_thread)


    # EKF
    ekf_msg = init_ekf_msg()
    ekf_sub() = subscriber_thread(ctx, ekf_msg, 5003)
    ekf_thread = Task(ekf_sub)
    schedule(ekf_thread)

    # Timing 
    h = 0.002
    ################## Publisher ###################
    motorCmds_msg = init_motor_commands()
    motor_pub = create_pub(ctx, 5005, "*")
    iob = IOBuffer()

    ############ Control loop ###########
    t_Kp = 0. 
    dKp_dt = 5
    command = ["position"]
    command_reader() = while true command[1] = readline() end 
    command_thread = Task(command_reader)
    schedule(command_thread)
    
    ########### Preample ################ 
    ### Debug logging 
    io = open("log.txt", "w+")
    logger = SimpleLogger(io)
    global_logger(logger)

    println("Robot is live...")
    try
        while true 
            ############## Get EKF State ################
            quat = getproperty(ekf_msg, :quaternion)
            pos = getproperty(ekf_msg, :position)
            velocity = getproperty(ekf_msg, :velocity)
            ang_vel = getproperty(ekf_msg, :angular_velocity)
            q = @SVector [quat.w, quat.x, quat.y, quat.z]
            r = @SVector [pos.x, pos.y, pos.z]
            v = @SVector [velocity.x, velocity.y, velocity.z]
            ω = @SVector [ang_vel.x, ang_vel.y, ang_vel.z]

            ############### Get motor readings ############
            q_motor, v_motor, τ_motor = getMotorReadings(motorReadings_msg)

            ################ Controller #################
            joint_pos_c = mapMotorArrays(joint_pos_rgb, MotorIDs_rgb, MotorIDs_c)
            # Gradually upping the position gain 
            if Kp < 200 
                if t_Kp == 0
                    t_Kp = time() 
                end 
                Kp = (time() - t_Kp) * dKp_dt 
            else
                Kp = 200
            end 

            # Calculate state difference 
            Δx[1:3] .= rotation_error(UnitQuaternion(q), UnitQuaternion(xf[1:4]), CayleyMap())
            Δx[4:6] .= r - xf[5:7]
            Δx[19:21] .= ω # NOTE: \omega and velocity should both in body frame 
            Δx[22:24] .= UnitQuaternion(q) * v  # in the KF, v is in world frame. 
            Δx[7:18] .= mapMotorArrays(q_motor, MotorIDs_c, MotorIDs_rgb) - xf[8:19]
            Δx[25:end] .= mapMotorArrays(v_motor, MotorIDs_c, MotorIDs_rgb) 
            u_fb[:] .= -K * Δx 
            u_now[:] .= uf #+ u_fb 
           
            ############### Debug Logging #####################
            # println(round.(u_fb[[1,2,3,4]], digits=3)) # hip
            # println(round.(u_fb[[5,6,7,8]], digits=3)) # thigh 
            # println(round.(u_fb[[9,10,11,12]], digits=3)) # caf 

            # println("calf readings ", qs[9], τs[9])
            # if qs[9] < -1.2 
            #     @info joint_pos_c 
            # end 
            # println(round.(Δx[19:21], digits=3 ))
            # Positional Safety

            ################# Safety ###############
            if any(abs.(Δx[8:19]) .> deg2rad(20)) || any(abs.(Δx[1:3]) .> deg2rad(15)) || any(abs.(Δx[4:6]) .> 0.05) 
                # println("Position out of bounds!!")
                u_now .= 0 
            end 

            # Command safety 
            if any(abs.(u_fb) .> 15) 
                # println("Control out of bounds!!")
                u_now .= 0 
            end 
             
            if command[1] == "position"
                setPositionCmds!(motorCmds_msg, joint_pos_c, Kp, Kd)
            elseif command[1] == "balance"
                # Convert calculation to C indices and set the command! 
                println("entering torque mode!!")
                torques[:] .= mapMotorArrays(u_now, MotorIDs_rgb, MotorIDs_c) # map to c control indices 
                setTorqueCmds!(motorCmds_msg, u_now)
            elseif command[1] == "capture"
                xf[5:7] .= copy(r)
                # capture the current equilibrium point 
                setPositionCmds!(motorCmds_msg, joint_pos_c, Kp, Kd)
                command[1] = "position"
                println("Position captured. Returning to position hold")
            else 
                setPositionCmds!(motorCmds_msg, joint_pos_c, Kp, Kd)
            end 
            setproperty!(motorCmds_msg, :time, time())
            publish(motor_pub, motorCmds_msg, iob)

            if command[1] == "kill control"
                command[1] = "waiting"
                throw(InterruptException())
            end 

            sleep(h)        
            GC.gc(false) # collect garbage 
         end 
    catch e
        # Base.throwto(command_thread, InterruptException())
        # Base.throwto(ekf_thread, InterruptException())
        # Base.throwto(motor_thread, InterruptException())
        schedule(command_thread, ErrorException("stop"), error=true)
        schedule(ekf_thread, InterruptException(), error=true)
        schedule(motor_thread, InterruptException(), error=true)
        close(motor_pub) # sub is closed with the thread
        close(ctx)
        println("EVERYTHING TERMINATED CORRECTLY")
        if e isa InterruptException
        # cleanup
            println("control loop terminated by the user")
        else
            println(e)
            rethrow(e)
        end
    end
end 

main()