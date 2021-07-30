# run load data first 
using Rotations: ∇differential
using EKF
using LinearAlgebra
using PyPlot
include("../EKF.jl/test/imu_grav_comp/imu_dynamics_discrete.jl")

ind_final = 6000
h = 0.005
qs = zeros(4, ind_final)
qs[:,1] .= q_ekf[:,1]
q = copy(qs[:,1])

state = TrunkState(zeros(length(TrunkState))); state.qw = 1.0
vicon_measurement = Vicon(zeros(length(Vicon))); vicon_measurement.qw = 1.0;
input = ImuInput(zeros(length(ImuInput)))

P = Matrix(1.0I(length(TrunkError))) * 1e10; 
W = Matrix(1.0I(length(TrunkError))) * 1e-2;
W[4:6, 4:6] .= I(3) * 1e-2 * h^2 
W[end-5:end,end-5:end] = I(6)*1e4
R = Matrix(1.0I(length(ViconError))) * 1e-3;
ekf = ErrorStateFilter{TrunkState, TrunkError, ImuInput, Vicon, ViconError}(state, P, W, R) 

acc_corrected = zeros(3,ind_final)
r_predicted = zeros(3, ind_final)
bias_predicted = zeros(3, ind_final)
v_predicted = zeros(3, ind_final)
for i in 2:ind_final
	ω = gyro_imu[:,i-1]
	qs[:,i] = qs[:,i-1] + 0.5 * ∇differential(UnitQuaternion(qs[:,i-1])) * (ω )*h
	qs[:,i] = qs[:,i] / norm(qs[:,i])

	# EKF test 
	input[1:3] .= acc_imu[:,i-1]
	input[4:6] .= gyro_imu[:,i-1]
	vicon_measurement[1:3] .= r_vicon[:,i]
	vicon_measurement[4:end] .= q_vicon[:,i]
	prediction!(ekf, input, dt=h)
	update!(ekf, vicon_measurement)

	r_predicted[:,i] .= ekf.est_state[1:3]
	v_predicted[:,i] .= ekf.est_state[4:6]
	bias_predicted[:,i] .= ekf.est_state[end-5:end-3]


	q_truth = q_ekf[:,i-1]
	g = [0,0,9.81]
	C = UnitQuaternion(q_truth);
	acc = acc_imu[:,i-1]
	bias = acc_bias_ekf[:,i-1]
	acc_corrected[:,i] = C*(acc - bias_predicted[:,i]) - g	
end

