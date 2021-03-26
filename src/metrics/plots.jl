using RecipesBase
using UnitfulRecipes

@recipe function plot(
    metric::Metric{ISPPA, 1}; 
    title=type(metric), 
    label="intensity", 
    axes="nil",
    coordinates = nothing,
)
    axes == "nil" && error("Keyword missing: axes=\"x\" or axes=\"y\"..")
    if isnothing(coordinates)
        error("You must set coordinates from scan in keyword arg:
              ;coordinates=scan1d.coordinates")
    end
    axis = Symbol(axes)
    xguide --> "Position ($(axis) axis)"
    yguide --> "Intensity"
    return string.(get_axis_positions(Val(axis), coordinates)), metric.val
end

@recipe function plot(
    metric::Metric{ISPTA, 1}; 
    title=type(metric), 
    label="intensity", 
    axes="nil",
    coordinates = nothing,
)
    axes == "nil" && error("Keyword missing: axes=\"x\" or axes=\"y\"..")
    if isnothing(coordinates)
        error("You must set coordinates from scan in keyword arg:
              ;coordinates=scan1d.coordinates")
    end
    axis = Symbol(axes)
    xguide --> "Position / Meters ($(axes) axis)"
    yguide --> "Intensity"
    return string.(get_axis_positions(Val(axis), coordinates)), metric.val
end

@recipe function plot(
    metric::Metric{MI, 1}; 
    title=type(metric), 
    label="Mechanical Index", 
    axes="nil",
    coordinates = nothing,
)
    axes == "nil" && error("Keyword missing: axes=\"x\" or axes=\"y\"..")
    if isnothing(coordinates)
        error("You must set coordinates from scan in keyword arg:
              ;coordinates=scan1d.coordinates")
    end
    axis = Symbol(axes)
    xguide --> "Position / Meters ($(axis) axis)"
    yguide --> "Mechanical Index"
    return string.(get_axis_positions(Val(axis), coordinates)), metric.val
end

@recipe function plot(
    metric::Metric{ISPPA, 2}; 
    title=type(metric), 
    axes="nil", 
    coordinates = nothing,
)
    axes == "nil" && error("Keyword missing: axes=\"xy\" or axes=\"yz\"..")
    seriestype := :heatmap
    xguide --> "Position / Meters ($(axes[1]) axis)"
    yguide --> "Position / Meters ($(axes[2]) axis)"

    return plot_2d_metric(metric.val, coordinates, axes)
end

@recipe function plot(
    metric::Metric{ISPTA, 2}; 
    title=type(metric), 
    axes="nil", 
    coordinates = nothing,
)
    axes == "nil" && error("Keyword missing: axes=\"xy\" or axes=\"yz\"..")
    seriestype := :heatmap
    xguide --> "Position / Meters ($(axes[1]) axis)"
    yguide --> "Position / Meters ($(axes[2]) axis)"

    return plot_2d_metric(metric.val, coordinates, axes)
end

@recipe function plot(
    metric::Metric{MI, 2}; 
    title=type(metric), 
    axes="nil", 
    coordinates = nothing,
)
    axes == "nil" && error("Keyword missing: axes=\"xy\" or axes=\"yz\"..")
    seriestype := :heatmap
    xguide --> "Axis $(axes[1])"
    yguide --> "Axis $(axes[2])"

    return plot_2d_metric(metric.val, coordinates, axes)
end

@recipe function plot(
    metric::Metric{ISPPA, 3};
    xslice = NaN, 
    yslice = NaN, 
    zslice = NaN, 
    coordinates = nothing,
    axes="xyz"
)
    seriestype := :heatmap
    slice, slice_axis = get_slice(xslice, yslice, zslice)
    data, axes = plot_3d_metric(
        metric.val, 
        slice,
        slice_axis,
        axes,
        coordinates,
    )
    title --> type(metric) * " ($(slice_axis)slice $slice)"
    xguide --> "Position / Meters ($(axes[1]) axis)"
    yguide --> "Position / Meters ($(axes[2]) axis)"
    return data
end

@recipe function plot(
    metric::Metric{ISPTA, 3}; 
    xslice = NaN, 
    yslice = NaN, 
    zslice = NaN, 
    coordinates = nothing,
    axes="xyz"
)
    seriestype := :heatmap
    slice, slice_axis = get_slice(xslice, yslice, zslice)
    data, axes = plot_3d_metric(
        metric.val, 
        slice,
        slice_axis,
        axes,
        coordinates,
    )
    title --> type(metric) * " ($(slice_axis)slice $slice)"
    xguide --> "Position / Meters ($(axes[1]) axis)"
    yguide --> "Position / Meters ($(axes[2]) axis)"
    return data
end

@recipe function plot(
    metric::Metric{MI, 3}; 
    xslice = NaN, 
    yslice = NaN, 
    zslice = NaN, 
    coordinates = nothing,
    axes="xyz",
)
    seriestype := :heatmap
    slice, slice_axis = get_slice(xslice, yslice, zslice)
    data, axes = plot_3d_metric(
        metric.val, 
        slice,
        slice_axis,
        axes,
        coordinates,
    )
    title --> type(metric) * " ($(slice_axis)slice $slice)"
    xguide --> "Position / Meters ($(axes[1]) axis)"
    yguide --> "Position / Meters ($(axes[2]) axis)"
    return data
end



function plot_3d_metric(
    data, 
    slice, 
    slice_axis, 
    axes,
    coordinates,
)
    if isnothing(coordinates)
        error("You must set coordinates from scan in keyword arg:
              ;coordinates=scan.coordinates")
    end
    if slice isa Unitful.Length
        slice = ustrip(uconvert(u"m", slice))
        positions = get_axis_positions(Val(slice_axis), coordinates)
        slice = findnearest(positions, slice)
    end
    slice_axis_size = get_axis_size(Val(slice_axis), data)
    if slice < 1 || slice > slice_axis_size
        error("$(slice_axis)slice must be between 1 and $slice_axis_size")
    end
    data_2d, axes = slice_data(Val(slice_axis), slice, data, axes)
    plot_data = plot_2d_metric(data_2d, coordinates, axes)
    return plot_data, axes, slice_axis
end

function plot_2d_metric(data, coordinates, axes)
    if isnothing(coordinates)
        error("You must set coordinates from scan in keyword arg:
              ;coordinates=scan.coordinates")
    end
    first_axis, second_axis = Val(Symbol(axes[1])), Val(Symbol(axes[2]))
    return string.(get_axis_positions(first_axis, coordinates)),
           string.(get_axis_positions(second_axis, coordinates)),
           data
end

function get_slice(xslice, yslice, zslice)
    if reduce(+, isnan.([xslice, yslice, zslice])) != 2
        error("Only one of the keyword arguments must be set:
              xslice, yslice, or zslice")
    end
    !isnan(xslice) && return xslice, :x
    !isnan(yslice) && return yslice, :y
    return zslice, :z
end

findnearest(A::AbstractArray,t) = findmin(abs.(A.-t))[2]

slice_data(::Val{:x}, slice, data, axes) = data[slice, :, :], axes[2:3]
slice_data(::Val{:y}, slice, data, axes) = data[:, slice, :], axes[1:2:3]
slice_data(::Val{:z}, slice, data, axes) = data[:, :, slice], axes[1:2]

get_axis_size(::Val{:x}, data) = size(data, 1)
get_axis_size(::Val{:y}, data) = size(data, 2)
get_axis_size(::Val{:z}, data) = size(data, 3)

get_axis_positions(::Val{:x}, coordinates) = coordinates[1, :, 1, 1]
get_axis_positions(::Val{:y}, coordinates) = coordinates[2, 1, :, 1]
get_axis_positions(::Val{:z}, coordinates) = coordinates[3, 1, 1, :]
