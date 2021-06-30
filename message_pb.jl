# syntax: proto3
using ProtoBuf
import ProtoBuf.meta

mutable struct IMU <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function IMU(; kwargs...)
        obj = new(meta(IMU), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) || error(string(typeof(obj), " has no field with name ", fldname))
            if fldval !== nothing
                values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
            end
        end
        obj
    end
end # mutable struct IMU
const __meta_IMU = Ref{ProtoMeta}()
function meta(::Type{IMU})
    ProtoBuf.metalock() do
        if !isassigned(__meta_IMU)
            __meta_IMU[] = target = ProtoMeta(IMU)
            pack = Symbol[:quaternion,:rpy,:gyro]
            allflds = Pair{Symbol,Union{Type,String}}[:quaternion => Base.Vector{Float64}, :rpy => Base.Vector{Float64}, :gyro => Base.Vector{Float64}, :time => Float64]
            meta(target, IMU, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, pack, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_IMU[]
    end
end
function Base.getproperty(obj::IMU, name::Symbol)
    if name === :quaternion
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Float64}
    elseif name === :rpy
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Float64}
    elseif name === :gyro
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Float64}
    elseif name === :time
        return (obj.__protobuf_jl_internal_values[name])::Float64
    else
        getfield(obj, name)
    end
end

mutable struct VICON <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function VICON(; kwargs...)
        obj = new(meta(VICON), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) || error(string(typeof(obj), " has no field with name ", fldname))
            if fldval !== nothing
                values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
            end
        end
        obj
    end
end # mutable struct VICON
const __meta_VICON = Ref{ProtoMeta}()
function meta(::Type{VICON})
    ProtoBuf.metalock() do
        if !isassigned(__meta_VICON)
            __meta_VICON[] = target = ProtoMeta(VICON)
            pack = Symbol[:position,:quaternion]
            allflds = Pair{Symbol,Union{Type,String}}[:position => Base.Vector{Float64}, :quaternion => Base.Vector{Float64}, :time => Float64]
            meta(target, VICON, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, pack, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_VICON[]
    end
end
function Base.getproperty(obj::VICON, name::Symbol)
    if name === :position
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Float64}
    elseif name === :quaternion
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Float64}
    elseif name === :time
        return (obj.__protobuf_jl_internal_values[name])::Float64
    else
        getfield(obj, name)
    end
end

const PROPERTY_NAME = (;[
    Symbol("IMU") => Int32(0),
    Symbol("VICON") => Int32(1),
]...)

mutable struct PROPERTY <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function PROPERTY(; kwargs...)
        obj = new(meta(PROPERTY), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) || error(string(typeof(obj), " has no field with name ", fldname))
            if fldval !== nothing
                values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
            end
        end
        obj
    end
end # mutable struct PROPERTY
const __meta_PROPERTY = Ref{ProtoMeta}()
function meta(::Type{PROPERTY})
    ProtoBuf.metalock() do
        if !isassigned(__meta_PROPERTY)
            __meta_PROPERTY[] = target = ProtoMeta(PROPERTY)
            allflds = Pair{Symbol,Union{Type,String}}[]
            meta(target, PROPERTY, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_PROPERTY[]
    end
end

export IMU, VICON, PROPERTY_NAME, PROPERTY
