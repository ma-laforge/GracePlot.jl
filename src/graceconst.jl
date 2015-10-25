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
	#Common
	:none       => GraceConstLitteral("0"), #Linestyle, ..
	#Line styles:
	:solid       => GraceConstLitteral("1"),
	:dot         => GraceConstLitteral("2"),
	:dash        => GraceConstLitteral("3"),
	:ldash       => GraceConstLitteral("4"),
	:dotdash     => GraceConstLitteral("5"),
	:dotldash    => GraceConstLitteral("6"),
	:dotdotdash  => GraceConstLitteral("7"),
	:dotdashdash => GraceConstLitteral("8"),
)

#Last line
