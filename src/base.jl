#GracePlot base types & core functions

#==Type definitions
===============================================================================#

#Data vector type (don't support complex numbers):
typealias DataVec{T<:Real} Vector{T}

#Graph coordinate (zero-based):
typealias GraphCoord NTuple{Int, Int}

#Map property fields to grace commands:
typealias PropertyCmdMap Dict{Symbol, String}

#Map a high-level property to a setter function:
typealias PropertyFunctionMap Dict{Symbol, Function}

abstract PropType

#Map a "PropType" property to a setter function:
#(Does not need to be "set" using keyword arguments)
#TODO: Find way to restrict Dict to DataTypes inherited from PropType?
typealias PropTypeFunctionMap Dict{DataType, Function}

#A constant litteral in grace...
#-------------------------------------------------------------------------------
type GraceConstLitteral
	#Basically just a string, but will not be surrounded with quotes when sent...
	s::String
end

#-------------------------------------------------------------------------------
type Dataset
	x::DataVec
	y::DataVec
end

#-------------------------------------------------------------------------------
type Graph
	datasetcount::Int

	Graph() = new(0)
end

#-------------------------------------------------------------------------------
type Plot
	pipe::Base.Pipe
	process::Base.Process
	gdim::GraphCoord
	graphs::Vector{Graph}
	activegraph::Int
	log::Bool #set to true to log commands
end

#-------------------------------------------------------------------------------
type GraphRef
	plot::Plot
	coord::GraphCoord
end
GraphRef(p::Plot, idx::Int) = GraphRef(p, (idx, 0))

#-------------------------------------------------------------------------------
type DatasetRef
	graph::GraphRef
	id::Int
end

#-------------------------------------------------------------------------------
type TextProp <: PropType
	value::String
	font
	size
	color
end
eval(expr_propobjbuilder(:text, TextProp, reqfieldcnt=1)) #"text" constructor

#-------------------------------------------------------------------------------
type LineProp <: PropType
	_type
	style
	width
	color
	pattern
end
eval(expr_propobjbuilder(:line, LineProp, reqfieldcnt=0)) #"line" constructor

#-------------------------------------------------------------------------------
type GlyphProp <: PropType #Don't use "Symbol" - name used by Julia
	_type
	size
	color
	pattern
	fillcolor
	fillpattern
	linewidth
	linestyle
	char #ASCII value: Use a letter as a glyph?
	charfont
	skipcount
end
eval(expr_propobjbuilder(:glyph, GlyphProp, reqfieldcnt=0)) #"glyph" constructor

#-------------------------------------------------------------------------------
type FrameProp <: PropType
	frametype
	color
	pattern
	bkgndcolor
	bkgndpattern

	linestyle
	linewidth
end

#-------------------------------------------------------------------------------
type LegendProp <: PropType
	font
	charsize
	color

	boxcolor
	boxpattern
	boxlinewidth
	boxlinestyle
	boxfillcolor
	boxfillpattern
end

#-------------------------------------------------------------------------------
type AxesProp <: PropType
	xmin; xmax; ymin; ymax
	xscale; yscale #gconst[:lin/:log/:reciprocal]
	invertx; inverty #gconst[:on/:off]
end
eval(expr_propobjbuilder(:axes, AxesProp, reqfieldcnt=0)) #"axes" constructor

#-------------------------------------------------------------------------------
type AxisTickProp <: PropType #???
	majorspacing
	minortickcount
	placeatrounded
#	autotickdivisions
	direction #in/out/both
end

#Properties for Major/Minor ticks:???
#-------------------------------------------------------------------------------
type TickProp <: PropType
	size
	color
	linewidth
	linestyle
end

#==Other constructors/accessors
===============================================================================#
function new(; fixedcanvas::Bool=true, template=nothing)
	canvasarg = fixedcanvas? []: "-free"
		#-free: Stretch canvas to client area
	templatearg = template!=nothing? ["-param" "$template"]: []
	#Other switches:
	#   -dpipe 0: STDIN; -pipe switch seems broken
	cmd = `xmgrace -dpipe 0 -nosafe -noask $canvasarg $templatearg`
	(pipe, process) = open(cmd, "w")
	activegraph = -1 #None active @ start
	return Plot(pipe, process, (0, 0), Graph[Graph()], activegraph, false)
end

Plot() = new() #Alias for code using type name for constructor.

graphindex(g::GraphRef) = ((row,col)=g.coord; return g.plot.gdim[2]*row+col)
graph(p::Plot, args...) = GraphRef(p, args...) #Link constructor to exported function
graphdata(g::GraphRef) = g.plot.graphs[graphindex(g)+1]

#==Communication
===============================================================================#
function sendcmd(p::Plot, cmd::String)
	write(p.pipe, cmd)
	write(p.pipe, "\n")
	if p.log; info("$cmd\n"); end
end

function flushpipe(p::Plot)
	flush(p.pipe)
end

Base.close(p::Plot) = sendcmd(p, "EXIT")
#Base.close(p::Plot) = kill(p.process)


#==Other helper functions
===============================================================================#

#Escape all quotes from a string expression.
#-------------------------------------------------------------------------------
escapequotes(s::String) = replace(s, r"\"", "\\\"")

#-------------------------------------------------------------------------------
function sendpropchangecmd(p::Plot, cmd::String, value::Any) #Catchall
	sendcmd(p, "$cmd $value")
end
function sendpropchangecmd(p::Plot, cmd::String, value::String)
	sendcmd(p, "$cmd \"$value\"") #Add quotes around string
end
function sendpropchangecmd(p::Plot, cmd::String, value::GraceConstLitteral)
	sendcmd(p, "$cmd $(value.s)") #Send associated string, unquoted
end

#Set graph properties for a given element:
#-------------------------------------------------------------------------------
function applypropchanges(g::GraphRef, fmap::PropertyCmdMap, prefix::String, data::Any)
	setactive(g)

	for prop in names(data)
		v = eval(:($data.$prop))

		if v != nothing
			subcmd = get(fmap, prop, nothing)

			if subcmd != nothing
				sendpropchangecmd(g.plot, "$prefix$subcmd", v)
			else
				dtype = typeof(data)
				warn("Property \"$prop\" of $dtype not currently supported.")
			end
		end
	end
end

#Set dataset properties:
#-------------------------------------------------------------------------------
function applydatasetpropchanges(ds::DatasetRef, fmap::PropertyCmdMap, data::Any)
	dsid = ds.id
	applypropchanges(ds.graph, fmap::PropertyCmdMap, "S$dsid ", data::Any)
end

#Core algorithm for "set" interface:
#-------------------------------------------------------------------------------
function set(obj::Any, ptmap::PropTypeFunctionMap, fnmap::PropertyFunctionMap, args...; kwargs...)
	for value in args
		setfn = get(ptmap, typeof(value), nothing)

		if setfn != nothing
			setfn(obj, value)
		else
			argstr = string(typeof(value))
			objtype = typeof(obj)
			warn("Argument \"$argstr\" not recognized by \"set(::$objtype, ...)\"")
		end
	end

	for (arg, value) in kwargs
		setfn = get(fnmap, arg, nothing)

		if setfn != nothing
			setfn(obj, value)
		else
			argstr = string(arg)
			objtype = typeof(obj)
			warn("Argument \"$argstr\" not recognized by \"set(::$objtype, ...)\"")
		end
	end
	return
end

#Last line
