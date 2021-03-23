const volt = typeof(1.0u"V")
const kg_per_m3 = typeof(1.0u"kg/m^3")
const m_per_s = typeof(1.0u"m" / 1.0u"s")
const seconds = typeof(1.0u"s")
const herz = typeof(1.0u"Hz")
const pascal = typeof(1.0u"Pa")

struct Medium
    density::kg_per_m3 # density in kg/m³
    c::m_per_s # speed of sound in m/s
end
Medium() = Medium(1000.0u"kg/m^3", 1480.0u"m/s")

struct Excitation
    f0::herz                # Center frequency in Hz
    pulse_duration::seconds # seconds
    duty_cycle::Float64     # [0,1]
    total_duration::seconds
end
Excitation() = Excitation(5e6u"Hz", 0.1u"s", 1.0, 10u"s")

format_intensity(i) = uconvert(u"W/m^2", i)

"""
    intensity(p::Unitful.Pressure, M::Medium)
    p is expected to be a single number in units of pascal.
    Output unit is W/m².

"""
function intensity(p::Unitful.Pressure, M::Medium)
    return format_intensity(p^2 / (M.density * M.c))
end

