#Test code
#-------------------------------------------------------------------------------

#Append the current file path to a filename:
macro filerelpath(fname)
	return :(joinpath(dirname(realpath(@__FILE__)),$fname))
end

#No real test code yet... just run demos:
include("demo1.jl")

:Test_Complete
