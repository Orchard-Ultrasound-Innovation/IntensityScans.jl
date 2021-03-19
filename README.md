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

```julia
using IntensityScans
# You only need to load the configs if you have aliases you want to access
using TcpInstruments; TcpInstruments.load_config()
using ThorlabsLTStage; ThorlabsLTStage.load_config()

lts = initialize(ThorlabsLTS150)
scope = initialize(AgilentDSOX4034A)
channel = 1
number_of_samples = get_data(scope, channel).info.num_points

scanner = IntensityScan(lts, scope, channel, number_of_samples)

info_x   = scan_x(scanner,   [0, .05], 5)
info_xy  = scan_xy(scanner,  [0, .05], 5, [0, 0.02], 2)
info_xyz = scan_xyz(scanner, [0, .05], 5, [0, 0.02], 2, [0, 0.2], 2)

save(info_x)
save(info_xy; filename="/home/user/scanfolder/myscan")
save(info_xyz; format=:matlab)

new_info_xy = load("home/user/scanfolder/myscan")

plot(new_info_xy)
```
