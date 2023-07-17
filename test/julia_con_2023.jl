
using RelevanceStacktrace
using MLDatasets

# load full training set (I already downloaded them)
train_x, train_y = MNIST()[:]

#%%
# we want to understand the underlying data
using Boilerplate

#%%
@sizes train_x
@sizes train_y

#%%
@typeof train_x
#%%

@display train_x[3:23,6:16,1:2]
#%%
#%%
q=5
@show q
@println q

#%%
using Boilerplate: fieldnames, findfirst_typed
a1 = (randn(Float32, 2,4,2),"a2",rand(1:10,100,5))
fieldnames(a1)

#%%

findfirst_typed(>(0.99), train_x)

#%%
using Boilerplate: @async_showerr

fn() = begin
	sleep(2) 
	@assert false "The error is here!"
end

#%%
t = @async fn()
#%%
t
#%%
@async_showerr fn()
#%%
using Boilerplate: @track
gn() = begin
	sleep(2) 
	@track :ok 5*5*5*3*rand()
	println("Ready...")
	return 3
end
@async_showerr gn()

#%%
using Boilerplate: tracked
tracked[:ok]


#%%







