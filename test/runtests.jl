using IntensityScans
using IntensityScans: Metric
using TcpInstruments
using ThorlabsLTStage
using Unitful

using Test

if false
function stub_intensity_scan()
    scans = ["scan1d.jld2", "scan2d.jld2", "scan3d.jld2"]
    scans = joinpath.(@__DIR__, scans)
    return load(scans[1]), load(scans[2]), load(scans[3])
end

params = ScanParameters(
    medium = Medium(),
    excitation = Excitation(),
    f0 = 15e6,
    hydrophone_id = :Onda_HGL0200_2322,
    preamp_id = :Onda_AH2020_1238_20dB,
)

scan1d, scan2d, scan3d = stub_intensity_scan()

metrics1d = compute_metrics(params, scan1d)
metrics2d = compute_metrics(params, scan2d)
metrics3d = compute_metrics(params, scan3d)
end

scope = initialize(TcpInstruments.FakeDSOX4034A)
lts = initialize(ThorlabsLTStage.FakeLTS)

scanner = IntensityScan(
    xyz = lts,
    scope = scope,
    channel = 1,
    precapture_delay = 0u"µs",
    sample_size =TcpInstruments.num_samples(scope)
)

wave_x = scan_x(scanner, [0u"m", 100u"mm"], 5)
wave_xy = scan_xy(scanner, [0u"m", 0.1u"m"], 5, [0u"mm", 0.1u"m"], 7)
wave_xyz = scan_xyz(scanner, [0u"m", 0.1u"m"], 3, [0u"m", 0.1u"m"], 3, [0u"m", 0.1u"m"], 3)

params = ScanParameters(
    medium = Medium(),
    excitation = Excitation(),
    f0 = 15e6,
    hydrophone_id = :Onda_HGL0200_2322,
    preamp_id = :Onda_AH2020_1238_20dB,
)

metrics_x = compute_metrics(wave_x, params)
metrics_xy = compute_metrics(wave_xy, params)
metrics_xyz = compute_metrics(wave_xyz, params)


@testset "IntensityScans.jl" begin
    @testset "Scan" begin
        @test isnothing(wave_x.metrics)
        @test isnothing(wave_xy.metrics)
        @test isnothing(wave_xyz.metrics)
    end
    @testset "Metrics" begin
        @test metrics_x.metrics isa ScanMetric
        @test metrics_xy.metrics isa ScanMetric
        @test metrics_xyz.metrics isa ScanMetric

        @test metrics_xyz.metrics.isppa isa Metric{:IntensitySPPA, 3}
        @test metrics_xyz.metrics.ispta isa Metric{:IntensitySPTA, 3}
        @test metrics_xyz.metrics.mechanical_index isa Metric{:MechanicalIndex, 3}

        sppa_max, sppa_xyz = metrics_xyz.metrics.isppa_max
        @test sppa_max isa Unitful.Quantity
        @test length(sppa_xyz) == 3
        @test sppa_xyz isa Vector{typeof(1.0u"m")}

        spta_max, spta_xyz = metrics_xyz.metrics.ispta_max
        @test spta_max isa Unitful.Quantity
        @info spta_max
        @test length(spta_xyz) == 3
        @test spta_xyz isa Vector{typeof(1.0u"m")}

        mi_max, mi_xyz = metrics_xyz.metrics.mechanical_index_max 
        @test mi_max isa Float64
        @test length(mi_xyz) == 3
        @test mi_xyz isa Vector{typeof(1.0u"m")}
    end
    # Write your tests here.
end
