using RecipesBase
using UnitfulRecipes

const PressureArray{x} = Array{T, x} where T <: Union{Unitful.Pressure, Number}

struct IntensitySppa1D
    val
end

struct IntensitySppa2D
    val
end

struct IntensitySppa3D
    val
end

struct IntensitySpta1D
    val
end

struct IntensitySpta2D
    val
end

struct IntensitySpta3D
    val
end

struct MechanicalIndex1D
    val
end

struct MechanicalIndex2D
    val
end

struct MechanicalIndex3D
    val
end

@recipe function plot(sppa::IntensitySppa1D; title="Intensity Sppa 1D", label="intensity", xguide="position")
   return sppa.val
end

@recipe function plot(spta::IntensitySpta1D; title="Intensity Spta 1D", label="intensity", xguide="position")
   return spta.val
end

@recipe function plot(sppa::IntensitySppa2D; title="Intensity Sppa 2D", axes=axes) 
    seriestype := :heatmap
    if !isempty(axes)
        xguide := "Axis $(axes[1])"
        yguide := "Axis $(axes[2])"
    end
    return specific_pressure_plot_helper_2d(sppa.val)
end

@recipe function plot(spta::IntensitySpta2D; title="Intensity Spta 2D", axes=axes) 
    seriestype := :heatmap
    if !isempty(axes)
        xguide := "Axis $(axes[1])"
        yguide := "Axis $(axes[2])"
    end
    return specific_pressure_plot_helper_2d(spta.val)
end

@recipe function plot(isppa::IntensitySppa3D; title="Intensity Sppa 3D", xslice = nothing, yslice = nothing, zslice = nothing, axes="xyz") 
    seriestype := :heatmap
    data, axes = specific_pressure_plot_helper_3d(
        isppa.val, 
        xslice, 
        yslice, 
        zslice, 
        axes
    )
    if !isempty(axes)
        xguide := "Axis $(axes[1])"
        yguide := "Axis $(axes[2])"
    end
    return data
end

@recipe function plot(ispta::IntensitySpta3D; title="Intensity Spta 3D", xslice = nothing, yslice = nothing, zslice = nothing, axes="xyz") 
    seriestype := :heatmap
    data, axes = specific_pressure_plot_helper_3d(
        ispta.val, 
        xslice, 
        yslice, 
        zslice, 
        axes
    )
    if !isempty(axes)
        xguide --> "Axis $(axes[1])"
        yguide --> "Axis $(axes[2])"
    end
    return data
end

function specific_pressure_plot_helper_3d(data, xslice, yslice, zslice, axes)
    if reduce(+, isnothing.([xslice, yslice, zslice])) != 2
        error("Only one of the keyword arguments must be set:
              xslice, yslice, or zslice")
    end
    data_2d = if !isnothing(xslice)
            if xslice < 1 || xslice > size(data, 1)
                error("xslice must be between 1 and $(size(data, 1))")
            end
            axes = axes[2:3]
            data[xslice, :, :]
        elseif !isnothing(yslice)
            if yslice < 1 || yslice > size(data, 2)
                error("yslice must be between 1 and $(size(data, 2))")
            end
            axes = axes[1:2:3]
            data[:, yslice, :]
        elseif !isnothing(zslice)
            if zslice < 1 || zslice > size(data, 3)
                error("zslice must be between 1 and $(size(data, 3))")
            end
            axes = axes[1:2]
            data[:, :, zslice]
    end
    return specific_pressure_plot_helper_2d(data_2d), axes
    
end

function specific_pressure_plot_helper_2d(data)
    return string.(1:size(data, 1)), string.(1:size(data, 2)), data
end

