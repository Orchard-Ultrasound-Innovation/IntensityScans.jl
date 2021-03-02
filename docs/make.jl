using IntensityScans
using Documenter

DocMeta.setdocmeta!(IntensityScans, :DocTestSetup, :(using IntensityScans); recursive=true)

makedocs(;
    modules=[IntensityScans],
    authors="Morten F. Rasmussen <10264458+mofii@users.noreply.github.com> and contributors",
    repo="https://github.com/mofii/IntensityScans.jl/blob/{commit}{path}#{line}",
    sitename="IntensityScans.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mofii.github.io/IntensityScans.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mofii/IntensityScans.jl",
)
