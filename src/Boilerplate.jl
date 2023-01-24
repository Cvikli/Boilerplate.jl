module Boilerplate
using Base

# include("./Testing.jl")

hello() = println("Hey! I am here, with you!")

export @sizes
export @typeof
export @display

export tracked
export @track


returnparametric(x::Val{V}) where {V} = V  # I guess there is a simpler way... but for now this was enough.

# It is just crazy how many time did I try to convert anything to string like this... Let's make it default...
Base.String(x) = "$x" 

# I hate lambda functions sometime...
noop(vargs...) = nothing 

# push if not exists
push_ifne!(arr, elem) = (!(elem in arr) && push!(arr, elem))

# Curried functions:
Base.filter(f::Function) = L -> Base.filter(f, L)
Base.map(f::Function)    = L -> map(f, L)

# Base.:>(args::NTuple, f::Function) = f(args...)
Base.reshape(s1::Union{Colon, Int}) = arr::AbstractArray -> reshape(arr, s1)
Base.reshape(s1::Union{Colon, Int}, s2::Union{Colon, Int}) = arr::AbstractArray -> reshape(arr, s1, s2)
Base.reshape(s1::Union{Colon, Int}, s2::Union{Colon, Int}, s3::Union{Colon, Int}) = arr::AbstractArray -> reshape(arr, s1, s2, s3)
Base.reshape(s1::Union{Colon, Int}, s2::Union{Colon, Int}, s3::Union{Colon, Int}, s4::Union{Colon, Int}) = arr::AbstractArray -> reshape(arr, s1, s2, s3, s4)

# To handle different nested array structs... Not comprehensive...
map_array(fn::Function, arr::AbstractArray{Float32,N}) where {N} = fn(arr)
map_array(fn::Function, arr::AbstractArray{Int64,N})   where {N} = fn(arr)
map_array(fn::Function, arr::Vector{Function})                   = Vector{Function}(undef, length(arr))
map_array(fn::Function, arr::Vector{T})                where {T} = [map_array(fn, v) for v in arr] # this is a less strict option.
map_array(fn::Function, arr::Array{Array{Float32,N},1})  where N = [map_array(fn, v) for v in arr]
map_array(fn::Function, arr::Array{Array{Int64,N},1})    where N = [map_array(fn, v) for v in arr]
map_array(fn::Function, arr::Array{Array{Function,N},1}) where N = [map_array(fn, v) for v in arr]
map_array(fn::Function, arr::Array{Array{Array{Float32,N},1},1}) where N = [map_array(fn, v) for v in arr]
map_array(fn::Function, arr::Tuple{A})           where {A} = (map_array(fn, arr[1]),)
map_array(fn::Function, arr::Tuple{A,B})         where {A,B} = (map_array(fn, arr[1]), map_array(fn, arr[2]))
map_array(fn::Function, arr::Tuple{A,B,C})       where {A,B,C} = (map_array(fn, arr[1]), map_array(fn, arr[2]), map_array(fn, arr[3]))
map_array(fn::Function, arr::Tuple{A,B,C,D})     where {A,B,C,D} = (map_array(fn, arr[1]), map_array(fn, arr[2]), map_array(fn, arr[3]), map_array(fn, arr[4]))
map_array(fn::Function, arr::Tuple{A,B,C,D,E})   where {A,B,C,D,E} = (map_array(fn, arr[1]), map_array(fn, arr[2]), map_array(fn, arr[3]), map_array(fn, arr[4]), map_array(fn, arr[5]))
map_array(fn::Function, arr::Tuple{A,B,C,D,E,F}) where {A,B,C,D,E,F} = (map_array(fn, arr[1]), map_array(fn, arr[2]), map_array(fn, arr[3]), map_array(fn, arr[4]), map_array(fn, arr[5]), map_array(fn, arr[6]))
map_array(fn::Function) = d -> map_array(fn, d)



map_assign!(a, b::AbstractArray{Float32,N}) where {N} = a .= b
map_assign!(a, b::AbstractArray{Function,1})          = Vector{Function}(undef, length(b))
map_assign!(a, b::AbstractArray)                      = for i = 1:length(b)  map_assign!(a[i], b[i]) end
map_assign!(a, b::Tuple)                              = for i = 1:length(b) map_assign!(a[i], b[i]) end

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

macro get(indexing)  # indexing of Dict... @get dictobj.["TD3_MINI", "TD5_BIG"]
	indexing.head ≠ :. && error("syntax: expected: `d.[ks...]`.")
	dict = indexing.args[1]
	indexing.args[1] = :getindex
	indexing.args[2].head = :tuple
	indexing.args[2].args = [Expr(:tuple, dict); indexing.args[2].args]
	indexing
end

function getfirst(pred, itr)
  for elt = itr
      if pred(elt)
          return elt
      end
  end
  nothing
end


macro async_showerr(ex)
	quote
		t = @async try
			eval($(esc(ex)))
		catch err
			bt = catch_backtrace()
			println()
			showerror(stderr, err, bt)
		end
	end
end
macro asyncsafe(ex)
	quote 
		@async try
			$(esc(ex))
		catch err
			bt = catch_backtrace()
			println()
			showerror(stderr, err, bt)
			println()
		end
	end
end
throttle(fn::Function, delay_ms::Number) = begin
	c = Channel(100)
	counter = 0
	(args...; kw...) -> begin
		# @asyncsafe begin
		# 	counter += 1
		# 	fn_c = counter
		# 	sleep(delay_ms / 1000)
		# 	if counter !== fn_c
		# 		return
		# 	end
		# 	fn(args..., kw...)
    # end
	end
end
throttle(delay_ms::Number) = (fn::Function) -> throttle(fn, delay_ms)


global tracked = Dict()
get_tracked() = begin
	return tracked
end
# is_tracking_disabled() = true
is_tracking_disabled() = false
macro track(var, ex)
	is_tracking_disabled() && return esc(ex)
	res = gensym()
	var_sym = var
	return esc(quote
			$res = $ex;
			!($var_sym in keys(tracked)) && (tracked[$var_sym] = typeof($res)[]);
			push!(tracked[$var_sym], $res)
			$res
	end)
end
macro monitor(functioncall, timer, testtipe)
	res = gensym()
	return esc(quote
		if TI_UP() 
			$timer = time() 
		end 
		$res = $functioncall 
		if TI_UP() 
			dprint(rpad($testtipe,12), fp_2_str(($timer=time()-$timer;)*1000_000),"µs") 
		end 
		$res
	end)
end
macro monitor(functioncall, timer, testtipe, vars, ranges)
	res = gensym()
	blk = Expr(:block)
	for ex in vars.args
			push!(blk.args, :($(sprint(print,ex))))
	end
	isempty(vars.args) || push!(blk.args, :value)
	return esc(quote
		if TI_UP() 
			$timer = time() 
		end 
		$res = $functioncall 
		if TI_UP() 
			dprint(rpad($testtipe,12), fp_2_str(($timer=time()-$timer;)*1000_000),"µs") 
		end 
		if NAN_CHECK() 
			nan_catcher(a, $vars, $(blk.args), $ranges, eᵢ) 
		end
		$res
	end)
end

macro display(ex)
	esc(quote
		# $Zygote.@ignore begin
			# Zygote.@ignore show(stdout, "text/plain", $ex)
			# @show $ex
			# :(println($ex))
			# print($(sprint(Base.show_unquoted, ex)*" = "))
			display($ex)
		# end
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
	#If n is 0 (or missing), clear from cursor to the end of the line. 
	#If n is 1, clear from cursor to beginning of the line. 
	#If n is 2, clear entire line. 
	#Cursor position does not change. 
end

equalize(arrs...) = begin
  ww = minimum(length.(arrs))
	for arr in arrs
		while length(arr) > ww; pop!(arr) end
	end
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

is_it_reproducible(syms::Matrix{Symbol}; silent=false) = is_it_reproducible(syms, silent)
is_it_reproducible(syms::Matrix{Symbol}, silent) = is_it_reproducible.(syms, silent)

is_it_reproducible(syms::Vector{Symbol}; silent=false) = is_it_reproducible(syms, silent)
is_it_reproducible(syms::Vector{Symbol}, silent) = is_it_reproducible.(syms, silent)

is_it_reproducible(sym::Symbol; silent=false) = is_it_reproducible(sym, silent)
is_it_reproducible(sym::Symbol, silent) = begin
	global tracked
	!(sym in keys(tracked)) && ((!silent && println("$sym: doesn't exist!")); return 3)
	length(tracked[sym]) < 2 && ((!silent && println("$sym: isn't ready")); return 2)
	is_last_two_similar(sym, tracked[sym][end], tracked[sym][end-1], silent)
end

is_last_two_similar(sym, arr1, arr2, silent) = begin
	if is_similar(arr1, arr2)
		!silent && println("$sym: ✔")
		return 1
	else
		!silent && println("$sym: asymetry in the data! (something undef or seed wasn't set?)")
		return 0
	end
end

is_similar(arr1::AbstractArray{Int,N},     arr2::AbstractArray{Int,N})     where N = is_similar(Array(arr1), Array(arr2))
is_similar(arr1::AbstractArray{Float32,N}, arr2::AbstractArray{Float32,N}) where N = is_similar(Array(arr1), Array(arr2))
is_similar(arr1::Array{Int,N},             arr2::Array{Int,N})             where N = all(arr1 .== arr2)
is_similar(arr1::Vector{Int32},              arr2::Vector{Int32})                  = all(arr1 .== arr2)
is_similar(arr1::Array{Float32,N},         arr2::Array{Float32,N})         where N = all(isapprox.(arr1, arr2, rtol=3e-3))
is_similar(v1::Float32, v2::Float32)  = isapprox(v1, v2, rtol=3e-3)
is_similar(v1::Int,     v2::Int)      = v1 == v2


# - size(arr, dim)  if dim > rank(arr) , DO a FCKING ERROR PLS... Why we allow it!! OMG
# - @code_warntype silent error has to be corrected!




end  # modul Boilerplate
