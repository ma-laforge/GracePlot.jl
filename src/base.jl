#GracePlot base types & core functions
#-------------------------------------------------------------------------------

#==Main type definitions
===============================================================================#

#Data vector type (don't support complex numbers):
typealias DataVec{T<:Real} Vector{T}

#Graph coordinate (zero-based):
typealias GraphCoord Tuple{Int, Int}

#A constant litteral in grace...
#-------------------------------------------------------------------------------
type GraceConstLitteral
	#Basically just a string, but will not be surrounded with quotes when sent...
	s::AbstractString
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
type CanvasAttributes <: AttributeList
	width::AbstractLength
	height::AbstractLength
end
canvas(width::AbstractLength, height::AbstractLength) = CanvasAttributes(width, height)

#-------------------------------------------------------------------------------
type Plot
	pipe::Base.Pipe
	process::Base.Process

	#Width/height stored so user knows what it is
	#>>Smallest of height/width is considered unity by Grace<<
	canvas::CanvasAttributes

	ncols::Int #Number of columns assumed when accessing graphs with GraphCoord
	graphs::Vector{Graph}
	activegraph::Int
	log::Bool #set to true to log commands
end

#-------------------------------------------------------------------------------
type GraphRef
	plot::Plot
	index::Int
end

#-------------------------------------------------------------------------------
type DatasetRef
	graph::GraphRef
	id::Int
end

#-------------------------------------------------------------------------------
type CartesianLimAttributes <: AttributeList
	xmin; xmax
	ymin; ymax
end
eval(genexpr_attriblistbuilder(:limits, CartesianLimAttributes)) #"limits" constructor

#-------------------------------------------------------------------------------
type TextAttributes <: AttributeList
	value::AbstractString
	font
	size
	color
end
eval(genexpr_attriblistbuilder(:text, TextAttributes, reqfieldcnt=1)) #"text" constructor

#-------------------------------------------------------------------------------
type LineAttributes <: AttributeList
	_type
	style
	width
	color
	pattern
end
eval(genexpr_attriblistbuilder(:line, LineAttributes, reqfieldcnt=0)) #"line" constructor

#-------------------------------------------------------------------------------
type GlyphAttributes <: AttributeList #Don't use "Symbol" - name used by Julia
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
eval(genexpr_attriblistbuilder(:glyph, GlyphAttributes, reqfieldcnt=0)) #"glyph" constructor

#-------------------------------------------------------------------------------
type FrameAttributes <: AttributeList
	frametype
	color
	pattern
	bkgndcolor
	bkgndpattern

	linestyle
	linewidth
end

#-------------------------------------------------------------------------------
type LegendAttributes <: AttributeList
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
type AxesAttributes <: AttributeList
	xmin; xmax; ymin; ymax
	xscale; yscale #gconst[:lin/:log/:reciprocal]
	invertx; inverty #gconst[:on/:off]
end
eval(genexpr_attriblistbuilder(:axes, AxesAttributes, reqfieldcnt=0)) #"axes" constructor

#-------------------------------------------------------------------------------
type AxisTickAttributes <: AttributeList #???
	majorspacing
	minortickcount
	placeatrounded
#	autotickdivisions
	direction #in/out/both
end

#Properties for Major/Minor ticks:???
#-------------------------------------------------------------------------------
type TickAttributes <: AttributeList
	size
	color
	linewidth
	linestyle
end


#==Other constructors/accessors
===============================================================================#
function new(; fixedcanvas::Bool=true, template=nothing)
	const defaultcanvasratio = 1.6 #Roughly golden ratio
	canvasarg = fixedcanvas? []: "-free"
		#-free: Stretch canvas to client area
	templatearg = template!=nothing? ["-param" "$template"]: []
	#Other switches:
	#   -dpipe 0: STDIN; -pipe switch seems broken
	cmd = `xmgrace -dpipe 0 -nosafe -noask $canvasarg $templatearg`
	(pipe, process) = open(cmd, "w")
	activegraph = -1 #None active @ start

	#Default width/height (32cm x 20cm - roughly golden ratio):
	const c = 0.01 #centi
	h = 20c; w = h*defaultcanvasratio
	ncols = 2 #Assume 2 graph columns, by default

	plot = Plot(pipe, process, canvas(Meter(w), Meter(h)), ncols,
		Graph[Graph()], activegraph, false
	)
	#At this point, plot.canvas is still basically meaningless...

	#Only update plot canvas size (send to xmgrace) if not reading template...
	#(Template might already have a canvas size set)
	#...So when templates are used, the value of plot.canvas is meaningless...
	if nothing == template
		set(plot, plot.canvas)
		arrange(plot, (1, 1)) #Fit plot to new canvas size
	end

	return plot
end

Plot() = new() #Alias for code using type name for constructor.

graphindex(g::GraphRef) = g.index
graph(p::Plot, idx::Int) = GraphRef(p, idx)
graph(p::Plot, coord::GraphCoord) =
	((row,col) = coord; return GraphRef(p, p.ncols*row+col))
graphdata(g::GraphRef) = g.plot.graphs[graphindex(g)+1]

#==Communication
===============================================================================#
function sendcmd(p::Plot, cmd::AbstractString)
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
escapequotes(s::AbstractString) = replace(s, r"\"", "\\\"")


#Last line
