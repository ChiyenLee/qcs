
# Init an ekf message
function init_ekf_msg()
	ekf_msg = EKF_msg()
	setproperty!(ekf_msg, :quaternion, Quaternion_msg(w=1,x=0., y=0., z=0.))
	setproperty!(ekf_msg, :position, Vector3_msg(x=0.0, y=0.0, z=0.0))
	setproperty!(ekf_msg, :acceleration_bias, Vector3_msg(x=0.0, y=0.0, z=0.0))
	setproperty!(ekf_msg, :angular_velocity_bias, Vector3_msg(x=0.0, y=0.0, z=0.0))
	setproperty!(ekf_msg, :velocity, Vector3_msg(x=0.0, y=0.0, z=0.0))
	setproperty!(ekf_msg, :angular_velocity, Vector3_msg(x=0.0, y=0.0, z=0.0))
	setproperty!(ekf_msg, :time, 0.0)
	return ekf_msg
end 

# init an imu message 
function init_imu_msg()
	imu_msg = IMU_msg()
	setproperty!(imu_msg, :gyroscope, Vector3_msg(x=0.,y=0., z=0.))
	setproperty!(imu_msg, :acceleration, Vector3_msg(x=0., y=0., z=0.))
	setproperty!(imu_msg, :time, 0.0)
	return imu_msg
end 

# init vicon message
function init_vicon_msg()
	vicon_msg = Vicon_msg()
	setproperty!(vicon_msg, :quaternion, Quaternion_msg(w=1.0, 
	 			  x=0.0, y=0.0, z=0.0))
	setproperty!(vicon_msg, :position, Vector3_msg(x=0.0, y=0.0, z=0.0))
	setproperty!(vicon_msg, :time, 0.0)
	return vicon_msg
end 

# init motor message 
function init_motor_readings() 
    motor_position_msg = Motor_msg() # these are in C indices 
    motor_vel_msg = Motor_msg()
    motor_torque_msg = Motor_msg()
    [setproperty!(motor_position_msg, field,0) for field in propertynames(motor_position_msg)]
    [setproperty!(motor_vel_msg, field,0) for field in propertynames(motor_vel_msg)]
    [setproperty!(motor_torque_msg, field,0) for field in propertynames(motor_torque_msg)]
	motorR_msg = MotorReadings_msg(positions=motor_position_msg, velocities=motor_vel_msg, torques=motor_torque_msg)
	setproperty!(motorR_msg, :time, time())
	return motorR_msg
end 

function init_motor_commands()
	motor_cmds_msg = MotorCmds_msg(); 

	for motor in propertynames(motor_cmds_msg)[1:12]
		motor_cmd = MotorCmd_msg(Kp=0, Kd=0, pos=0, vel=0, tau=0)
		setproperty!(motor_cmds_msg, motor, motor_cmd)
	end 
	setproperty!(motor_cmds_msg, :time, time())
	return motor_cmds_msg

end 