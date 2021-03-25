using RecipesBase

struct ScanParameters
    medium
    excitation
    hydrophone_id
    preamp_id
    f0
    calibration_factor
end

function ScanParameters(medium, excitation, f0, hydrophone_id, preamp_id = nothing)
    factor = volt_to_pressure(f0, hydrophone_id, preamp_id)
    return ScanParameters(medium, excitation, f0, hydrophone_id, preamp_id, factor)
end

# TODO: Types/Make immutable
struct ScanMetric
    params
    pressure
    isppa
    isppa_max
    ispta
    ispta_max
    mechanical_index
    mechanical_index_max
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
hydrophone = IntensityScan(lts, scope, 100, 1)
```
"""
struct IntensityScan 
    xyz::ThorlabsLTS150
    scope::TcpInstruments.Instr{T} where T <: Oscilloscope
    channel::Int64
    sample_size::Int64
    # TODO calibration::Calibration
end

const Volt = typeof(1.0u"V")

struct Scan1D
    axes::String
    scope_info::TcpInstruments.ScopeInfo
    time::Array{Float64, 1}
    waveform::Array{Volt, 2}
    coordinates::Array{Float64, 2}
    metrics::Union{Nothing, ScanMetric}
end

function Scan1D(
    axes,
    scope_info::TcpInstruments.ScopeInfo,
    time,
    samples_per_waveform::Int64,
    number_of_scanning_points_first_axis::Int64,
)
    waveform = u"V" * zeros(
        samples_per_waveform,
        number_of_scanning_points_first_axis,
    )
    coordinates = zeros(
        3, # number of coordinates. One for each axis: xyz
        number_of_scanning_points_first_axis,
    )
    return Scan1D(axes, scope_info, time, waveform, coordinates, nothing)
end

struct Scan2D
    axes::String
    scope_info::TcpInstruments.ScopeInfo
    time::Array{Float64, 1}
    waveform::Array{Volt, 3}
    coordinates::Array{Float64, 3}
    metrics::Union{Nothing, ScanMetric}
end

function Scan2D(
    axes,
    scope_info,
    time,
    sample_size_of_single_scan,
    number_of_scans_first_axis::Int,
    number_of_scans_second_axis::Int,
)
    waveform = u"V" * zeros(
        sample_size_of_single_scan,
        number_of_scans_first_axis,
        number_of_scans_second_axis,
    )
    coordinates = zeros(
        3, # number of coordinates. One for each axis: xyz
        number_of_scans_first_axis,
        number_of_scans_second_axis,
    )
    return Scan2D(axes, scope_info, time, waveform, coordinates, nothing)
end

struct Scan3D
    axes::String
    scope_info::TcpInstruments.ScopeInfo
    time::Array{Float64, 1}
    waveform::Array{Volt, 4}
    coordinates::Array{Float64, 4}
    metrics::Union{Nothing, ScanMetric}
end

function Scan3D(
    axes,
    scope_info,
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
    coordinates = zeros(
        3, # number of coordinates. One for each axis: xyz
        number_of_scans_first_axis,
        number_of_scans_second_axis,
        number_of_scans_third_axis,
    )

    return Scan3D(axes, scope_info, time, waveform, coordinates, nothing)
end

