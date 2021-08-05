using julia_messaging
using quadruped_control
using EKF
using LinearAlgebra
include("EKF.jl/test/imu_grav_comp/imu_dynamics_discrete.jl")

state_init = zeros(length(TrunkState)); state_init[7] = 1.0 
state = TrunkState(state_init)
vicon_init = zeros(7); vicon_init[4] = 1.0
vicon_measurement = Vicon(vicon_init);
input = ImuInput(zeros(length(ImuInput)))

h = 0.005
P = Matrix(1.0I(length(TrunkError))) * 1e10; 
W = Matrix(1.0I(length(TrunkError))) * 1e-3;
W[4:6, 4:6] .= I(3) * 1e-2 * h^2 
W[end-5:end,end-5:end] = I(6)*1e2
R = Matrix(1.0I(length(ViconError))) * 1e-3;
ekf = ErrorStateFilter{TrunkState, TrunkError, ImuInput, Vicon, ViconError}(state, P, W, R) 
try
	while true 
		global command 
		println(command[1])
		sleep(0.005)
	end 
catch e 
	rethrow(e)
finally 
	println("???")
end 