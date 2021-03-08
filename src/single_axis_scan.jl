using Dates

"""
    scan_x(scanner, x_range, x_num_scans; kwargs..)

Move along the x axis and grab data based on a fixed increment.

# Arguments
- `scanner::IntensityScan`: the structure for all controller connections.
- `x_range`: An array or tuple that contains the start and end 
             point of the desired range in the x-direction.
             (Must be 1 or 2 elements long)
- `x_num_scans::Int`: The number of points/scans the user desires 
                      to record along the x-axis.
# Keywords
- `verbose`::Bool: Optional, defaults to: true

# Returns
- Scan1D

# Example
```
xyz_handle = initialize(ThorlabsLTS150)
scope_handle = initialize(Scope350MHz)
# Sample size 100, read from scope on channel 1
scanner_handle = IntensityScan(xyz_handle, scope_handle, 100, 1)

scan_range_x = [0, 2]
num_points_x = 5

wave_info_x = scan_x(scanner_handle, scan_range_x, num_points_x)
```
"""
function scan_x(
    scanner::IntensityScan, x_range, num_points;
    verbose=true, 
)
    scan_single_axis(
        scanner, x_range, num_points, move_x_abs; verbose=verbose, 
    )
end

"""
    scan_y(scanner, y_axis_range, y_axis_num_scans; kwargs..)

This function moves along the y axis and grabs data based on a fixed
increment passed by the user. 

# Arguments
- `scanner`: the structure for all controller connections.
- `y_axis_range::Array`: Contains the start and end point
                         of the desired range in the
                         y-direction.
                         (Must be 1 or 2 elements long)
- `y_axis_num_scans::Int`: The number of points/scans the user desires 
                           to record along the y-axis.
# Keywords
- `verbose`::Bool: Optional, defaults to: true

# Returns
- Scan1D

# Example
```
xyz_handle = initialize(ThorlabsLTS150)
scope_handle = initialize(Scope350MHz)
# Sample size 100, read from scope on channel 1
scan_handle = IntensityScan(xyz_handle, scope_handle, 100, 1)

scan_range_y = [0 2]
num_points_y =10

wave_info_y = scan_y(scan_handle, scan_range_y, num_points_y)
```
"""
function scan_y(
    scanner, y_range, num_points;
    verbose=true, 
)
    scan_single_axis(
        scanner, y_range, num_points, move_y_abs;
        verbose=verbose, 
    )
end

"""
    scan_z(scan_handle, z_scan_range, num_scans)
This function moves along the z axis and grabs data based on a fixed
increment passed by the user. 

# Arguments
- `scanner`: the structure for all controller connections.
- `z_axis_range::Array`: Contains the start and end point
                         of the desired range in the
                         z-direction.
                         (Must be 1 or 2 elements long)
- `z_axis_num_scans::Int`: The number of points/scans the user desires 
                           to record along the z-axis.
 # Keywords
 - `verbose`: Default true. When false the printed messages should be suppressed (normally used when this function is called by another function)
 # Returns
  - `Scan1D`

# Example
```
xyz_handle = initialize(ThorlabsLTS150)
scope_handle = initialize(Scope350MHz)
# Sample size 100, read from scope on channel 1
scan_handle = IntensityScan(xyz_handle, scope_handle, 100, 1)

scan_range = [0, 1]
num_scans = 5
wave_info_z = scan_z(scan_handle, scan_range, num_scans)
``` 
"""
function scan_z(
    scanner, z_range, num_points;
    verbose=true, 
)
    scan_single_axis(
        scanner, z_range, num_points, move_z_abs;
        verbose=verbose, 
    )
end


function scan_single_axis(
    scanner, axis_range, num_scans, move_func;
    verbose=true, 
)
    start_time = time()
    axis = get_axis(move_func)
    check_xyz_limits(scanner, axis, axis_range)
    positions = create_positions_vector(axis_range, num_scans)
    wave_info = Scan1D(scanner.sample_size, num_scans)

    for scan_index in 1:num_scans
        if verbose 
            loop_time = time()
            @info """
            Scanning $axis-direction: $scan_index/$num_scans iterations
            """
        end

        first_pass = scan_index == 1

        move_func(scanner.xyz, positions[scan_index])

        # TODO: Pausing
        
        data = get_data(scanner.scope, scanner.channel)

        if data.info.num_points != scanner.sample_size
            error("Scope sample size is different from scanner")
        end

        # TODO: if remove_amount_data != 0 trim beginning and end of data

        if first_pass
            wave_info.info = data.info
        end

        wave_info.waveform[:, scan_index] = data.volts
        wave_info.coordinates[:, scan_index] = pos_xyz(scanner.xyz)


        if verbose
            time_left = elapsed_time(loop_time) do elapsed_seconds
                # Multiply seconds this loop took by number of
                # remaining iterations to get approximate end time
                elapsed_seconds * (num_scans - scan_index)
            end
            @info "Estimated time remaining: $time_left"
        end
    end

    if verbose
        @info """
        Done!
        Scan completed from $(axis_range[begin]) to $(axis_range[end])
        Total elapsed time: $(elapsed_time(start_time))
        """
    end

    # TODO: Save data to file
    if verbose
        @info "Saving to file"
    end

    # TODO: Plot
    wave_info

end

function create_positions_vector(axis_range, num_points)
    if length(axis_range) == 1
        if num_points != 1
            error(
                "Can't measure multiple points when axis_range has one"* 
                " position"
            )
        end
        return axis_range
    elseif length(axis_range) == 2
        return range(axis_range[begin], stop=axis_range[end], length=num_points)
    else
        error("axis_range must have 1 or 2 elements")
    end
end

function check_xyz_limits(
    scanner::IntensityScan, axis::AbstractString, axis_range::Array
)
    if axis == "x"
        check_xyz_limits(scanner.xyz.get_limits_x, axis_range)
    elseif axis == "y"
        check_xyz_limits(scanner.xyz.get_limits_y, axis_range)
    elseif axis == "z"
        check_xyz_limits(scanner.xyz.get_limits_z, axis_range)
    else
        error("Single axis must be x, y or z not: $axis")
    end
end

function check_xyz_limits(get_limits::Function, axis_range::Array)
    low_limit, high_limit = get_limits()
    if !axis_range[begin] in low_limit:high_limit || !axis_range[end] in low_limit:high_limit
        error("scan range is outside current limits of the xyz stage")
    end
end

get_axis(move_func::Function) = split(string(move_func), '_')[2] 

