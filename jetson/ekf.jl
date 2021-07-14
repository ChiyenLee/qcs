using quadruped_control: prediction!
using julia_messaging
using quadruped_control
using quadruped_control: UnitQuaternion, RotXYZ
using LinearAlgebra
## Subscribing example with ZMQ and Protobuf 
function main()
    # Subscribe to Vicon topics
    ctx = julia_messaging.ZMQ.Context(1)
	vicon = Vicon_msg()
	vicon_sub() = subscriber_thread(ctx,vicon,5000)
	vicon_thread = Task(vicon_sub)
	schedule(vicon_thread)

    # IMU readings 
    accel_imu = zeros(3);
    gyro_imu = zeros(3);

    # Initialize EKF
    v = Vicon{Float64}()
    s = TrunkState{Float64}()
    u_imu = IMU_IN{Float64}()
    ekf = EKF(s)
    v.R = v.R * 1e-4

    s.W .= s.W * 1e2
    s.W[s.dβf.indices[1], s.dβf.indices[1]] .= s.W[s.dβf.indices[1], s.dβf.indices[1]] * 1
    s.W[s.dβω.indices[1], s.dβω.indices[1]] .= s.W[s.dβω.indices[1], s.dβω.indices[1]] * 1
    # s.W[s.dr.indices[1],  s.dβf.indices[1]] .= Matrix(1.0I, 3,3) * 1e-3
    # s.W[s.dβf.indices[1],  s.dr.indices[1]] .= Matrix(1.0I, 3,3) * 1e-3
    # s.W[s.dϕ.indices[1],  s.dβf.indices[1]] .= Matrix(1.0I, 3,3) * 1e-3
    # s.W[s.dβf.indices[1],  s.dϕ.indices[1]] .= Matrix(1.0I, 3,3) * 1e-3
    # s.W[s.dv.indices[1],  s.dβf.indices[1]] .= Matrix(1.0I, 3,3) * 1e-3
    # s.W[s.dβf.indices[1],  s.dv.indices[1]] .= Matrix(1.0I, 3,3) * 1e-3


    P_init = Matrix(1.0I, 15,15) * 1e10
    ekf.est_cov .= P_init
    # timing 
    vicon_time = 0.0
    h = 0.005
    try
        while true 
            A1Robot.getAcceleration(interface, accel_imu);
            A1Robot.getGyroscope(interface, gyro_imu); 

            # Prediction 
            u_imu.f .= copy(accel_imu)    
            u_imu.ω .= copy(gyro_imu)
            prediction!(ekf, u_imu, h)

            # Update 
            if hasproperty(vicon, :quaternion)
               if vicon.time != vicon_time 
                    # v.q .= [vicon.quaternion.z, vicon.quaternion.w, vicon.quaternion.x,
                            # vicon.quaternion.y]
                    v.q .= [vicon.quaternion.w, vicon.quaternion.x, vicon.quaternion.y, vicon.quaternion.z]
                    v.r .= [vicon.position.x, vicon.position.y, vicon.position.z]
                    update!(ekf, v, h)
                    vicon_time = vicon.time
               end  
            end

            # println(round.(ekf.est_state.q, digits=3))
            # println(round.(ekf.est_state.dϕ, digits=3))
            # println(round.(ekf.est_state.r, digits=3))
            println(round.(ekf.est_state.v , digits=3))
            # println(round.(ekf.est_state.βω, digits=3))
            # println(ekf.est_state.βf)
            # println(round.(accel_imu, digits=3))
            # println(ekf.est_state.q)
            # q = ekf.est_state.q
            # q = v.q
            # g = [0, 0, 9.81]
            # C = UnitQuaternion(q)
            # println(round.(ekf.est_state.βf, digits=3))
            # println(round.(C' * accel_imu - g, digits=2))
            sleep(h)
        end    
    catch e
        close(ctx)
        if e isa InterruptException
            # clean up 
            println("Process terminated by you")
            Base.throwto(vicon_thread, InterruptException())
        else 
            rethrow(e)
        end 
    end
end 

main()