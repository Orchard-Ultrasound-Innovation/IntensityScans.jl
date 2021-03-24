@recipe function plot(scan::Scan1D; label="", title="Scan1D", xguide="Measurement Index / 1", yguide="0", xticks=3, colorbar_title="Voltage / V")
    time_unit, scaled_time = autoscale_seconds(scan.time)
    if yguide == "0"
        yguide := "Time / " * time_unit
    else
        yguide := yguide
    end
    seriestype := :heatmap
    scaled_time = round.(scaled_time; digits=2)
    return string.(1:size(scan.coordinates, 2)), string.(scaled_time),  ustrip(scan.waveform)
end

@recipe function plot(scan::Scan2D; label="", title="Scan2D", xguide="Measurement Index / 1", yguide="0", xticks=3, colorbar_title="Voltage / V")
    time_unit, scaled_time = autoscale_seconds(scan.time)
    if yguide == "0"
        yguide := "Time / " * time_unit
    else
        yguide := yguide
    end
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

@recipe function plot(scan::Scan3D; label="", title="Scan3D", xguide="Measurement Index / 1", yguide="0", xticks=3, colorbar_title="Voltage / V")
    time_unit, scaled_time = autoscale_seconds(scan.time)
    if yguide == "0"
        yguide := "Time / " * time_unit
    else
        yguide := yguide
    end
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


