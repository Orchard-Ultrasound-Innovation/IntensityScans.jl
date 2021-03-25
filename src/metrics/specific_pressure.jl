# TODO: This could be the IntensityMetrics.intensity_sppa function
function calc_intensity_sppa(pressure, medium, excitation)
    intensities = u"s" * mapreduce(
        p -> intensity(p, medium), +, pressure; dims=1
    ) 
    return squeeze(intensities / (excitation.pulse_duration * 10_000u"cm^2/m^2"))
end

function intensity_sppa(pressure::PressureArray{2}, medium, excitation)
    intensities = calc_intensity_sppa(pressure, medium, excitation)
    return Metric{ISPPA, 1}(intensities)
end

function intensity_sppa(pressure::PressureArray{3}, medium, excitation)
    intensities = calc_intensity_sppa(pressure, medium, excitation)
    return Metric{ISPPA, 2}(intensities)
end

function intensity_sppa(pressure::PressureArray{4}, medium, excitation)
    intensities = calc_intensity_sppa(pressure, medium, excitation)
    return Metric{ISPPA, 3}(intensities)
end


calc_intensity_spta(p, M, E) = intensity_sppa(p, M, E).val * E.duty_cycle # W/cm²

"""
    intensity_spta(p::Unitful.Pressure, M::Medium, E::Excitation)
    Spatial Peak, Time Averaged Intensity.
    Spatial Peak, Time Averaged Intensity.
    p is expected to be a vector/time series containing only the measured pressure from the excitation pulse.
    Output unit is W/cm².
"""
intensity_spta(pressure::PressureArray{2}, medium, excitation) =
    Metric{ISPTA, 1}(calc_intensity_spta(pressure, medium, excitation))

intensity_spta(pressure::PressureArray{3}, medium, excitation) =
    Metric{ISPTA, 2}(calc_intensity_spta(pressure, medium, excitation))

intensity_spta(pressure::PressureArray{4}, medium, excitation) =
    Metric{ISPTA, 3}(calc_intensity_spta(pressure, medium, excitation))
