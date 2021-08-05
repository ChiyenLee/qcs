using Pkg 
Pkg.activate(".")
using Revise
using julia_messaging
using quadruped_control
using quadruped_control: UnitQuaternion, RotXYZ
using LinearAlgebra
using EKF
using julia_messaging: writeproto, ZMQ
# include("EKF.jl/test/imu_grav_comp/imu_dynamics_discrete.jl")
# include("jetson/proto_utils.jl")
include("../EKF.jl/test/imu_grav_comp/imu_dynamics_discrete.jl")
include("proto_utils.jl")
# COMMAND = [".."]
## Subscribing example with ZMQ and Protobuf 
function main()
    ##### Subscribe to Vicon topics #####
    ctx = julia_messaging.ZMQ.Context(1)
	vicon = Vicon_msg()
	vicon_sub() = subscriber_thread(ctx,vicon,5000)
	vicon_thread = Task(vicon_sub)
	schedule(vicon_thread)

    ##### Subscribe to IMU topics ####### 
    imu_msg = init_imu_msg()
    imu_sub() = subscriber_thread(ctx, imu_msg, 5002)
    imu_thread = Task(imu_sub)
    schedule(imu_thread)

    # Timing 
    h = 0.005
    vicon_time = 0.0

    # # Initialize EKF
    state_init = zeros(length(TrunkState)); state_init[7] = 1.0 
    state = TrunkState(state_init)
    vicon_init = zeros(7); vicon_init[4] = 1.0
    vicon_measurement = Vicon(vicon_init);
    input = ImuInput(zeros(length(ImuInput)))

    P = Matrix(1.0I(length(TrunkError))) * 1e10; 
    W = Matrix(1.0I(length(TrunkError))) * 1e-3;
    W[1:3, 1:3] .= I(3) * 1e-2
    W[4:6, 4:6] .= I(3) * 1e-3
    W[7:9, 7:9] .= I(3) * 1e-4
    W[end-5:end,end-5:end] = I(6)*1e2
    R = Matrix(1.0I(length(ViconError))) * 1e-5;
    R[1:3,1:3] = I(3) * 1e-3 
    R[4:6,4:6] = I(3) * 1e-3 
    ekf = ErrorStateFilter{TrunkState, TrunkError, ImuInput, Vicon, ViconError}(state, P, W, R) 

    # Publisher 
    ekf_pub = create_pub(ctx,5003, "*")
    vicon_pub = create_pub(ctx,5001, "*")
    iob = IOBuffer()
    ekf_msg = init_ekf_msg()
    vicon_msg = init_vicon_msg()

    try
        while true 
            # Prediction 
            acc = getproperty(imu_msg, :acceleration)
            gyro = getproperty(imu_msg, :gyroscope)
            input = ImuInput(acc.x, acc.y, acc.z, gyro.x, gyro.y, gyro.z)
            prediction!(ekf, input, h)

            Update 
            if hasproperty(vicon, :quaternion)
               if vicon.time != vicon_time 
                    vicon_measurement = Vicon(vicon.position.x, vicon.position.y, vicon.position.z, vicon.quaternion.w, vicon.quaternion.x, vicon.quaternion.y, vicon.quaternion.z)
                    update!(ekf, vicon_measurement)
                    vicon_time = vicon.time

                    # Publishing 
                    vicon_msg.quaternion.w, vicon_msg.quaternion.x, vicon_msg.quaternion.y, vicon_msg.quaternion.z = vicon_measurement[4:end]
                    vicon_msg.position.x, vicon_msg.position.y, vicon_msg.position.z = vicon_measurement[1:3]
                    vicon_msg.time = time()
                    publish(vicon_pub, vicon_msg, iob)
               end  
            end

            # Publishing
            r, v, q, α, β = getComponents(TrunkState(ekf.est_state))
            ekf_msg.quaternion.w, ekf_msg.quaternion.x, ekf_msg.quaternion.y, ekf_msg.quaternion.z = q
            ekf_msg.position.x, ekf_msg.position.y, ekf_msg.position.z = r 
            ekf_msg.acceleration_bias.x, ekf_msg.acceleration_bias.y, ekf_msg.acceleration_bias.z = α
            ekf_msg.angular_velocity_bias.x, ekf_msg.angular_velocity_bias.y, ekf_msg.angular_velocity_bias.z = β
            ekf_msg.velocity.x, ekf_msg.velocity.y, ekf_msg.velocity.z = v 
            ekf_msg.angular_velocity.x, ekf_msg.angular_velocity.y, ekf_msg.angular_velocity.z = gyro.x, gyro.y, gyro.z
            ekf_msg.time = time()
            publish(ekf_pub, ekf_msg, iob)                

            # if Main.COMMAND[1] == "kill ekf"
            #     Main.COMMAND[1] = "waiting"
            #     throw(InterruptException())
            # end 
            sleep(h)
            GC.gc(false)
        end    
    catch e
        close(ekf_pub)
        close(vicon_pub)
        # Base.throwto(imu_thread, InterruptException())
        # Base.throwto(vicon_thread, InterruptException())
        schedule(imu_thread, InterruptException(), error=true)
        schedule(vicon_thread, InterruptException(), error=true)
        close(ctx)
        if e isa InterruptException
            # clean up 
            println("Process terminated by you")
        else 
            rethrow(e)
        end 
    end 
end 

main()