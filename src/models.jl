using Base: @kwdef 
using RecipesBase

const PressureArray{x} = Array{T, x} where T <: Union{Unitful.Pressure, Number}
const Volt = typeof(1.0u"V")
const Meter = typeof(1.0u"m")


squeeze(A::PressureArray{2}) = A[1, :]
squeeze(A::PressureArray{3}) = A[1, :, :]
squeeze(A::PressureArray{4}) = A[1, :, :, :]

const ISPPA = :IntensitySPPA
const ISPTA = :IntensitySPTA
const MI = :MechanicalIndex

struct Metric{T, D}
    val::AbstractArray
end

type(a::Metric{ISPPA, T}) where T = "Intensity SPPA $(T)D"
type(a::Metric{ISPTA, T}) where T = "Intensity SPTA $(T)D"
type(a::Metric{MI, T}) where T = "Mechanical Index $(T)D"

@kwdef struct ScanParameters
    medium::Any
    excitation::Any
    f0::Float64
    hydrophone_id::Symbol
    preamp_id::Union{Symbol, Nothing} = nothing
    calibration_factor::typeof(1.0u"Pa/V") = volt_to_pressure(f0, hydrophone_id, preamp_id)
end

# TODO: Types/Make immutable
struct ScanMetric
    params::ScanParameters
    pressure::PressureArray
    isppa::Metric{ISPPA}
    isppa_max::Tuple{Unitful.Quantity, Vector{Meter}}
    ispta::Metric{ISPTA}
    ispta_max::Tuple{Unitful.Quantity, Vector{Meter}}
    mechanical_index::Metric{MI}
    mechanical_index_max::Tuple{Float64, Vector{Meter}}
end

"""
Input:
       xyz: The handle of desired xyz stage
     scope: Handle of desired scope
   channel: This input decides which channel the scope will read from.
sample_size: The amount of samples desired to be taken.


Ex.
```
lts = initialize(ThorlabsLTS150)
scope = initialize(Scope350MHz)
# Sample size 100, read from scope on channel 1
hydrophone = IntensityScan(xyz = lts, scope scope, channel = 1, sample_size = 100)
```
"""
@kwdef struct IntensityScan 
    xyz::T where T <: LTS
    scope::TcpInstruments.Instr{T} where T <: Oscilloscope
    channel::Int64
    sample_size::Int64
    post_move_delay::typeof(1.0u"s") = 0u"s"
    precapture_delay::typeof(1.0u"s")
    trigger_function::Function = () -> nothing
end

const version = v"1"

struct Scan1D
    version::VersionNumber
    axes::String
    scope_info::TcpInstruments.ScopeInfo
    time::Array{Float64, 1}
    waveform::Array{Volt, 2}
    coordinates::Array{Meter, 2}
    metrics::Union{Nothing, ScanMetric}
end

function Scan1D(
    axes::AbstractString,
    scope_info::TcpInstruments.ScopeInfo,
    time::Array{Float64, 1},
    samples_per_waveform,
    number_of_scanning_points_first_axis,
)
    waveform = u"V" * zeros(
        samples_per_waveform,
        number_of_scanning_points_first_axis,
    )
    coordinates = u"m" * zeros(
        3, # number of coordinates. One for each axis: xyz
        number_of_scanning_points_first_axis,
    )
    return Scan1D(version, axes, scope_info, time, waveform, coordinates, nothing)
end

struct Scan2D
    version::VersionNumber
    axes::String
    scope_info::TcpInstruments.ScopeInfo
    time::Array{Float64, 1}
    waveform::Array{Volt, 3}
    coordinates::Array{Meter, 3}
    metrics::Union{Nothing, ScanMetric}
end

function Scan2D(
    axes::AbstractString,
    scope_info::TcpInstruments.ScopeInfo,
    time::Array{Float64, 1},
    sample_size_of_single_scan,
    number_of_scans_first_axis::Int,
    number_of_scans_second_axis::Int,
)
    waveform = u"V" * zeros(
        sample_size_of_single_scan,
        number_of_scans_first_axis,
        number_of_scans_second_axis,
    )
    coordinates = u"m" * zeros(
        3, # number of coordinates. One for each axis: xyz
        number_of_scans_first_axis,
        number_of_scans_second_axis,
    )
    return Scan2D(version, axes, scope_info, time, waveform, coordinates, nothing)
end

struct Scan3D
    version::VersionNumber
    axes::String
    scope_info::TcpInstruments.ScopeInfo
    time::Array{Float64, 1}
    waveform::Array{Volt, 4}
    coordinates::Array{Meter, 4}
    metrics::Union{Nothing, ScanMetric}
end

function Scan3D(
    axes::AbstractString,
    scope_info::TcpInstruments.ScopeInfo,
    time,
    sample_size_of_single_scan,
    number_of_scans_first_axis,
    number_of_scans_second_axis,
    number_of_scans_third_axis,
)
    waveform = u"V" * zeros(
        sample_size_of_single_scan,
        number_of_scans_first_axis,
        number_of_scans_second_axis,
        number_of_scans_third_axis,
    )
    coordinates = u"m" * zeros(
        3, # number of coordinates. One for each axis: xyz
        number_of_scans_first_axis,
        number_of_scans_second_axis,
        number_of_scans_third_axis,
    )

    return Scan3D(version, axes, scope_info, time, waveform, coordinates, nothing)
end

