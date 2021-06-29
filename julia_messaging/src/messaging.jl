
function create_sub(ctx, portname)
    s = Socket(ctx, SUB)
    ZMQ.subscribe(s)
    ZMQ.connect(s, "tcp://127.0.0.1:$portname")

    return s 
end 

function create_pub(ctx, portname)
    s = Socket(ctx, PUB)
    ZMQ.bind(p, "tcp://127.0.0.1:$portname")
    return s 
end