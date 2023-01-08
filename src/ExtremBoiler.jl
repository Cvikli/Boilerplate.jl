module ExtremBoiler
import Base

struct VectorLength
  len::Int
end
L = VectorLength(1)
export L
@inline Base.:*(m::Int, l::VectorLength) = VectorLength(m * l.len)
@inline Base.:(==)(arr::AbstractArray, l::VectorLength) = length(arr) == l
@inline Base.:(==)(l::VectorLength, arr::AbstractArray) = length(arr) == l
@inline Base.:(==)(l::VectorLength, arr::Int) = arr == l.len
@inline Base.:(==)(arr::Int, l::VectorLength) = arr == l.len

end
#%%
# import .ExtremBoiler: L
# a = randn(2)
# @show a == 2L
# @show length(a)
# @show length(a) == 2
# @show a == 2
# 3 == 3L
# # (3L).len
# #%%
# a = rand(1280000) # ≈10 Mb
# 1234 |> format_bytes |> println