using RecipesBase
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
    scope_info::TcpInstruments.ScopeInfo
    time::Array{Float64, 1}
    waveform::Array{Volt, 2}
    coordinates::Array{Float64, 2}
    function Scan1D(
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
        return new(scope_info, time, waveform, coordinates)
    end
end

struct Scan2D
    scope_info::TcpInstruments.ScopeInfo
    time::Array{Float64, 1}
    waveform::Array{Volt, 3}
    coordinates::Array{Float64, 3}
    function Scan2D(
        scope_info,
        time,
        sample_size_of_single_scan,
        number_of_scans_first_axis,
        number_of_scans_second_axis,
    )
        waveform = u"V" * zeros(
            sample_size_of_single_scan,
            number_of_scans_first_axis,
            number_of_scans_second_axis
        )
        coordinates = zeros(
            3, # number of coordinates. One for each axis: xyz
            number_of_scans_first_axis,
            number_of_scans_second_axis
        )
        return new(scope_info, time, waveform, coordinates)
    end
end

struct Scan3D
    scope_info::TcpInstruments.ScopeInfo
    time::Array{Float64, 1}
    waveform::Array{Volt, 4}
    coordinates::Array{Float64, 4}
    function Scan3D(
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

        return new(scope_info, time, waveform, coordinates)
    end
end
