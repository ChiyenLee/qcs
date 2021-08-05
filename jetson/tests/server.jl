using DaemonMode 
using Pkg 
Pkg.activate(".")
using Revise 
using quadruped_control
interface = A1Robot.RobotInterface() 
A1Robot.InitSend(interface)
COMMAND = ["1"]
serve(print_stack=true, async=true)