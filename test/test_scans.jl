@testset "Scan" begin
    @test wave_x.version == v"1"
    @test wave_xy.version == v"1"
    @test wave_xyz.version == v"1"

    @test wave_x.axes == "x"
    @test wave_xy.axes == "xy"
    @test wave_xyz.axes == "xyz"

    @test isnothing(wave_x.metrics)
    @test isnothing(wave_xy.metrics)
    @test isnothing(wave_xyz.metrics)
end
