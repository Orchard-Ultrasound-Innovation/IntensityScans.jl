"""
TODO: Rewrite
function wave_info_vol = ky_hydro_scan_volume(settings, x_range, x_num, y_range, y_num, z_range, z_num, called)
 wave_info_vol = ky_hydro_scan_volume(settings, x_range, x_num, y_range, y_num, z_range, z_num, called)

 This function grabs data along the xyz-axis. It holds the z-position
 constant and calls the xy_scan function. This function scans along the x
 axis until it reaches the last x point and then moves along the y axis
 and repeats the process. After completing the xy scan, the z-position is
 changed and then the process is repeated. There are five mantadory inputs
 and one optional input that is used only when this function is called by 
 other functions and the printed messages should be surpressed. The user 
 usually doesn't have to use the variable called.

 Input:
       settings: The structure for all controller connections.
        x_range: A 1x2 or 1x1 array that contains the start and end point
                 of the desired range in the x-direction.
          x_num: The number of points the user desires to record along the
                 x-axis.
        y_range: A 1x2 or 1x1 array that contains the start and end point
                 of the desired range in the y-direction.
          y_num: The number of points the user desires to record along the
                 y-axis.
        z_range: A 1x2 or 1x1 array that contains the start and end point
                 of the desired range in the z-direction.
          z_num: The number of points the user desires to record along the
                 z-axis.

 Output:
   wave_info_xy: A structure that contains the data of the waveforms and
                 the coordinates travelled. The waveforms are stored under
                 wave_info_vol.wave_form and the coordinates travelled are 
                 stored under wave_info_vol.coordinates. The coordinates 
                 are the (x, y, z) coordinates along the path that the 
                 function took.

 Example:
 scan_range_x = [0 2]; scan_range_y = [0 2]; scan_range_z = [0 2];
 num_points_x = 5; num_points_y = 10; num_points_z = 10;
 wave_info_vol = ky_hydro_scan_volume(settings, scan_range_x, num_points_x, scan_range_y, num_points_y, scan_range_z, num_points_z)

"""
function scan_xyz(
    scanner,
    x_range,
    x_num_scans,
    y_range,
    y_num_scans,
    z_range,
    z_num_scans;
    verbose=true
)
    start_time = time()    
    check_xyz_limits(scanner, "x", x_range)
    check_xyz_limits(scanner, "y", y_range)
    check_xyz_limits(scanner, "z", z_range)
    positions = create_positions_vector(z_range, z_num_scans)
    wave_info = nothing
    for scan_index in 1:z_num_scans
        if verbose 
            loop_time = time()
            @info "Scanning xyz-direction: " *
                  "$scan_index/$z_num_scans iterations"
        end
        first_pass = scan_index == 1

        move_z_abs(scanner.xyz, positions[scan_index])

        wave_info_xy = scan_xy(
            scanner,
            x_range,
            x_num_scans,
            y_range,
            y_num_scans,
            verbose=false, 
        )
        if first_pass
            wave_info = Scan3D(
                wave_info_xy.scope_info,
                wave_info_xy.time,
                scanner.sample_size, 
                x_num_scans, 
                y_num_scans, 
                z_num_scans, 
            )
        end
        wave_info.waveform[:, :, :, scan_index] =
            wave_info_xy.waveform
        wave_info.coordinates[:, :, :, scan_index] =
            wave_info_xy.coordinates

        if verbose
            time_left = elapsed_time(loop_time) do elapsed_seconds
                elapsed_seconds * (z_num_scans - scan_index)
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
