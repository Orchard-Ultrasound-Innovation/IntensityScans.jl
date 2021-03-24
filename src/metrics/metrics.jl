using HydrophoneCalibrations

PressureArray{x} = Array{T, x} where T <: Union{Unitful.Pressure, Number}

include("tmp_metrics.jl")
include("models.jl")
include("specific_pressure.jl")
include("mechanical_index.jl")

function get_metrics(params::ScanParameters, scan::Union{Scan1D, Scan2D, Scan3D})
    voltage = scan.waveform
    pressure = voltage * params.calibration_factor
    isppa = intensity_sppa(pressure, params.medium, params.excitation)
    isppa_max =  maximum(isppa.intensity)
    ispta = intensity_spta(pressure, params.medium, params.excitation)
    ispta_max = maximum(ispta.intensity)
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
