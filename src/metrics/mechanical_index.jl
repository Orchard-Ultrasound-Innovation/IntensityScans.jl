mechanical_index_helper(pressure, E) = 
    squeeze(mapslices(p->mechanical_index(p, E), pressure; dims=1))

mechanical_index(pressure::PressureArray{2}, excitation) =
    Metric{MI, 1}(mechanical_index_helper(pressure, excitation))

mechanical_index(pressure::PressureArray{3}, excitation) =
    Metric{MI, 2}(mechanical_index_helper(pressure, excitation))

mechanical_index(pressure::PressureArray{4}, excitation) =
    Metric{MI, 3}(mechanical_index_helper(pressure, excitation))
