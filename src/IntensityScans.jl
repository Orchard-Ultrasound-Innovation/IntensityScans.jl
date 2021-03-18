module IntensityScans

using TcpInstruments
using ThorlabsLTStage
using Unitful


export
    IntensityScan,
    Scan1D,
    Scan2D,
    Scan3D,

    scan_x,
    scan_y,
    scan_z,
    scan_xy,
    scan_xz,
    scan_yz,
    scan_xyz

include("util.jl")

include("models.jl")

include("single_axis_scan.jl")
include("double_axis_scan.jl")
include("scan_xyz.jl")

end
