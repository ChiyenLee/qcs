import zmq 

def create_pub(ctx, port): 
    socket = ctx.socket(zmq.PUB)
    socket.bind("tcp://*:%s" % port)
    return socket 

def create_sub(ctx, port): 
    socket = ctx.socket(zmq.SUB)
    socket.connect("tcp://localhost:%s" % port)
    socket.subscribe("")
    return socket  

