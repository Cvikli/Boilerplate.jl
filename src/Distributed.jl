using Distributed

function Base.collect(c::RemoteChannel)
	content = []
	while isready(c)
		d = take!(c)
		push!(content, d)
	end
	content
end