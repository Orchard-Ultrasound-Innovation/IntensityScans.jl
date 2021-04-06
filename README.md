# IntensityScans

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Orchard-Ultrasound-Innovation.github.io/IntensityScans.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Orchard-Ultrasound-Innovation.github.io/IntensityScans.jl/dev)
[![Build Status](https://github.com/Orchard-Ultrasound-Innovation/IntensityScans.jl/workflows/CI/badge.svg)](https://github.com/Orchard-Ultrasound-Innovation/IntensityScans.jl/actions)
[![Build Status](https://travis-ci.com/Orchard-Ultrasound-Innovation/IntensityScans.jl.svg?branch=master)](https://travis-ci.com/Orchard-Ultrasound-Innovation/IntensityScans.jl)
[![Coverage](https://codecov.io/gh/Orchard-Ultrasound-Innovation/IntensityScans.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Orchard-Ultrasound-Innovation/IntensityScans.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

# Usage
This package relies on the following packages. To learn more about
configuring and using these packages:
- [ThorlabsLTStage](https://github.com/Orchard-Ultrasound-Innovation/ThorlabsLTStage.jl)
- [TcpInstruments](https://github.com/Orchard-Ultrasound-Innovation/TcpInstruments.jl)
- [HydrophoneCalibrations.jl](https://github.com/Orchard-Ultrasound-Innovation/HydrophoneCalibrations.jl) 

```julia
using IntensityScans
using IntensityScans.ThorlabsLTStage
using IntensityScans.TcpInstruments
using IntensityScans.Unitful


lts = initialize(LTS)
scope = initialize(AgilentDSOX4034A)
channel = 1
number_of_samples = get_data(scope, channel).info.num_points

scanner = IntensityScan(lts, scope, channel, number_of_samples)
scanner = IntensityScan(
    xyz = lts, 
    scope = scope, 
    channel = 1, 
    precapture_delay = 0u"µs",
    sample_size = 65104,
    postmove_delay = 0u"s",
)

wave_x = scan_x(scanner, [0u"m", 100u"mm"], 5)
wave_xy = scan_xy(scanner, [0u"m", 0.1u"m"], 5, [0u"mm", 0.1u"m"], 7)
wave_xyz = scan_xyz(scanner, [0u"m", 0.1u"m"], 3, [0u"m", 0.1u"m"], 3, [0u"m", 0.1u"m"], 3)

save(wave_x)
save(wave_xy; filename="/home/user/scanfolder/myscan")
save(wave_xyz; format=:matlab)

new_info_xy = load("home/user/scanfolder/myscan")

params = ScanParameters(
    medium = Medium(),
    excitation = Excitation(),
    f0 = 15e6,
    hydrophone_id = :Onda_HGL0200_2322,
    preamp_id = :Onda_AH2020_1238_20dB,
)

new_info_xy = compute_metrics(new_info_xy)
wave_xyz = compute_metrics(wave_xyz, params)

plot(wave_x)

plot(new_info_xy)
plot(new_info_xy; isppa=true)
plot(new_info_xy; ispta=true)
plot(new_info_xy; mi=true)

plot(wave_xyz; xslice=0u"m", ispta=true, mi=true)
```
