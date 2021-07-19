using Pkg
Pkg.activate(".")
using julia_messaging
using julia_messaging: ProtoBuf
using julia_messaging: readproto, writeproto
using EKF
using LinearAlgebra
include("../EKF.jl/test/imu_grav_comp/imu_dynamics_discrete.jl")

# Setting up data loading 
# folder = "tools/A1data-2021-07-16--16-22-05"
folder = "tools/A1data-2021-07-16--16-24-22"
f = open(folder*"/imu.bin", "r")
ekf_f = open(folder*"/ekf.bin", "r")
vicon_f = open(folder*"/vicon.bin", "r")
imu = IMU_msg()
ekf_msg = EKF_msg()
vicon_msg = Vicon_msg()
iob = PipeBuffer();

# setting up ekf stuff 
state = TrunkState(zeros(length(TrunkState))); state.qw = 1.0
vicon_measurement = Vicon(zeros(length(Vicon))); vicon_measurement.qw = 1.0;
input = ImuInput(zeros(length(ImuInput)))

P = Matrix(1.0I(length(TrunkError))) * 1e10; 
W = Matrix(1.0I(length(TrunkError))) * 1e5;
W[end-5:end,end-5:end] = W[end-5:end,end-5:end] * 1e-5
R = Matrix(1.0I(length(ViconError))) * 1e-3;
ekf = ErrorStateFilter{TrunkState, TrunkError, ImuInput, Vicon, ViconError}(state, P, W, R) 

acc_imu = []
gyro_imu = []
t_imu = []
r_ekf = []
acc_bias_ekf = []
v_ekf = []
q_ekf = []
r_vicon = []
q_vicon = []
t_vicon = []
while true 

	size_bytes = read(f,4)
	if length(size_bytes) == 4
		data_size = bswap(reinterpret(UInt32, size_bytes)[1])
		bin_data = read(f, data_size)
		write(iob,bin_data)
        data = readproto(iob, imu)

		acc = data.acceleration
		ω = data.gyroscope
		input[1:3] = [acc.x, acc.y, acc.z]
		input[4:6] = [ω.x, ω.y, ω.z]
		prediction!(ekf, input, dt=0.005)
		push!(acc_imu, input[1:3])	
		push!(gyro_imu, input[4:6])
		push!(t_imu, data.time)
	else
		break
	end 
end 
while true 

	size_bytes = read(ekf_f,4)
	if length(size_bytes) == 4
		data_size = bswap(reinterpret(UInt32, size_bytes)[1])
		bin_data = read(ekf_f, data_size)
		write(iob,bin_data)
        ekf_data = readproto(iob, ekf_msg)

		r = ekf_data.position
		q = ekf_data.quaternion
		v = ekf_data.velocity
		α = ekf_data.acceleration_bias
		push!(r_ekf, [r.x, r.y, r.z])
		push!(q_ekf, [q.w, q.x, q.y, q.z])
		push!(v_ekf, [v.x, v.y, v.z])
		push!(acc_bias_ekf, [α.x, α.y, α.z])	
		# push!(vicon_readings, [q_vicon.x, q_ekf.y, q_ekf.z])
	
	else
		break
	end 
end 

while true 

	size_bytes = read(vicon_f,4)
	if length(size_bytes) == 4
		data_size = bswap(reinterpret(UInt32, size_bytes)[1])
		bin_data = read(vicon_f, data_size)
		write(iob,bin_data)
        vicon_data = readproto(iob, vicon_msg)

		r = vicon_data.position
		q = vicon_data.quaternion
		push!(r_vicon, [r.x, r.y, r.z])
		push!(q_vicon, [q.w, q.x, q.y, q.z])
		push!(t_vicon, vicon_data.time)
	else
		break
	end 
end 

r_ekf = hcat(r_ekf...)
q_ekf = hcat(q_ekf...)
v_ekf = hcat(v_ekf...)
acc_bias_ekf = hcat(acc_bias_ekf...)
acc_imu = hcat(acc_imu...)
gyro_imu = hcat(gyro_imu...)
r_vicon = hcat(r_vicon...)
q_vicon = hcat(q_vicon...)