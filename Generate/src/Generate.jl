module Generate

using Groebner

function generate_systems()

    systems = [
        ("noon3", Groebner.noonn(3)),
        ("noon4", Groebner.noonn(4)),
        ("noon5", Groebner.noonn(5)),
        ("cyclic4", Groebner.cyclicn(4)),
        ("cyclic5", Groebner.cyclicn(5)),
        ("katsura3", Groebner.katsuran(3)),
        ("katsura4", Groebner.katsuran(4))
    ]
    
    path = (@__DIR__)*"/../../_assets/systems"
    @info "Writing to $path"
    cd(path)
    for (name, eqs) in systems
        @info "Writing $name"
        dirname = "$name"
        filename = "$name/$name.txt"
        mkpath(dirname)
        io = open(filename, "w")
        println(io, "$(join(map(string, eqs), ",\n"))")
        close(io)
    end
    nothing
end

function generate_markdown()
    md = """
    +++
    title = "Polynomial systems"
    rss = "--"

    tags = ["syntax", "code"]
    +++

    # Polynomial systems

    The list of all available systems.

    \\toc

    """
    path = (@__DIR__)*"/../../_assets/systems"
    @info "Reading from $path"
    cd(path)
    for name in readdir(".")
        filename = "$name/$name.txt"
        md *= "\n#### $name\n\n"
        md *= "[$name](../assets/systems/$filename)"
    end
    writeto = (@__DIR__)*"/../../systems.md"
    @info "Populating $writeto"
    io = open(writeto, "w")
    println(io, md)
    close(io)
    nothing
end

function generate()
    generate_systems()
    generate_markdown()
end

end

