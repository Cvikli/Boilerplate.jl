
test1() = (d = (cus(randn(20)),); d |> map_array(f2))
test2() = (d = ([[2,3],[3,4]]); d |> map_array(f2))
test3() = (d = ([randn(Float32,20)],[[2,3],[3,4]]); d |> map_array(f2))

@code_warntype test1()
#%%
using Boilerplate: @display
@display randn(3)
a = randn(2)
display(a)
@display a
;

#%%

module ASDF
using Boilerplate
using Boilerplate: @track
# Main.dfff = nothing
fnnqqnqqqqqqqqqq(a) = begin 
  system_vars=Dict()
  system_vars["sdf"] = "ffewefe"
  @track :system_vars "owkef2we"
end
end

using .ASDF: fnnqqnqqqqqqqqqq
fnnqqnqqqqqqqqqq(232233)
Main.dfdfg
# println(dffff, Main.dffff)
# using .ASDF: system_vars
using Boilerplate: tracked
@show tracked
tracked


#%%
println(3,4,5, sep=", ")
#%%
using Base
Base.println(args...; sep) = println(join(args, sep), sep="")
println(3,4,5,6; sep=", ") 
