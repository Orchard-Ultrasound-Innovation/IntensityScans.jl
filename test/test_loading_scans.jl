@testset "Scan" begin
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

    metrics1d = compute_metrics(scan1d, params)
    metrics2d = compute_metrics(scan2d, params)
    metrics3d = compute_metrics(scan3d, params)
end
