using Pkg
Pkg.activate(".")
using Revise
using quadruped_control
interface = A1Robot.RobotInterface() 
A1Robot.InitSend(interface)
#