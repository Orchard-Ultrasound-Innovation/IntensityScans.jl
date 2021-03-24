mechanical_index_helper(pressure, E) = 
    squeeze(mapslices(p->mechanical_index(p, E), pressure; dims=1))

function mechanical_index(pressure::PressureArray{2}, E::Excitation)
    return mechanical_index_helper(pressure, E)
end

function mechanical_index(pressure::PressureArray{3}, E::Excitation)
    return mechanical_index_helper(pressure, E)
end

function mechanical_index(pressure::PressureArray{4}, E::Excitation) 
    return mechanical_index_helper(pressure, E)
end
