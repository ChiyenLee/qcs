using DaemonMode 

try 
	while true 
		Main.COMMAND[1] = readline()
		println(Main.COMMAND[1])
		if Main.COMMAND[1] == "kill command"
			throw(InterruptException())
		end 
	end 
catch e 
	if e isa InterruptException
		println("killed by user")
	else 
		rethrow(e)
	end 
end 
