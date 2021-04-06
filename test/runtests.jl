using IntensityScans
using TcpInstruments; using ThorlabsLTStage; using Unitful
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

wave_x = compute_metrics(wave_x, params)
wave_xy = compute_metrics(wave_xy, params)
wave_xyz = compute_metrics(wave_xyz, params)


@testset "IntensityScans.jl" begin
    @testset "Plot" begin
        # plot(metrics1d.isppa)
        # plot(metrics1d.ispta)
        # plot(metrics2d.isppa)
        # plot(metrics2d.ispta)
        # plot(metrics3d.isppa; xslice=3) # 2d cross section where measurement index of x axis is 3
        # plot(metrics3d.ispta; yslice=2)
        # plot(metrics3d.ispta; zslice=2)
        # plot(scan1d)
        # plot(scan2d)
        # plot(scan3d)
    end
    # Write your tests here.
end
