"""
    scan_xy(scanner, x_axis_range, x_axis_num_scans, y_axis_range, y_axis_num_scans; kwargs..)

This function grabs data along the xy-plane. It holds the y-position
constant and moves along the x axis until it reaches the last x point 
and then changes the y-position and repeats. There are five mandatory 
inputs and one optional input that is used only when this function is
called by other functions and the printed messages should be 
surpressed. The user usually doesn't have to use the variable called.

# Arguments
- `scanner`: the structure for all controller connections.
- `x_axis_range::Array`: An array that contains the start and end point
                         of the desired range in the x-direction.
                         (Must be 1 or 2 elements long)
- `x_axis_num_scans::Int`: The number of points/scans the user desires to
                           record along the x-axis.
- `y_axis_range::Array`: Contains the start and end point
                         of the desired range in the
                         y-direction.
                         (Must be 1 or 2 elements long)
- `y_axis_num_scans::Int`: The number of points/scans the user desires 
                           to record along the y-axis.
# Keywords
- `verbose`::Bool: Optional, defaults to: true

# Returns
- Scan2D

# Example
```
scanner = IntensityScan(initialize(lts150), initialize(Scope350MHz), 1, 100)
scan_range_x = [0 2]; scan_range_y = [0 2];
num_points_x = 5; num_points_y =10;

wave_info_xz = scan_xy(
    scanner, scan_range_x, num_points_x, scan_range_y, num_points_y
)
```
"""
function scan_xy(
    scanner,
    x_axis_range,
    x_axis_num_scans,
    y_axis_range,
    y_axis_num_scans;
    verbose=true,
)
    scan_double_axis(
        scanner,
        x_axis_range,
        x_axis_num_scans,
        scan_x,
        y_axis_range,
        y_axis_num_scans,
        move_y_abs;
        verbose=verbose,
    )
    
end

function scan_xz(
    scanner,
    x_axis_range,
    x_axis_num_scans,
    z_axis_range,
    z_axis_num_scans;
    verbose=true,
)
    scan_double_axis(
        scanner,
        x_axis_range,
        x_axis_num_scans,
        scan_x,
        z_axis_range,
        z_axis_num_scans,
        move_z_abs;
        verbose=verbose,
    )
    
end

function scan_yz(
    scanner,
    y_axis_range,
    y_axis_num_scans,
    z_axis_range,
    z_axis_num_scans;
    verbose=true,
)
    scan_double_axis(
        scanner,
        y_axis_range,
        y_axis_num_scans,
        scan_y,
        z_axis_range,
        z_axis_num_scans,
        move_z_abs;
        verbose=verbose,
    )
    
end


function scan_double_axis(
    scanner::IntensityScan,
    first_axis_range,
    first_axis_num_scans,
    scan_first_axis::Function,
    second_axis_range,
    second_axis_num_scans,
    move_second_axis::Function;
    verbose=true,
)
    start_time = time()    
    first_axis = get_axis(scan_first_axis)
    second_axis = get_axis(move_second_axis)
    check_xyz_limits(scanner, second_axis, second_axis_range)
    positions = create_positions_vector(
        second_axis_range,
        second_axis_num_scans,
    )
    wave_info = nothing
    for scan_index in 1:second_axis_num_scans
        if verbose 
            loop_time = time()
            @info "Scanning $first_axis$second_axis-direction: " *
                  "$scan_index/$second_axis_num_scans iterations"
        end
        first_pass = scan_index == 1

        move_second_axis(scanner.xyz, positions[scan_index])

        wave_info_first_axis = scan_first_axis(
            scanner, first_axis_range, first_axis_num_scans;
            verbose=false, 
        )

        if first_pass
            wave_info = Scan2D(
                wave_info_first_axis.scope_info,
                wave_info_first_axis.time,
                scanner.sample_size, 
                first_axis_num_scans, 
                second_axis_num_scans; 
            )
        end

        wave_info.waveform[:, :, scan_index] =
            wave_info_first_axis.waveform
        wave_info.coordinates[:, :, scan_index] =
            wave_info_first_axis.coordinates

        if verbose
            time_left = elapsed_time(loop_time) do elapsed_seconds
                elapsed_seconds * (second_axis_num_scans - scan_index)
            end
            @info "Estimated time remaining: $time_left"
        end
    end

    wave_info
end
