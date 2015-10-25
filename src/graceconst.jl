#GracePlot constant literals
#-------------------------------------------------------------------------------


#==Julia Symbol => Grace constants
===============================================================================#

#A constant litteral in grace...
type GraceConstLitteral
	#Basically just a string, but will not be surrounded with quotes when sent...
	s::AbstractString
end

const graceconstmap = Dict{Symbol, GraceConstLitteral}(
	#Booleans:
	:on  => GraceConstLitteral("ON"),
	:off => GraceConstLitteral("OFF"),
	#Axis scales:
	:lin        => GraceConstLitteral("NORMAL"),
	:log        => GraceConstLitteral("LOGARITHMIC"),
	:reciprocal => GraceConstLitteral("RECIPROCAL"),
)

#Last line
