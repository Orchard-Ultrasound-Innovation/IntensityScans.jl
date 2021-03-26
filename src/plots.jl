@recipe function plot(scan::Scan1D; raw=false, isppa=false, ispta=false, mi=false)
    count = 0
    if raw 
        count += 1
    end
    if isppa 
        count += 1
    end
    if ispta 
        count += 1
    end
    if mi 
        count += 1
    end
    layout := (1, count)
    if raw
        @series begin
        time_unit, scaled_time = autoscale_seconds(scan.time)

        title --> "Scan1D"
        xguide --> "Measurement Index / 1 ($(scan.axes) axis)"
        xticks --> 3
        colorbar_title --> "Voltage / V"
        yguide --> "Time / " * time_unit
        seriestype := :heatmap

        scaled_time = round.(scaled_time; digits=2)
        return string.(1:size(scan.coordinates, 2)), string.(scaled_time),  ustrip(scan.waveform)
        end
    end

    axes --> scan.axes
    coordinates := scan.coordinates

    if isppa
        @series begin
            return scan.metrics.isppa
        end
    end
    if ispta
        @series begin
            return scan.metrics.ispta
        end
    end
    if mi
        @series begin
            return scan.metrics.mechanical_index
        end
    end
end

@recipe function plot(scan::Scan2D; raw=false, isppa=false, ispta=false, mi=false)
    count = 0
    if raw 
        count += 1
    end
    if isppa 
        count += 1
    end
    if ispta 
        count += 1
    end
    if mi 
        count += 1
    end
    layout := (1, count)
    if raw
        @series begin
        time_unit, scaled_time = autoscale_seconds(scan.time)

        title --> "Scan2D"
        xguide --> "Measurement Index / 1",
        yguide --> "Time / " * time_unit
        xticks --> 3
        colorbar_title --> "Voltage / V"
        seriestype := :heatmap

        scaled_time = round.(scaled_time; digits=2)
        waveform = ustrip(scan.waveform)
        waveform = vcat([waveform[:, :, i] for i in 1:size(waveform, 3)]...)
        position_idx = []
        for y in 1:size(scan.coordinates, 3)
            for x in 1:size(scan.coordinates, 2)
                push!(position_idx, "($x, $y)")
            end
        end
        return position_idx, string.(scaled_time),  waveform
        end
    end

    axes --> scan.axes
    coordinates := scan.coordinates

    if isppa
        @series begin
            return scan.metrics.isppa
        end
    end
    if ispta
        @series begin
            return scan.metrics.ispta
        end
    end
    if mi
        @series begin
            return scan.metrics.mechanical_index
        end
    end
end

@recipe function plot(
    scan::Scan3D;
    raw=false,
    isppa=false,
    ispta=false,
    mi=false,
    xslice=NaN,
    yslice=NaN,
    zslice=NaN
)
    count = 0
    if raw 
        count += 1
    end
    if isppa 
        count += 1
    end
    if ispta 
        count += 1
    end
    if mi 
        count += 1
    end
    layout := (1, count)
    if raw
        @series begin
        time_unit, scaled_time = autoscale_seconds(scan.time)

        title --> "Scan3D"
        xguide --> "Measurement Index / 1"
        yguide --> "Time / " * time_unit
        colorbar_title --> "Voltage / V"
        xticks --> 3
        seriestype := :heatmap

        scaled_time = round.(scaled_time; digits=2)
        waveform = ustrip(scan.waveform)
        # Collapse y first. 3rd dimension
        waveform = vcat([waveform[:, :, i, :] for i in 1:size(waveform, 3)]...)
        # Collapse z
        waveform = vcat([waveform[:, :, i] for i in 1:size(waveform, 3)]...)

        position_idx = []
        for z in 1:size(scan.coordinates, 4)
            for y in 1:size(scan.coordinates, 3)
                for x in 1:size(scan.coordinates, 2)
                    push!(position_idx, "($x, $y, $z)")
                end
            end
        end

        return position_idx, string.(scaled_time),  waveform
        end
    end

    coordinates := scan.coordinates
    xslice := xslice
    yslice := yslice
    zslice := zslice

    if isppa
        @series begin
            return scan.metrics.isppa
        end
    end
    if ispta
        @series begin
            return scan.metrics.ispta
        end
    end
    if mi
        @series begin
            return scan.metrics.mechanical_index
        end
    end
end

# TODO: TcpInstruments.autoscale should be made more generic, then use that
function autoscale_seconds(time)
    # temp = filter(x->x != 0, abs.(data.time))
    # @info "test", temp == data.time
    # m = min(temp...)
    unit = "seconds"
    time_array = time
    m = abs(min(time...))
    if m >= 1
    elseif m < 1 && m >= 1e-3
        unit = "ms" # miliseconds
        time_array = time * 1e3
    elseif m < 1e-3 && m >= 1e-6
        unit = "μs" # microseconds
        time_array = time * 1e6
    elseif m < 1e-6 && m >= 1e-9
        unit = "ns" # nanoseconds
        time_array = time * 1e9
    else
        @info "Seconds unit not found"
    end
    return unit, time_array
end


