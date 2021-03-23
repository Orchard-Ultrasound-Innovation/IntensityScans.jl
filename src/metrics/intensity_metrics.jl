function convert_to_pressure(scan)
    #vtp = volt_to_pressure(scan.f0, scan.hydrophone, scan.preamp)
    #scan.pressure .= vtp .* scan.waveform
    return nothing
end


function calc_intensity_sppa(scan)
    #scan.isppa .= intensity_sppa(scan.pressure, scan.medium, scan.excitation)
    #scan.isppa_max = maximum(scan.isppa)
    return nothing
end

function calc_intensity_spta(scan)
    #scan.ispta .= intensity_spta(scan.pressure, scan.medium, scan.excitation)
    #scan.ispta_max = maximum(scan.ispta)
    return nothing
end

function calc_mechanical_index(scan)
    #scan.mechanical_index .= mechanical_index(scan.pressure, scan.medium, scan.excitation)
    #scan.mechanical_index_max = maximum(scan.mechanical_index)
    return nothing
end



## From IntensityMetrics:
#function intensity(scan::Scan1DPressure, M::Medium)
#    I = intensity(scan.pressure, M)
#end

function intensity_sppa(
    pressure::Array{T, 2}, M::Medium, E::Excitation
) where T <:Unitful.Pressure
    intensities = mapreduce(p -> intensity(p, M), +, pressure; dims=1)  * u"s"
    adjusted = intensities / (E.pulse_duration * 10_000u"cm^2/m^2")
    return IntensitySppa1D(adjusted[1, :])
end



function intensity_sppa(
    pressure::Array{T, 3}, M::Medium, E::Excitation
) where T <:Unitful.Pressure
    intensities = mapreduce(p -> intensity(p, M), +, pressure; dims=1)  * u"s"
    adjusted = intensities / (E.pulse_duration * 10_000u"cm^2/m^2")
    return IntensitySppa2D(adjusted[1, :, :])
end


"""
    intensity_spta(p::Unitful.Pressure, M::Medium, E::Excitation)
    Spatial Peak, Time Averaged Intensity.
    Spatial Peak, Time Averaged Intensity.
    p is expected to be a vector/time series containing only the measured pressure from the excitation pulse.
    Output unit is W/cm².
"""
function intensity_spta(
    p::Array{T, 3},
    M::Medium,
    E::Excitation,
) where {T<:Union{Unitful.Pressure,Number}}
    i = intensity_sppa(p, M, E) * E.duty_cycle # W/cm²
    return IntensitySpta2D(i)
end
