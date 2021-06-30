
function create_sub(ctx, portname, host="127.0.0.1")
    s = Socket(ctx, SUB)
    ZMQ.subscribe(s)
    ZMQ.connect(s, "tcp://127.0.0.1:$portname")
    return s 
end 

function create_pub(ctx, portname)
    p = Socket(ctx, PUB)
    ZMQ.bind(p, "tcp://127.0.0.1:$portname")
    return p 
end