const PressureArray{x} = Array{T, x} where T <: Union{Unitful.Pressure, Number}

squeeze(A::PressureArray{2}) = A[1, :]
squeeze(A::PressureArray{3}) = A[1, :, :]
squeeze(A::PressureArray{4}) = A[1, :, :, :]

const ISPPA = :IntensitySPPA
const ISPTA = :IntensitySPTA
const MI = :MechanicalIndex

struct Metric{T, D}
    val
end

type(a::Metric{ISPPA, T}) where T = "Intensity SPPA $(T)D"
type(a::Metric{ISPTA, T}) where T = "Intensity SPTA $(T)D"
type(a::Metric{MI, T}) where T = "Mechanical Index $(T)D"
