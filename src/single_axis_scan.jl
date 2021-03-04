using Dates

"""
 wave_info_x = ky_hydro_scan_x(settings, axis_range, num_points, called)

 This function moves along the x axis and grabs data based on a fixed
 increment passed by the user. This program uses the ky_scope_rs_ch_data
 function that returns a structure with helpful information. There are
 three mantadory inputs and one optional input that is used only when this
 function is called by other functions and the printed messages should be
 supressed. The user usually doesn't have to use the variable called.

 Delete:
       settings: the structure for all controller connections.
 Input: 
     hydrophone: the structure for all controller connections.
        axis_range: A 1x2 or 1x1 array that contains the start and end point
                 of the desired range in the x-direction.
          num_points: The number of points the user desires to record along the
                 x-axis.
         called: This variable is either one or zero and is used to turn
                 off user notifications when another function calls this
                 one. User usually won't have to use this variable.

 Output:
   wave_info_x: A structure that contains the data that traces num_points of
                waveforms and the coordinates travelled. The waveforms are
                stored under wave_info_x.wave_form and the coordinates 
                travelled is stored under wave_info_x.coordinates. The
                coordinates are the (x, y, z) coordinates along the path
                that the function took.

 Example:
 scan_range = [0 1]; num_points = 5;
 wave_info_x = ky_hydro_scan_x(settings, scan_range, num_points);
"""
function scan_x(
    hydro::IntensityScan, x_range, num_points;
    verbose=true, 
)
    scan_single_axis(
        hydro, x_range, num_points, move_x_abs; verbose=verbose, 
    )
end

"""
 This function moves along the y axis and grabs data based on a fixed increment
 passed by the user. There are three mantadory inputs and one optional input
 that is used only when this function is called by other functions and the
 printed messages should be supressed. The user usually doesn't have to use the
 variable called.

 Input: 
     hydrophone: the structure for all controller connections.
        axis_range: A 1x2 or 1x1 array that contains the start and end point
                 of the desired range in the y-direction.
          num_points: The number of points the user desires to record along the
                 y-axis.
         called: This variable is either one or zero and is used to turn
                 off user notifications when another function calls this
                 one. User usually won't have to use this variable.

 Output:
   wave_info_y: A structure that contains the data that traces num_points of
                waveforms and the coordinates travelled. The waveforms are
                stored under wave_info_y.wave_form and the coordinates 
                travelled is stored under wave_info_x.coordinates. The
                coordinates are the (x, y, z) coordinates along the path
                that the function took.

 Example:
 scan_range = [0 1]; num_points = 5;
 wave_info_x = ky_hydro_scan_y(settings, scan_range, num_points);
"""
function scan_y(
    hydro, y_range, num_points;
    verbose=true, 
)
    scan_single_axis(
        hydro, y_range, num_points, move_y_abs;
        verbose=verbose, 
    )
end

"""
 This function moves along the z axis and grabs data based on a fixed
 increment passed by the user. 

 There are three mandatory inputs and one optional keyword.

 when this function is called by other functions and 
 should be supressed.

 # Arguments
 # Keywords
 - `verbose`: Default true. When false the printed messages should be suppressed (normally used when this function is called by another function)
 # Returns
  - `Waveinfo_1D`
A structure that contains the data that traces the number of
waveform scans and the coordinates travelled. The waveforms are
stored under wave_info_x.wave_form and the coordinates 
travelled is stored under wave_info_x.coordinates. The
coordinates are the (x, y, z) coordinates along the path
that the function took.

 Input: 
     hydrophone: the structure for all controller connections.
        axis_range: A 1x2 or 1x1 array that contains the start and end point
                 of the desired range in the z-direction.
          num_points: The number of points the user desires to record along the
                 z-axis.
         called: This variable is either one or zero and is used to turn
                 off user notifications when another function calls this
                 one. User usually won't have to use this variable.

 # Example
xyz_handle = initialize(ThorlabsLTS150)
scope_handle = initialize(Scope350MHz)
# Sample size 100, read from scope on channel 1
scan_handle = IntensityScan(xyz_handle, scope_handle, 100, 1)

scan_range = [0, 1]
num_scans = 5
wave_info_z = scan_z(scan_handle, scan_range, num_scans)
"""
function scan_z(
    hydro, z_range, num_points;
    verbose=true, 
)
    scan_single_axis(
        hydro, z_range, num_points, move_z_abs;
        verbose=verbose, 
    )
end


function scan_single_axis(
    hydro, axis_range, num_scans, move_func;
    verbose=true, 
)
    start_time = time()
    axis = get_axis(move_func)
    check_xyz_limits(hydro, axis, axis_range)
    positions = create_positions_vector(axis_range, num_scans)
    wave_info = Waveinfo_1D(hydro.sample_size, num_scans)

    for scan_index in 1:num_scans
        if verbose 
            loop_time = time()
            @info """
            Scanning $axis-direction: $scan_index/$num_scans iterations
            """
        end

        first_pass = scan_index == 1

        move_func(hydro.xyz, positions[scan_index])

        # TODO: Pausing
        
        data = get_data(hydro.scope, hydro.channel)

        if data.info.num_points != hydro.sample_size
            error("Scope sample size is different from hydrophone")
        end

        # TODO: if remove_amount_data != 0 trim beginning and end of data

        if first_pass
            wave_info.info = data.info
        end

        wave_info.waveform[:, scan_index] = data.volts
        wave_info.coordinates[scan_index] = pos_xyz(hydro.xyz)


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
    hydro::IntensityScan, axis::AbstractString, axis_range::Array
)
    if axis == "x"
        check_xyz_limits(hydro.xyz.get_limits_x, axis_range)
    elseif axis == "y"
        check_xyz_limits(hydro.xyz.get_limits_y, axis_range)
    elseif axis == "z"
        check_xyz_limits(hydro.xyz.get_limits_z, axis_range)
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

