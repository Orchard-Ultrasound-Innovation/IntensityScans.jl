using RecipesBase
using UnitfulRecipes

# TODO: Types/Make immutable
mutable struct ScanMetric
    params
    pressure
    isppa
    isppa_max
    ispta
    ispta_max
    mechanical_index
    mechanical_index_max
end

struct ScanParameters
    medium
    excitation
    hydrophone_id
    preamp_id
    f0
    calibration_factor
end

function ScanParameters(medium, excitation, f0, hydrophone_id, preamp_id = nothing)
    factor = volt_to_pressure(f0, hydrophone_id, preamp_id)
    return ScanParameters(medium, excitation, f0, hydrophone_id, preamp_id, factor)
end

struct IntensitySppa1D
    intensity
end

struct IntensitySppa2D
    intensity
end

struct IntensitySppa3D
    intensity
end

struct IntensitySpta1D
    intensity
end

struct IntensitySpta2D
    intensity
end

struct IntensitySpta3D
    intensity
end

@recipe function plot(sppa::IntensitySppa1D; title="Intensity Sppa 1D", label="intensity", xguide="position")
   return sppa.intensity
end

@recipe function plot(spta::IntensitySpta1D; title="Intensity Spta 1D", label="intensity", xguide="position")
   return spta.intensity
end

@recipe function plot(sppa::IntensitySppa2D; title="Intensity Sppa 2D") 
    seriestype := :heatmap
    return specific_pressure_plot_helper_2d(sppa.intensity)
end

@recipe function plot(spta::IntensitySpta2D; title="Intensity Spta 2D") 
    seriestype := :heatmap
    return specific_pressure_plot_helper_2d(spta.intensity)
end

@recipe function plot(isppa::IntensitySppa3D; title="Intensity Sppa 3D", xslice = nothing, yslice = nothing, zslice = nothing) 
    seriestype := :heatmap
    return specific_pressure_plot_helper_3d(isppa.intensity, xslice, yslice, zslice)
end

@recipe function plot(ispta::IntensitySpta3D; title="Intensity Spta 3D", xslice = nothing, yslice = nothing, zslice = nothing) 
    seriestype := :heatmap
    return specific_pressure_plot_helper_3d(ispta.intensity, xslice, yslice, zslice)
end

function specific_pressure_plot_helper_3d(data, xslice, yslice, zslice)
    if reduce(+, isnothing.([xslice, yslice, zslice])) != 2
        error("Only one of the keyword arguments must be set:
              xslice, yslice, or zslice")
    end
    data_2d = if !isnothing(xslice)
            if xslice < 1 || xslice > size(data, 1)
                error("xslice must be between 1 and $(size(data, 1))")
            end
            data[xslice, :, :]
        elseif !isnothing(yslice)
            if yslice < 1 || yslice > size(data, 2)
                error("xslice must be between 1 and $(size(data, 1))")
            end
            data[:, yslice, :]
        elseif !isnothing(zslice)
            if zslice < 1 || zslice > size(data, 3)
                error("xslice must be between 1 and $(size(data, 1))")
            end
            data[:, :, zslice]
    end
    return specific_pressure_plot_helper_2d(data_2d)
    
end

function specific_pressure_plot_helper_2d(data)
    return string.(1:size(data, 1)), string.(1:size(data, 2)), data
end

