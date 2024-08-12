module Boilerplate

# include("./Testing.jl")

export @sizes
export @typeof
export @display
export @println


# - size(arr, dim)  if dim > rank(arr) , DO a FCKING ERROR PLS... Why we allow it!! OMG
# - @code_warntype silent error has to be corrected!


get_parametric(x::Val{P}) where P = P  # I guess there is a simpler way... but for now this was enough.

# I hate lambda functions sometime...
noop(vargs...) = nothing 

# push if not exists
push_ifne!(arr, elem) = (!(elem in arr) && push!(arr, elem))




# THE size function! Extremly great!
_sizes(arr::AbstractArray{Float64,N})  where {N} = (@info "Float64 in the arrays!!"; [size(arr)...])  # for GPU Float64 is terrible, I always note this! Redefine if you don't like it. 
_sizes(arr::AbstractArray{Float32,N})  where {N} = [size(arr)...]
_sizes(arr::AbstractArray{Int64,N})    where {N} = [size(arr)...]
_sizes(arr::AbstractArray{UInt8,N})    where {N} = [size(arr)...]
_sizes(arr::AbstractArray{Function,N}) where {N} = "Function$([size(arr)...])"
_sizes(arr::AbstractArray)                       = (size(arr, 1) > 0 && length(_sizes(arr[1])) > 0 ? [size(arr)..., _sizes(arr[1])] : [size(arr)...])
_sizes(dict::Dict{Int,AbstractArray})            = Dict(key => sizes(value) for (key, value) in dict)
_sizes(tup::Tuple)   = Tuple(sizes(obj) for obj in tup)
_sizes(v::Int64)     = "Int64"
_sizes(v::Float64)   = "Float64"
_sizes(v::Int32)     = "Int32"
_sizes(v::Nothing)   = "Nothing"
_sizes(v::T) where T = "$T"
sizes(x) = replace(replace("$(_sizes(x))", "Any" => ""), "\""=>"")
macro sizes(arr)
  local hh=esc(arr)
  :(println("@sizes " * $(sprint(Base.show_unquoted, arr)) * " = ", sizes($hh)))
end

macro typeof(exs...)
  blk = Expr(:block)
  for ex in exs
    push!(blk.args, :(println("@typeof " * $(sprint(Base.show_unquoted, ex) * " = "), repr(begin
      value = $(esc(quote
        typeof($ex)
      end))
    end))))
  end
  isempty(exs) || push!(blk.args, :value)
  return blk
end


findfirst_typed(fn::Function, A) = (for (i, a) in enumerate(A) 
	(fn(a) && return i); 
end; return -1)

idxI(arr,i) = [a[i] for a in arr]


macro async_showerr(ex)
	quote 
		@async try
			$(esc(ex))
		catch err
			println()
			showerror(stderr, err, catch_backtrace())
			println()
		end
	end
end
macro asyncsafe(ex) 
	quote 
		@async_showerr $(esc(ex))
	end
end


macro display(ex)
	esc(quote
			display($ex)
	end)
end
macro println(ex)
	esc(quote
		println($ex)
	end)
end

clear_line_up() = begin  
	print("\u1b[1F") #Moves cursor to beginning of the line n (default 1) lines up  
	print("\u1b[2K") # clears  part of the line.
end




export dtt
global dtt = -1e0
macro dtime() 
	nt = gensym()
	quote 
		esc($nt) = time()
		println("$(esc($nt)-esc($dtt)) seconds")
		esc($dtt = $nt)
	end
end



available_memory() = parse(Int, "$(read(`grep MemAvailable /proc/meminfo`))"[14:end-3])



end  # modul Boilerplate
