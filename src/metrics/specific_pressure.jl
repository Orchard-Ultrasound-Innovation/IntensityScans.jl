# TODO: This could be the IntensityMetrics.intensity_sppa function
function calc_intensity_sppa(pressure, medium, excitation)
    intensities = u"s" * mapreduce(
        p -> intensity(p, medium), +, pressure; dims=1
    ) 
    return intensities / (excitation.pulse_duration * 10_000u"cm^2/m^2")
end

function intensity_sppa(p::Array{T, 2}, M::Medium, E::Excitation) where 
    {T<:Unitful.Pressure}

    intensities = calc_intensity_sppa(p, M, E)
    return IntensitySppa1D(intensities[1, :])
end

function intensity_sppa(p::Array{T, 3}, M::Medium, E::Excitation) where 
    {T<:Unitful.Pressure}

    intensities = calc_intensity_sppa(p, M, E)
    return IntensitySppa2D(intensities[1, :, :])
end

function intensity_sppa(p::Array{T, 4}, M::Medium, E::Excitation) where 
    {T<:Unitful.Pressure}

    intensities = calc_intensity_sppa(p, M, E)
    return IntensitySppa3D(intensities[1, :, :, :])
end


calc_intensity_spta(p, M, E) = intensity_sppa(p, M, E).intensity * E.duty_cycle # W/cm²

"""
    intensity_spta(p::Unitful.Pressure, M::Medium, E::Excitation)
    Spatial Peak, Time Averaged Intensity.
    Spatial Peak, Time Averaged Intensity.
    p is expected to be a vector/time series containing only the measured pressure from the excitation pulse.
    Output unit is W/cm².
"""
function intensity_spta(p::Array{T, 2}, M::Medium, E::Excitation) where 
    T <: Union{Unitful.Pressure, Number}

    return IntensitySpta1D(calc_intensity_spta(p, M, E))
end

function intensity_spta(p::Array{T, 3}, M::Medium, E::Excitation) where
    T <: Union{Unitful.Pressure, Number}

    return IntensitySpta2D(calc_intensity_spta(p, M, E))
end

function intensity_spta(p::Array{T, 4}, M::Medium, E::Excitation) where
    T <: Union{Unitful.Pressure, Number}

    return IntensitySpta3D(calc_intensity_spta(p, M, E))
end
