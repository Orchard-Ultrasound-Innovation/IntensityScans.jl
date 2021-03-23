using IntensityScans
using Test

function stub_intensity_scan()
    scans = ["wave_x.jld2", "wave_xy.jld2", "wave_xyz.jld2"]
    scans = joinpath.(@__DIR__, scans)
    return load(scans[1]), load(scans[2]), load(scans[3])
end

params = ScanParameters(
    Medium(), 
    Excitation(), 
    15e6, 
    :Onda_HGL0200_2322, 
    :Onda_AH2020_1238_20dB
)

scan1d, scan2d, scan3d = stub_intensity_scan()

metrics1d = get_metrics(params, scan1d)
metrics2d = get_metrics(params, scan2d)
metrics3d = get_metrics(params, scan3d)

@testset "IntensityScans.jl" begin
    @testset "Plot" begin
        # plot(metrics1d.isppa)
        # plot(metrics1d.ispta)
        # plot(metrics2d.isppa)
        # plot(metrics2d.ispta)
        # plot(metrics3d.isppa; xslice=3) # 2d cross section where measurement index of x axis is 3
        # plot(metrics3d.ispta; yslice=2)
        # plot(metrics3d.ispta; zslice=2)
    end
    # Write your tests here.
    @info metrics1d
end
