# Boilerplate
**Enhance the productivity** till the skys! 

Most of these are crazy useful function, should be adopted by the Base too.

# Install
```
using Pkg; Pkg.add("Boilerplate")
using Boilerplate
```
later on as it gets registered repository: 
```
] add Boilerplate
using Boilerplate
```
# Fast overview
```julia
using Boilerplate

# UNIVERSAL sizes! Really life saving in any situation! 
a2 = [100,3,4,2]
a1 = (randn(Float32, 100,4,2),a2,(rand(1:10,100,5), randn(Float32,100,9)))

@sizes a1 

# macro typeof! Simplest way lie @show!
@typeof a1

# TRACK anything anytime!
fn(x) = begin
  y=x+8+x*x
  @track :y y  # Suppose the y is a REALLY important and complex structure that you just don't want to return  throught the functions, just for debug purpose. "Let's track!"
  z=y * (x + 4)
  return z
end
fn(3)
@show tracked[:y] # It is an array, so we track every single value that is pushed into it, we just have to know which one are we looking for.

# beautiful print!
@display q = randn(6,3)

using Boilerplate: push_ifne!, findfirst_typed, idxI, @get, @asyncsafe

push_ifne!(a2, 3)
push_ifne!(a2, 4) # Push if not exists
@show a2

# findfirst with that Nothing.... is just very big antipattern, let's just use this instead! I love type stability, so I don't like when something is ambiguous.
@show findfirst_typed(==(7), a2)  # ==(7)  is actually v->v==7 (if someone didn't know)
# I think actually findfirst should be renamed to findfirstsafe or something that means it is a different findfirst then in any other language. (Of course it is beautiful stuff, but sounds like an antipattern)

# and never forget about that we have @edit which is one of the most powerful tool of Julia too!

a3 = idxI.(a1, 1) # of course it isn't that beautiful syntax... but isn't used frequently anyways! It also works from Vector{Matrix[Float32]} or anything...
@typeof a3
@sizes a3

@get tracked.[:y, :y]   # get multiple values from dict like from the arrays in a beautiful way!
fn2(x) = begin
  println(x)
  sleep(x)
end

@async fn2("0.2") # DANGER! In certain situation there are actually no error... silent errors are the deadliest enemies. Has to be zeroed! 
@asyncsafe fn2(0.1)
try 
  @asyncsafe fn2("0.2")
catch e
  println("The error actually catchable!")
  bt = catch_backtrace()
  showerror(stderr, e, bt)
  println()
end
sleep(0.3)
println()
println("These things actually make everything extremly fast to debug!")
```

# Why?
`@show` is extremly useful due to you don't have to do paranthesis. It sounds like a minor thing, but actually this is key. Julia most important fast debug function has to adopt this style as it is extremly fast to type. (Of course in other language you use macros for this, but also that gives crazy amount of boilerplate code, which is cognitive burden and should be reduced as much as possible.) That is why `@sizes` and `@typeof` is also extremly useful. (Ofc, it could be standardised by community, as this is mainly for support my own goal.) 

Some of these boilerplate are so trivial, that it is already on the discourse.julia. I just copied some of them.

# Contribute
If you have any other useful Boilerplate code that automate some of the process or anything! Please don't hesitate to share! We help each other! ;)

# Other productivity tools
- Best stacktrace I am using: https://github.com/Cvikli/RelevanceStacktrace.jl Reduce the error search to ZERO! 
- I will share a lot more. 
   - I have a vscode plugin, that is also extremly useful, I cannot emphasize this. Sadly Python cannot do this this well like julia, actually this is the main reason julia is the best language of 2023. 
   - sysimage creator that is also really great! Also that can precompile packages while keeping it modifiable from outside.
   - PkgResolver system, that could be expanded and added to sysimage so it would automatically find the problem and resolve the package that is in development. This project goal is to reduce the problem to just running one script and resolve package issues.    
