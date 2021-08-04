# syntax: proto3
using ProtoBuf
import ProtoBuf.meta

mutable struct MotorCmd_msg <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function MotorCmd_msg(; kwargs...)
        obj = new(meta(MotorCmd_msg), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct MotorCmd_msg
const __meta_MotorCmd_msg = Ref{ProtoMeta}()
function meta(::Type{MotorCmd_msg})
    ProtoBuf.metalock() do
        if !isassigned(__meta_MotorCmd_msg)
            __meta_MotorCmd_msg[] = target = ProtoMeta(MotorCmd_msg)
            allflds = Pair{Symbol,Union{Type,String}}[:Kp => Float64, :Kd => Float64, :pos => Float64, :vel => Float64, :tau => Float64]
            meta(target, MotorCmd_msg, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_MotorCmd_msg[]
    end
end
function Base.getproperty(obj::MotorCmd_msg, name::Symbol)
    if name === :Kp
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :Kd
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :pos
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :vel
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :tau
        return (obj.__protobuf_jl_internal_values[name])::Float64
    else
        getfield(obj, name)
    end
end

mutable struct MotorCmds_msg <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function MotorCmds_msg(; kwargs...)
        obj = new(meta(MotorCmds_msg), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct MotorCmds_msg
const __meta_MotorCmds_msg = Ref{ProtoMeta}()
function meta(::Type{MotorCmds_msg})
    ProtoBuf.metalock() do
        if !isassigned(__meta_MotorCmds_msg)
            __meta_MotorCmds_msg[] = target = ProtoMeta(MotorCmds_msg)
            allflds = Pair{Symbol,Union{Type,String}}[:FR_Hip => MotorCmd_msg, :FR_Thigh => MotorCmd_msg, :FR_Calf => MotorCmd_msg, :FL_Hip => MotorCmd_msg, :FL_Thigh => MotorCmd_msg, :FL_Calf => MotorCmd_msg, :RR_Hip => MotorCmd_msg, :RR_Thigh => MotorCmd_msg, :RR_Calf => MotorCmd_msg, :RL_Hip => MotorCmd_msg, :RL_Thigh => MotorCmd_msg, :RL_Calf => MotorCmd_msg, :time => Float64]
            meta(target, MotorCmds_msg, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_MotorCmds_msg[]
    end
end
function Base.getproperty(obj::MotorCmds_msg, name::Symbol)
    if name === :FR_Hip
        return (obj.__protobuf_jl_internal_values[name])::MotorCmd_msg
    elseif name === :FR_Thigh
        return (obj.__protobuf_jl_internal_values[name])::MotorCmd_msg
    elseif name === :FR_Calf
        return (obj.__protobuf_jl_internal_values[name])::MotorCmd_msg
    elseif name === :FL_Hip
        return (obj.__protobuf_jl_internal_values[name])::MotorCmd_msg
    elseif name === :FL_Thigh
        return (obj.__protobuf_jl_internal_values[name])::MotorCmd_msg
    elseif name === :FL_Calf
        return (obj.__protobuf_jl_internal_values[name])::MotorCmd_msg
    elseif name === :RR_Hip
        return (obj.__protobuf_jl_internal_values[name])::MotorCmd_msg
    elseif name === :RR_Thigh
        return (obj.__protobuf_jl_internal_values[name])::MotorCmd_msg
    elseif name === :RR_Calf
        return (obj.__protobuf_jl_internal_values[name])::MotorCmd_msg
    elseif name === :RL_Hip
        return (obj.__protobuf_jl_internal_values[name])::MotorCmd_msg
    elseif name === :RL_Thigh
        return (obj.__protobuf_jl_internal_values[name])::MotorCmd_msg
    elseif name === :RL_Calf
        return (obj.__protobuf_jl_internal_values[name])::MotorCmd_msg
    elseif name === :time
        return (obj.__protobuf_jl_internal_values[name])::Float64
    else
        getfield(obj, name)
    end
end

mutable struct Motor_msg <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Motor_msg(; kwargs...)
        obj = new(meta(Motor_msg), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct Motor_msg
const __meta_Motor_msg = Ref{ProtoMeta}()
function meta(::Type{Motor_msg})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Motor_msg)
            __meta_Motor_msg[] = target = ProtoMeta(Motor_msg)
            allflds = Pair{Symbol,Union{Type,String}}[:FR_Hip => Float64, :FR_Thigh => Float64, :FR_Calf => Float64, :FL_Hip => Float64, :FL_Thigh => Float64, :FL_Calf => Float64, :RR_Hip => Float64, :RR_Thigh => Float64, :RR_Calf => Float64, :RL_Hip => Float64, :RL_Thigh => Float64, :RL_Calf => Float64, :time => Float64]
            meta(target, Motor_msg, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_Motor_msg[]
    end
end
function Base.getproperty(obj::Motor_msg, name::Symbol)
    if name === :FR_Hip
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :FR_Thigh
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :FR_Calf
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :FL_Hip
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :FL_Thigh
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :FL_Calf
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :RR_Hip
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :RR_Thigh
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :RR_Calf
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :RL_Hip
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :RL_Thigh
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :RL_Calf
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :time
        return (obj.__protobuf_jl_internal_values[name])::Float64
    else
        getfield(obj, name)
    end
end

mutable struct MotorReadings_msg <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function MotorReadings_msg(; kwargs...)
        obj = new(meta(MotorReadings_msg), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct MotorReadings_msg
const __meta_MotorReadings_msg = Ref{ProtoMeta}()
function meta(::Type{MotorReadings_msg})
    ProtoBuf.metalock() do
        if !isassigned(__meta_MotorReadings_msg)
            __meta_MotorReadings_msg[] = target = ProtoMeta(MotorReadings_msg)
            fnum = Int[1,2,3,5]
            allflds = Pair{Symbol,Union{Type,String}}[:torques => Motor_msg, :positions => Motor_msg, :velocities => Motor_msg, :time => Float64]
            meta(target, MotorReadings_msg, allflds, ProtoBuf.DEF_REQ, fnum, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_MotorReadings_msg[]
    end
end
function Base.getproperty(obj::MotorReadings_msg, name::Symbol)
    if name === :torques
        return (obj.__protobuf_jl_internal_values[name])::Motor_msg
    elseif name === :positions
        return (obj.__protobuf_jl_internal_values[name])::Motor_msg
    elseif name === :velocities
        return (obj.__protobuf_jl_internal_values[name])::Motor_msg
    elseif name === :time
        return (obj.__protobuf_jl_internal_values[name])::Float64
    else
        getfield(obj, name)
    end
end

mutable struct Vector3_msg <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Vector3_msg(; kwargs...)
        obj = new(meta(Vector3_msg), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct Vector3_msg
const __meta_Vector3_msg = Ref{ProtoMeta}()
function meta(::Type{Vector3_msg})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Vector3_msg)
            __meta_Vector3_msg[] = target = ProtoMeta(Vector3_msg)
            allflds = Pair{Symbol,Union{Type,String}}[:x => Float64, :y => Float64, :z => Float64]
            meta(target, Vector3_msg, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_Vector3_msg[]
    end
end
function Base.getproperty(obj::Vector3_msg, name::Symbol)
    if name === :x
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :y
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :z
        return (obj.__protobuf_jl_internal_values[name])::Float64
    else
        getfield(obj, name)
    end
end

mutable struct IMU_msg <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function IMU_msg(; kwargs...)
        obj = new(meta(IMU_msg), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct IMU_msg
const __meta_IMU_msg = Ref{ProtoMeta}()
function meta(::Type{IMU_msg})
    ProtoBuf.metalock() do
        if !isassigned(__meta_IMU_msg)
            __meta_IMU_msg[] = target = ProtoMeta(IMU_msg)
            allflds = Pair{Symbol,Union{Type,String}}[:acceleration => Vector3_msg, :gyroscope => Vector3_msg, :time => Float64]
            meta(target, IMU_msg, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_IMU_msg[]
    end
end
function Base.getproperty(obj::IMU_msg, name::Symbol)
    if name === :acceleration
        return (obj.__protobuf_jl_internal_values[name])::Vector3_msg
    elseif name === :gyroscope
        return (obj.__protobuf_jl_internal_values[name])::Vector3_msg
    elseif name === :time
        return (obj.__protobuf_jl_internal_values[name])::Float64
    else
        getfield(obj, name)
    end
end

mutable struct Quaternion_msg <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Quaternion_msg(; kwargs...)
        obj = new(meta(Quaternion_msg), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct Quaternion_msg
const __meta_Quaternion_msg = Ref{ProtoMeta}()
function meta(::Type{Quaternion_msg})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Quaternion_msg)
            __meta_Quaternion_msg[] = target = ProtoMeta(Quaternion_msg)
            allflds = Pair{Symbol,Union{Type,String}}[:w => Float64, :x => Float64, :y => Float64, :z => Float64]
            meta(target, Quaternion_msg, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_Quaternion_msg[]
    end
end
function Base.getproperty(obj::Quaternion_msg, name::Symbol)
    if name === :w
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :x
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :y
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :z
        return (obj.__protobuf_jl_internal_values[name])::Float64
    else
        getfield(obj, name)
    end
end

mutable struct Vicon_msg <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Vicon_msg(; kwargs...)
        obj = new(meta(Vicon_msg), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct Vicon_msg
const __meta_Vicon_msg = Ref{ProtoMeta}()
function meta(::Type{Vicon_msg})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Vicon_msg)
            __meta_Vicon_msg[] = target = ProtoMeta(Vicon_msg)
            allflds = Pair{Symbol,Union{Type,String}}[:position => Vector3_msg, :quaternion => Quaternion_msg, :time => Float64]
            meta(target, Vicon_msg, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_Vicon_msg[]
    end
end
function Base.getproperty(obj::Vicon_msg, name::Symbol)
    if name === :position
        return (obj.__protobuf_jl_internal_values[name])::Vector3_msg
    elseif name === :quaternion
        return (obj.__protobuf_jl_internal_values[name])::Quaternion_msg
    elseif name === :time
        return (obj.__protobuf_jl_internal_values[name])::Float64
    else
        getfield(obj, name)
    end
end

mutable struct EKF_msg <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function EKF_msg(; kwargs...)
        obj = new(meta(EKF_msg), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct EKF_msg
const __meta_EKF_msg = Ref{ProtoMeta}()
function meta(::Type{EKF_msg})
    ProtoBuf.metalock() do
        if !isassigned(__meta_EKF_msg)
            __meta_EKF_msg[] = target = ProtoMeta(EKF_msg)
            allflds = Pair{Symbol,Union{Type,String}}[:position => Vector3_msg, :quaternion => Quaternion_msg, :velocity => Vector3_msg, :acceleration_bias => Vector3_msg, :angular_velocity_bias => Vector3_msg, :angular_velocity => Vector3_msg, :time => Float64]
            meta(target, EKF_msg, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_EKF_msg[]
    end
end
function Base.getproperty(obj::EKF_msg, name::Symbol)
    if name === :position
        return (obj.__protobuf_jl_internal_values[name])::Vector3_msg
    elseif name === :quaternion
        return (obj.__protobuf_jl_internal_values[name])::Quaternion_msg
    elseif name === :velocity
        return (obj.__protobuf_jl_internal_values[name])::Vector3_msg
    elseif name === :acceleration_bias
        return (obj.__protobuf_jl_internal_values[name])::Vector3_msg
    elseif name === :angular_velocity_bias
        return (obj.__protobuf_jl_internal_values[name])::Vector3_msg
    elseif name === :angular_velocity
        return (obj.__protobuf_jl_internal_values[name])::Vector3_msg
    elseif name === :time
        return (obj.__protobuf_jl_internal_values[name])::Float64
    else
        getfield(obj, name)
    end
end

export MotorCmds_msg, MotorCmd_msg, MotorReadings_msg, Motor_msg, EKF_msg, IMU_msg, Vicon_msg, Vector3_msg, Quaternion_msg
