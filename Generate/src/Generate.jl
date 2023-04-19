module Generate

using AbstractAlgebra

struct SystemInfo
    name
    description
    reference
    basering
    variables
    dimension
    isregular
    system
end

function read_system(io)
    readvalue(io) = strip(last(split(readline(io), ":")))
    name = readvalue(io)
    description = readvalue(io)
    reference = readvalue(io)
    basering = readvalue(io)
    variables = readvalue(io)
    dimension = readvalue(io)
    isregular = readvalue(io)
    readline(io)
    system = map(strip, split(read(io, String), ","))
    SystemInfo(
        name,
        description,
        reference,
        basering,
        variables,
        dimension,
        isregular,
        system
    )
end

function read_systems(;path=(@__DIR__)*"/../../systems")
    @info "Reading from $path"
    systems = Vector{SystemInfo}()
    for file in readdir(path)
        io = open("$path/$file", "r")
        systeminfo = read_system(io)
        close(io)
        push!(systems, systeminfo)
    end
    systems
end

function generate_in_different_formats(
        systems; 
        write_to=(@__DIR__)*"/../../webpage/_assets/systems")
    
    mkpath(write_to)
    cd(write_to)
    @info "Writing systems to $write_to"
    for systeminfo in systems
        name, description, reference = systeminfo.name, systeminfo.description, systeminfo.reference
        basering, variables, system = systeminfo.basering, systeminfo.variables, systeminfo.system

        @info "Writing $(systeminfo.name)"
        dirname = "$name"
        mkpath(dirname)

        # write metainformation
        filename = "$name/metainfo.txt"
        io = open(filename, "w")
        println(io, "$(description)\n$(basering)\n$(reference)\n")
        close(io)

        # write in .txt
        filename = "$name/$name.txt"
        io = open(filename, "w")
        println(io, name)
        println(io, variables)
        println(io, "$(join(map(string, system), ",\n"))")
        close(io)

        # write in maple
        filename = "$name/$name.mpl"
        io = open(filename, "w")
        println(io, name)
        println(io, variables)
        println(io, "{\n$(join(map(string, system), ",\n"))\n}:")
        close(io)
    end
    nothing
end

function generate_markdown(
        systems; 
        crossref=nothing,
        write_to=(@__DIR__)*"/../../webpage/systems.md")
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
    for systeminfo in systems
        name, description, reference = systeminfo.name, systeminfo.description, systeminfo.reference
        basering, variables, system = systeminfo.basering, systeminfo.variables, systeminfo.system

        md *= "\n#### $name\n\n"
        md *= "$description\n\n"
        md *= "Reference: $reference\n\n"

        md *= "System over $basering.\n\n"

        filename = "$name/$name.txt"
        md *= "[[txt]](../assets/systems/$filename) "

        filename = "$name/$name.mpl"
        md *= "[[maple]](../assets/systems/$filename)\n"
        
        md *= "\n"
    end
    @info "Populating $write_to"
    io = open(write_to, "w")
    println(io, md)
    close(io)
    nothing
end

function generate()
    systems = read_systems(path=(@__DIR__)*"/../../systems")
    generate_in_different_formats(
        systems, 
        write_to=(@__DIR__)*"/../../webpage/_assets/systems"
    )
    generate_markdown(
        systems,
        crossref=(@__DIR__)*"/../../webpage/_assets/systems",
        write_to=(@__DIR__)*"/../../webpage/systems.md"
    )
end

end
