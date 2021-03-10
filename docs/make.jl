using IntensityScans
using Documenter

DocMeta.setdocmeta!(IntensityScans, :DocTestSetup, :(using IntensityScans); recursive=true)

makedocs(;
    modules=[IntensityScans],
    authors="Morten F. Rasmussen <10264458+mofii@users.noreply.github.com> and contributors",
    repo="https://github.com/Orchard-Ultrasound-Innovation/IntensityScans.jl/blob/{commit}{path}#{line}",
    sitename="IntensityScans.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Orchard-Ultrasound-Innovation.github.io/IntensityScans.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Orchard-Ultrasound-Innovation/IntensityScans.jl",
)
