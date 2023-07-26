# Julia productivity enhancement with Boilerplate.jl
using Boilerplate

#%%
using MLDatasets

# load full training set (I already downloaded them)
train_x, train_y = MNIST()[:]
rnd_data = (randn(Float32, 2,4,2),"a2",rand(1:10,10,4))

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
a1 = (randn(Float32, 2,4,2),"a2",rand(1:10,100,5))
fieldnames(a1)

#%%
using Boilerplate: findfirst_typed
findfirst_typed(>(0.99), train_x)

#%%
using Boilerplate: @asyncsafe

fn() = begin
	sleep(2) 
	@assert false "The error is here!"
end

#%%
t = @async fn()
#%%
t
#%%
@asyncsafe fn()
#%%
using Boilerplate: @track
gn() = begin
	sleep(2) 
	@track :ok 5*5*5*3*rand()  # <------
	println("Ready...")
	return 3
end
@asyncsafe gn()

#%%
using Boilerplate: tracked
tracked[:ok]


#%%

String(rnd_data)  # "$rnd_data"






