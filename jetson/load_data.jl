using Pkg
Pkg.activate(".")
using julia_messaging
using julia_messaging: ProtoBuf
using julia_messaging: readproto, writeproto
using EKF


f = open("tools/A1data-2021-07-16--16-33-55/imu.bin", "r")
imu = IMU_msg()
iob = PipeBuffer();
while true 

	size_bytes = read(f,4)
	if length(size_bytes) == 4
		data_size = bswap(reinterpret(UInt32, size_bytes)[1])
		bin_data = read(f, data_size)
		write(iob,bin_data)
        data = readproto(iob, imu)
	else
		break
	end 
end 
