module IntensityScans

using TcpInstruments
using ThorlabsLTStage
using HydrophoneCalibrations
using IntensityMetrics

using Unitful
using Unitful: s, ms, mm, m

export IntensityScan
export Scan1D, Scan2D, Scan3D
export scan_x, scan_y, scan_z
export scan_xy, scan_xz, scan_yz
export scan_xyz
export save, load

# Metrics
export ScanParameters
export ScanMetric
export compute_metrics, get_metrics
export intensity, intensity_sppa, intensity_spta, mechanical_index


# IntensityMetrics
export Medium, Excitation


include("util.jl")

include("models.jl")
include("plots.jl")

include("single_axis_scan.jl")
include("double_axis_scan.jl")
include("scan_xyz.jl")

include("metrics/metrics.jl")

end
