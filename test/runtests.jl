using IntensityScans
using IntensityScans: Metric
using TcpInstruments
using ThorlabsLTStage
using Unitful

using Test

include("emulate_scan.jl")

@testset "IntensityScans.jl" begin
    include("test_scans.jl")
    include("test_metrics.jl")
    include("test_loading_scans.jl")
end
