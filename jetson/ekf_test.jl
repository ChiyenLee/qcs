using Revise
using EKF
using LinearAlgebra
using Rotations: params
# include("../EKF.jl/test/imu/imu_states.jl")
# include("../EKF.jl/test/imu/imu_dynamics.jl")

# state = ImuState(zeros(length(ImuState))); state.q𝑤 = 1.0
# vicon = ViconMeasurement(zeros(length(ViconMeasurement))); vicon.q𝑤 = 1.0;
# input = ImuInput(zeros(length(ImuInput)))

# P = Matrix(1.0I(length(ImuErrorState))) * 1e-10; 
# W = Matrix(1.0I(length(ImuErrorState))) * 1e3;
# R = Matrix(1.0I(length(ViconErrorMeasurement))) * 1e-3;

# q_rand = randn(4); q_rand = q_rand / norm(q_rand)
# vicon = ViconMeasurement([0. 0. 0. q_rand...])
# input.v̇𝑥 = 10

# ekf = ErrorStateFilter{ImuState, ImuErrorState, ImuInput, ViconMeasurement, ViconErrorMeasurement}(state, P, W, R)

include("../EKF.jl/test/imu_grav_comp/imu_dynamics_discrete.jl")
state = TrunkState(zeros(length(TrunkState))); state.qw = 1.0
vicon = Vicon(zeros(length(Vicon))); vicon.qw = 1.0;
input = ImuInput(zeros(length(ImuInput)))

P = Matrix(1.0I(length(TrunkError))) * 1e10; 
W = Matrix(1.0I(length(TrunkError))) * 1e3;
W[end-5:end,end-5:end] = W[end-5:end,end-5:end] * 1
R = Matrix(1.0I(length(ViconError))) * 1e-3;

q_target = UnitQuaternion(RotXYZ(2.1,0.5,0.1))
state[7:10] .= params(q_target)
vicon = Vicon([1. 0. 0. params(q_target)...])

ekf = ErrorStateFilter{TrunkState, TrunkError, ImuInput, Vicon, ViconError}(state, P, W, R)
g = [0,0,9.81]
for i in 1:100
	# global state, P
	prediction!(ekf, input, dt=0.01)
	update!(ekf, vicon)	

	# estimateState!(ekf, input, vicon, 0.01 )
	# state_prior, P_prior = prediction(ekf, state, P, input, dt=0.01)
	# vicon_error, H, L = innovation(ekf, state_prior, P_prior, vicon) # H::measure jacobian, L::Kalman Gain
	# state_post, P_post = update!(ekf, state_prior, P_prior, vicon_error, H, L)
	
	# state = copy(state_post)
	# P = copy(P_post)
	# println(norm(ekf.est_state[7:10] - params(q_target)))
	r, v,q, α, β =	getComponents(state)
	# println(r)
	println("bias ", α)
end 	 

r, v,q, α, β =	getComponents(state)