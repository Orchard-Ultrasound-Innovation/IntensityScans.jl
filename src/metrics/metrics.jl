using HydrophoneCalibrations

include("tmp_metrics.jl")
include("models.jl")
include("specific_pressure.jl")
include("mechanical_index.jl")

function get_max(coordinates, data)
    max, max_coor = findmax(data)
    return max, coordinates[:, max_coor]
    
end

function get_metrics(params::ScanParameters, scan::Union{Scan1D, Scan2D, Scan3D})
    voltage = scan.waveform
    pressure = voltage * params.calibration_factor

    isppa = intensity_sppa(pressure, params.medium, params.excitation)
    ispta = intensity_spta(pressure, params.medium, params.excitation)
    mi = mechanical_index(pressure, params.excitation)

    isppa_max =  get_max(scan.coordinates, isppa.val)
    ispta_max = get_max(scan.coordinates, ispta.val)
    mi_max = get_max(scan.coordinates, mi.val)

    return ScanMetric(
        params,
        pressure,
        isppa,
        isppa_max,
        ispta,
        ispta_max,
        mi,
        mi_max,
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
