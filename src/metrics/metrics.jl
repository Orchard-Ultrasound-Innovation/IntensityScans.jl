using HydrophoneCalibrations

include("tmp_metrics.jl")
include("models.jl")
include("specific_pressure.jl")
include("mechanical_index.jl")

function get_metrics(params::ScanParameters, scan::Union{Scan1D, Scan2D, Scan3D})
    voltage = scan.waveform
    pressure = voltage * params.calibration_factor
    isppa = intensity_sppa(pressure, params.medium, params.excitation)
    isppa_max =  maximum(isppa.val)
    ispta = intensity_spta(pressure, params.medium, params.excitation)
    ispta_max = maximum(ispta.val)
    mechanical_idx = mechanical_index(pressure, params.excitation)
    mechanical_index_max = maximum(mechanical_idx) # TODO: Confirm
    return ScanMetric(
        params,
        pressure,
        isppa,
        isppa_max,
        ispta,
        ispta_max,
        mechanical_idx,
        mechanical_index_max,
     )
end

function compute_metrics(params::ScanParameters, scan::Scan1D)
    return Scan1D(
        scan.axes,
        scan.scope_info,
        scan.time,
        scan.waveform,
        scan.coordinates,
        get_metrics(params, scan),
    )
end

function compute_metrics(params::ScanParameters, scan::Scan2D)
    return Scan2D(
        scan.axes,
        scan.scope_info,
        scan.time,
        scan.waveform,
        scan.coordinates,
        get_metrics(params, scan),
    )
end

function compute_metrics(params::ScanParameters, scan::Scan3D)
    return Scan3D(
        scan.axes,
        scan.scope_info,
        scan.time,
        scan.waveform,
        scan.coordinates,
        get_metrics(params, scan),
    )
end
