using RecipesBase
using UnitfulRecipes

@recipe function plot(metric::Metric{ISPPA, 1}; title=type(metric), label="intensity", axes="nil")
    axes == "nil" && error("Keyword missing: axes=\"x\" or axes=\"y\"..")
    xguide --> "Position ($(axes) axis)"
    yguide --> "Intensity"
    return metric.val
end

@recipe function plot(metric::Metric{ISPTA, 1}; title=type(metric), label="intensity", axes="nil")
    axes == "nil" && error("Keyword missing: axes=\"x\" or axes=\"y\"..")
    xguide --> "Position / Meters ($(axes) axis)"
    yguide --> "Intensity"
    return metric.val
end

@recipe function plot(metric::Metric{MI, 1}; title=type(metric), label="Mechanical Index", axes="nil")
    axes == "nil" && error("Keyword missing: axes=\"x\" or axes=\"y\"..")
    xguide --> "Position / Meters ($(axes) axis)"
    yguide --> "Mechanical Index"
    return metric.val
end

@recipe function plot(metric::Metric{ISPPA, 2}; title=type(metric), axes="nil", coordinates = nothing,) 
    axes == "nil" && error("Keyword missing: axes=\"xy\" or axes=\"yz\"..")
    seriestype := :heatmap
    xguide --> "Position / Meters ($(axes[1]) axis)"
    yguide --> "Position / Meters ($(axes[2]) axis)"

    return specific_pressure_plot_helper_2d(metric.val, coordinates, axes)
end

@recipe function plot(metric::Metric{ISPTA, 2}; title=type(metric), axes="nil", coordinates = nothing,) 
    axes == "nil" && error("Keyword missing: axes=\"xy\" or axes=\"yz\"..")
    seriestype := :heatmap
    xguide --> "Position / Meters ($(axes[1]) axis)"
    yguide --> "Position / Meters ($(axes[2]) axis)"
    return specific_pressure_plot_helper_2d(metric.val, coordinates, axes)
end

@recipe function plot(metric::Metric{MI, 2}; title=type(metric), axes="nil", coordinates = nothing,)
    axes == "nil" && error("Keyword missing: axes=\"xy\" or axes=\"yz\"..")
    seriestype := :heatmap
    xguide --> "Axis $(axes[1])"
    yguide --> "Axis $(axes[2])"
    return specific_pressure_plot_helper_2d(metric.val)
end

@recipe function plot(
    metric::Metric{ISPPA, 3};
    title=type(metric),
    xslice = nothing,
    yslice = nothing,
    zslice = nothing,
    coordinates = nothing,
    axes="xyz"
)
    seriestype := :heatmap
    data, axes = specific_pressure_plot_helper_3d(
        metric.val, 
        xslice, 
        yslice, 
        zslice, 
        axes,
        coordinates,
    )
    xguide --> "Position / Meters ($(axes[1]) axis)"
    yguide --> "Position / Meters ($(axes[2]) axis)"
    return data
end

@recipe function plot(
    metric::Metric{ISPTA, 3}; 
    title=type(metric), 
    xslice = nothing, 
    yslice = nothing, 
    zslice = nothing, 
    coordinates = nothing,
    axes="xyz"
)
    seriestype := :heatmap
    data, axes = specific_pressure_plot_helper_3d(
        metric.val, 
        xslice, 
        yslice, 
        zslice, 
        axes,
        coordinates,
    )
    xguide --> "Position / Meters ($(axes[1]) axis)"
    yguide --> "Position / Meters ($(axes[2]) axis)"
    return data
end

@recipe function plot(
    metric::Metric{MI, 3}; 
    title=type(metric), 
    xslice = nothing, 
    yslice = nothing, 
    zslice = nothing, 
    coordinates = nothing,
    axes="xyz",
)
    seriestype := :heatmap
    data, axes = specific_pressure_plot_helper_3d(
        metric.val, 
        xslice, 
        yslice, 
        zslice, 
        axes,
        coordinates,
    )
    xguide --> "Position / Meters ($(axes[1]) axis)"
    yguide --> "Position / Meters ($(axes[2]) axis)"
    return data
end

findnearest(A::AbstractArray,t) = findmin(abs.(A.-t))[2]

#function position_to_coordinate_index

# TODO: Too ugly, refactor. chosen slice variable, dispatch?
# TODO: Meters to index logic might not hold up on translated plane. Revisit
function specific_pressure_plot_helper_3d(data, xslice, yslice, zslice, axes, coordinates)
    if reduce(+, isnothing.([xslice, yslice, zslice])) != 2
        error("Only one of the keyword arguments must be set:
              xslice, yslice, or zslice")
    end
    if isnothing(coordinates)
        error("You must set coordinates from scan in keyword arg:
              ;coordinates=scan3d.coordinates")
    end
    data_2d = if !isnothing(xslice)
            if xslice isa Unitful.Length
                xslice = ustrip(uconvert(u"m", xslice))
                xpositions = coordinates[1, :, 1, 1]
                xslice = findnearest(xpositions, xslice)
            end
            if xslice < 1 || xslice > size(data, 1)
                error("xslice must be between 1 and $(size(data, 1))")
            end
            axes = axes[2:3]
            data[xslice, :, :]
        elseif !isnothing(yslice)
            if yslice isa Unitful.Length
                yslice = ustrip(uconvert(u"m", yslice))
                ypositions = coordinates[2, 1, :, 1]
                yslice = findnearest(ypositions, yslice)
            end
            if yslice < 1 || yslice > size(data, 2)
                error("yslice must be between 1 and $(size(data, 2))")
            end
            axes = axes[1:2:3]
            data[:, yslice, :]
        elseif !isnothing(zslice)
            if zslice isa Unitful.Length
                zslice = ustrip(uconvert(u"m", zslice))
                zpositions = coordinates[3, 1, 1, :]
                zslice = findnearest(zpositions, zslice)
            end
            if zslice < 1 || zslice > size(data, 3)
                error("zslice must be between 1 and $(size(data, 3))")
            end
            axes = axes[1:2]
            data[:, :, zslice]
    end
    return specific_pressure_plot_helper_2d(data_2d, coordinates, axes), axes
    
end

function specific_pressure_plot_helper_2d(data)
    return string.(1:size(data, 1)), string.(1:size(data, 2)), data
end

function specific_pressure_plot_helper_2d(data, coordinates, axes)
    first_axis, second_axis = Val(Symbol(axes[1])), Val(Symbol(axes[2]))
    return string.(get_axis_positions(first_axis, coordinates)),
           string.(get_axis_positions(second_axis, coordinates)),
           data
end

get_axis_positions(::Val{:x}, coordinates) = coordinates[1, :, 1, 1]
get_axis_positions(::Val{:y}, coordinates) = coordinates[2, 1, :, 1]
get_axis_positions(::Val{:z}, coordinates) = coordinates[3, 1, 1, :]

