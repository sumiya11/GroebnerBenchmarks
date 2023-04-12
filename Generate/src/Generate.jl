module Generate

using Groebner

struct Metainfo
    nvariables
    ground
    reference
end

const _references = Dict(
    "cyclic" => "Göran Björck and Ralf Fröberg, A faster way to count the solutions of inhomogeneous systems of algebraic equations, with applications to cyclic n-roots, in J. Symbolic Computation (1991) 12, pp 329-336.",
    "katsura" => "S. Katsura, W. Fukuda, S. Inawashiro, N.M. Fujiki and R. Gebauer, Cell Biophysics, Vol 11, pages 309-319, 1987."
)

function generate_systems()

    systems = [
        ("noon3", Groebner.noonn(3), Metainfo(3, ("finite fields", "the rationals"), "--")),
        ("noon4", Groebner.noonn(4), Metainfo(4, ("finite fields", "the rationals"), "--")),
        ("noon5", Groebner.noonn(5), Metainfo(5, ("finite fields", "the rationals"), "--")),
        ("cyclic4", Groebner.cyclicn(4), Metainfo(4, ("finite fields", "the rationals"), _references["cyclic"])),
        ("cyclic5", Groebner.cyclicn(5), Metainfo(5, ("finite fields", "the rationals"), _references["cyclic"])),
        ("katsura3", Groebner.katsuran(3), Metainfo(3, ("finite fields", "the rationals"), _references["katsura"])),
        ("katsura4", Groebner.katsuran(4), Metainfo(4, ("finite fields", "the rationals"), _references["katsura"]))
    ]
    
    path = (@__DIR__)*"/../../webpage/_assets/systems"
    mkpath(path)
    @info "Writing to $path"
    cd(path)
    for (name, eqs, meta) in systems
        @info "Writing $name"
        dirname = "$name"
        mkpath(dirname)

        filename = "$name/metainfo.txt"
        io = open(filename, "w")
        println(io, "$(meta.nvariables)\n$(meta.ground)\n$(meta.reference)\n")
        close(io)

        filename = "$name/$name.txt"
        io = open(filename, "w")
        println(io, "$(join(map(string, eqs), ",\n"))")
        close(io)

        filename = "$name/$name.mpl"
        io = open(filename, "w")
        println(io, "{\n$(join(map(string, eqs), ",\n"))\n}:")
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
    path = (@__DIR__)*"/../../webpage/_assets/systems"
    @info "Reading from $path"
    cd(path)
    for name in readdir(".")
        md *= "\n#### $name\n\n"

        filename = "$name/metainfo.txt"
        io = open(filename, "r")
        nvars, ground, reference = readline(io), readline(io), readline(io)
        md *= "System in $nvars variables over $ground.\n\n"
        md *= "Reference: $reference\n\n"
        close(io)

        filename = "$name/$name.txt"
        md *= "[[txt]](../assets/systems/$filename) "

        filename = "$name/$name.mpl"
        md *= "[[maple]](../assets/systems/$filename)\n"
        
        md *= "\n"
    end
    writeto = (@__DIR__)*"/../../webpage/systems.md"
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

