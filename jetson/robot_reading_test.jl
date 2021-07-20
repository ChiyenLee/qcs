


try
    f_accel = open("accelerometer.csv", "w+")
    f_gyroscope = open("gyroscope.csv", "w+")
    f_quaternion = open("quaternion.csv", "w+")
    quaternion = zeros(Float64, 4)
    acceleration = zeros(Float64, 3)
    gyroscope = zeros(Float64, 3)
    t_start = time()
    while true 
        t = time() - t_start
        A1Robot.getQuaternion(interface, quaternion)
        A1Robot.getAcceleration(interface, acceleration)
        A1Robot.getGyroscope(interface, gyroscope)
        #write(f_accel, string(t) * "," )
        #write(f_accel, string(acceleration)[2:end-1])
        #write(f_accel, "\n")

        #write(f_gyroscope, string(t) *",")
        #write(f_gyroscope, string(gyroscope)[2:end-1])
        #write(f_gyroscope, "\n")

        #write(f_quaternion, string(t)*",")
        #write(f_quaternion, string(quaternion)[2:end-1])
        #write(f_quaternion, "\n")

        println(t)
        #sleep(0.01)
    end 
catch e
   if e isa InterruptException
      # cleanup
      println("control loop terminated by the user")
   #    rethrow(e)
   else
       println(e)
       rethrow(e)
   end
end
