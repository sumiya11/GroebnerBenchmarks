module Generate

using Groebner

function generate()
    noon3 = Groebner.noonn(3)
    noon4 = Groebner.noonn(4)
    cyclic4 = Groebner.cyclicn(4)
    
    systems = [
        ("noon3", noon3),
        ("noon4", noon4),
        ("cyclic4", cyclic4)
    ]
    
    path = (@__DIR__)*"/../generated"
    @info "Writing to $path"
    for (name, eqs) in systems
        io = open("$path/$name.txt", "w")
        println(io, eqs)
        close(io)
    end
end

end

