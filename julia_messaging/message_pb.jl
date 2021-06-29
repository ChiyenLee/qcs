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

const PORTLIST_TOPICS = (;[
    Symbol("HEADER") => Int32(0),
    Symbol("IMU") => Int32(5000),
]...)

mutable struct PORTLIST <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function PORTLIST(; kwargs...)
        obj = new(meta(PORTLIST), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct PORTLIST
const __meta_PORTLIST = Ref{ProtoMeta}()
function meta(::Type{PORTLIST})
    ProtoBuf.metalock() do
        if !isassigned(__meta_PORTLIST)
            __meta_PORTLIST[] = target = ProtoMeta(PORTLIST)
            allflds = Pair{Symbol,Union{Type,String}}[]
            meta(target, PORTLIST, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_PORTLIST[]
    end
end

export IMU, PORTLIST_TOPICS, PORTLIST
