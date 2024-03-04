# Julia productivity enhancement with Boilerplate.jl
using Boilerplate

#%%
using MLDatasets

# load full training set (I already downloaded them)
train_x, train_y = MNIST()[:]
rnd_data = (randn(Float32, 2,4,2),"a2",rand(1:10,10,4))
println("Loaded!")
;

#%%  we want to understand the underlying data
@sizes train_x
@sizes train_y
@sizes rnd_data
;
#%%
@typeof train_x
@typeof rnd_data
;
#%%

@display train_x[3:23,6:16,1:1]


#%%
using Boilerplate: fieldnames
struct Param
	Δt::Float64 
	n::Int64
	m::Int64
end

P = Param(0.1, 50, 35)
fieldnames(P)  # fieldnames(typeof(P))

#%%
using Boilerplate: findfirst_typed
findfirst_typed(>(0.99), train_x)

#%%

fn() = begin
	sleep(2) 
	@assert false "The error is here!"
end

#%%
t = @async fn()
#%%
t
#%%
using Boilerplate: @asyncsafe
@asyncsafe fn()
#%%
#%%

String(P)  # "$P"






