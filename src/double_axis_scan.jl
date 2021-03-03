function scan_xy(
    hydro,
    x_axis_range,
    x_axis_num_scans,
    y_axis_range,
    y_axis_num_scans;
    verbose=true,
    filter=false
)
    scan_double_axis(
        hydro,
        x_axis_range,
        x_axis_num_scans,
        scan_x,
        y_axis_range,
        y_axis_num_scans,
        move_y_abs;
        verbose=verbose,
        filter=filter
    )
    
end

function scan_double_axis(
    hydro::IntensityScan,
    first_axis_range,
    first_axis_num_scans,
    scan_first_axis::Function,
    second_axis_range,
    second_axis_num_scans,
    move_second_axis::Function;
    verbose=true,
    filter=false
)
    start_time = time()    
    first_axis = get_axis(scan_first_axis)
    second_axis = get_axis(move_second_axis)
    check_xyz_limits(hydro, second_axis, second_axis_range)
    positions = create_positions_vector(
        second_axis_range,
        second_axis_num_scans,
    )
    wave_info = Waveinfo(
        hydro.sample_size, 
        first_axis_num_scans, 
        second_axis_num_scans; 
        filter=filter,
    )
    for scan_index in 1:second_axis_num_scans
        if verbose 
            loop_time = time()
            @info "Scanning $first_axis$second_axis-direction: " *
                  "$scan_index/$second_axis_num_scans iterations"
        end
        first_pass = scan_index == 1

        move_second_axis(hydro.xyz, positions[scan_index])

        wave_info_first_axis = scan_first_axis(
            hydro, first_axis_range, first_axis_num_scans;
            verbose=false, filter=filter,
        )
        wave_info.wave_form[:, :, scan_index] =
            wave_info_first_axis.wave_info
        wave_info.coordinates[:, :, scan_index] =
            wave_info_first_axis.coordinates
        # TODO: Ask. Do we want to do this?
        if first_pass
            wave_info.info = wave_info_first_axis.info
        end

        if filter
            wave_info.unfiltered_waveform[:, :, scan_index] =
                wave_info_first_axis.unfiltered_waveform
        end
        if verbose
            time_left = elapsed_time(loop_time) do elapsed_seconds
                elapsed_seconds * (second_axis_num_scans - scan_index)
            end
            @info "Estimated time remaining: $time_left"
        end
    end

    # TODO: Save data to file
    if verbose
        @info "Please implement Saving to file"
    end

    # TODO: Plot
    wave_info
end
