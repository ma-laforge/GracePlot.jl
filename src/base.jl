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
type TextProp
	value::String
	font
	size
	color
end
#Generate "text" constructor:
eval(expr_propobjbuilder(:text, TextProp, reqfieldcnt=1))

#-------------------------------------------------------------------------------
#	legendtext (associated with dataset)

#-------------------------------------------------------------------------------
type LineProp
	_type
	style
	width
	color
	pattern
end
#trace?
eval(expr_propobjbuilder(:line, LineProp, reqfieldcnt=0))

#-------------------------------------------------------------------------------
type GlyphProp #Don't use name "Symbol" - used by Julia
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
#Generate "linestyle" constructor:
eval(expr_propobjbuilder(:glyph, GlyphProp, reqfieldcnt=0))

#-------------------------------------------------------------------------------
type FrameProp
	frametype
	color
	pattern
	bkgndcolor
	bkgndpattern

	linestyle
	linewidth
end

#-------------------------------------------------------------------------------
type LegendProp
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


#==Other constructors/accessors
===============================================================================#
function new()
	#switches:
	#   -dpipe 0: STDIN; -pipe switch seems broken
	#   -free: Strech canvas to client area
	(pipe, process) = open(`xmgrace -dpipe 0 -nosafe -noask`, "w")
	activegraph = -1 #None active @ start
	return Plot(pipe, process, (0, 0), Graph[Graph()], activegraph, false)
end

Plot() = new() #Alias for code using type name for constructor.

graphindex(g::GraphRef) = ((row,col)=g.coord; return g.plot.gdim[2]*row+col)
graph(p::Plot, args...) = GraphRef(p, args...) #Link to exported function
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
escapequotes(s::String) = replace(s, r"\"", "\\\"")

#Last line
