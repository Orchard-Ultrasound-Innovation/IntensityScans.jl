function calc_intensity_sppa(pressure::PressureArray{2}, medium, excitation)
    intensity_sppa(pressure, medium, excitation)
    return Metric{ISPPA, 1}(intensity_sppa(pressure, medium, excitation))
end

function calc_intensity_sppa(pressure::PressureArray{3}, medium, excitation)
    intensity_sppa(pressure, medium, excitation)
    return Metric{ISPPA, 2}(intensity_sppa(pressure, medium, excitation))
end

function calc_intensity_sppa(pressure::PressureArray{4}, medium, excitation)
    return Metric{ISPPA, 3}(intensity_sppa(pressure, medium, excitation))
end


"""
    intensity_spta(p::Unitful.Pressure, M::Medium, E::Excitation)
    Spatial Peak, Time Averaged Intensity.
    Spatial Peak, Time Averaged Intensity.
    p is expected to be a vector/time series containing only the measured pressure from the excitation pulse.
    Output unit is W/cm².
"""
calc_intensity_spta(pressure::PressureArray{2}, medium, excitation) =
    Metric{ISPTA, 1}(intensity_spta(pressure, medium, excitation))

calc_intensity_spta(pressure::PressureArray{3}, medium, excitation) =
    Metric{ISPTA, 2}(intensity_spta(pressure, medium, excitation))

calc_intensity_spta(pressure::PressureArray{4}, medium, excitation) =
    Metric{ISPTA, 3}(intensity_spta(pressure, medium, excitation))
