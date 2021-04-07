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
