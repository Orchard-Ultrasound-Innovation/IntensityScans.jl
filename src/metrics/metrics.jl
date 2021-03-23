using HydrophoneCalibrations
include("tmp_metrics.jl")
include("models.jl")
include("specific_pressure.jl")

function get_metrics(params::ScanParameters, scan::Union{Scan1D, Scan2D, Scan3D})
    voltage = scan.waveform
    pressure = voltage * params.calibration_factor
    isppa = intensity_sppa(pressure, params.medium, params.excitation)
    isppa_max = 0# TODO:  maximum(isppa)
    ispta = intensity_spta(pressure, params.medium, params.excitation)
    ispta_max = 0# TODO:  maximum(ispta)
    mechanical_index = 0
    mechanical_index_max = 0# TODO:  maximum(mechanical_index)
    return ScanMetric(
        params,
        pressure,
        isppa,
        isppa_max,
        ispta,
        ispta_max,
        mechanical_index,
        mechanical_index_max,
     )
end
