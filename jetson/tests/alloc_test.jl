using quadruped_control.StaticArrays

function test_alloc()
	test = @MVector zeros(10)
	test[1] = 1.0
	test[2] = 2.0
	test = SVector(test)
	return test
end 

command = ["a"]
@async while true command[1] = readline();  end

while true 
	sleep(0.01)
	println(command)
end 