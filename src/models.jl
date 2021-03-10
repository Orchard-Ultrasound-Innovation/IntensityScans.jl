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
end

mutable struct Scan1D
    scope_info::TcpInstruments.ScopeInfo
    time::Array{Float64, 1}
    data::Array{Float64, 2}
    coordinates::Array{Tuple{Float64, Float64, Float64}, 2}
    function Scan1D(
        samples_per_waveform,
        number_of_scanning_points_first_axis,
    )
        scan_info = new()
        scan_info.data = zeros(
            samples_per_waveform,
            number_of_scanning_points_first_axis,
        )
        scan_info.coordinates = zeros(
            3, # number of coordinates. One for each axis: xyz
            number_of_scanning_points_first_axis,
        )
        return scan_info
    end
end

mutable struct Scan2D
    scop_info::TcpInstruments.ScopeInfo
    time::Array{Float64, 1}
    waveform::Array{Float64, 3}
    coordinates::Array{Tuple{Float64, Float64, Float64}, 3}
    function Scan2D(
        sample_size_of_single_scan,
        number_of_scans_first_axis,
        number_of_scans_second_axis,
    )
        scan_info = new()
        scan_info.waveform = zeros(
            sample_size_of_single_scan,
            number_of_scans_first_axis,
            number_of_scans_second_axis
        )
        scan_info.coordinates = zeros(
            3, # number of coordinates. One for each axis: xyz
            number_of_scans_first_axis,
            number_of_scans_second_axis
        )
        return scan_info
    end
end

mutable struct Scan3D
    scope_info::TcpInstruments.ScopeInfo
    time::Array{Float64, 1}
    waveform::Array{Float64, 4}
    coordinates::Array{Tuple{Float64, Float64, Float64}, 4}
    function Scan3D(
        sample_size_of_single_scan,
        number_of_scans_first_axis,
        number_of_scans_second_axis,
        number_of_scans_third_axis,
    )
        scan_info = new()
        scan_info.waveform = zeros(
            sample_size_of_single_scan,
            number_of_scans_first_axis,
            number_of_scans_second_axis,
            number_of_scans_third_axis,
        )
        scan_info.coordinates = zeros(
            3, # number of coordinates. One for each axis: xyz
            number_of_scans_first_axis,
            number_of_scans_second_axis,
            number_of_scans_third_axis,
        )
        return scan_info
    end
end
