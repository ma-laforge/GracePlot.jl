#GracePlot functions to control Grace/xmgrace
#-------------------------------------------------------------------------------

#==Type definitions
===============================================================================#

#Map an individual attribute to a setter function:
typealias AttributeFunctionMap Dict{Symbol, Function}

#Map an "AttributeList" element to a setter function:
#NOTE: Unlike individual attributes, typed obects do not need to be "set"
#      using keyword arguments
#TODO: Find way to restrict Dict to DataTypes inherited from AttributeList
typealias AttributeListFunctionMap Dict{DataType, Function}

#Map attribute fields to grace commands:
typealias AttributeCmdMap Dict{Symbol, AbstractString}


#==Helper functions
===============================================================================#

#Copy in only attributes that are not "nothing" (thus "new"):
function copynew!{T<:AttributeList}(dest::T, newlist::T)
	for attrib in fieldnames(newlist)
		v = eval(:($newlist.$attrib))

		if v != nothing
			eval(:($dest.$attrib=$newlist.$attrib))
		end
	end
end

function setattrib(p::Plot, cmd::AbstractString, value::Any) #Catchall
	sendcmd(p, "$cmd $value")
end
function setattrib(p::Plot, cmd::AbstractString, value::AbstractString)
	sendcmd(p, "$cmd \"$value\"") #Add quotes around string
end
function setattrib(p::Plot, cmd::AbstractString, value::GraceConstLitteral)
	sendcmd(p, "$cmd $(value.s)") #Send associated string, unquoted
end

#Set graph attributes for a given element:
#-------------------------------------------------------------------------------
function setattrib(g::GraphRef, fmap::AttributeCmdMap, prefix::AbstractString, data::Any)
	setactive(g)

	for attrib in fieldnames(data)
		v = eval(:($data.$attrib))

		if v != nothing
			subcmd = get(fmap, attrib, nothing)

			if subcmd != nothing
				setattrib(g.plot, "$prefix$subcmd", v)
			else
				dtype = typeof(data)
				warn("Attribute \"$attrib\" of $dtype not currently supported.")
			end
		end
	end
end

#Set dataset attribute:
#-------------------------------------------------------------------------------
function setattrib(ds::DatasetRef, fmap::AttributeCmdMap, data::Any)
	dsid = ds.id
	setattrib(ds.graph, fmap::AttributeCmdMap, "S$dsid ", data::Any)
end

#Core algorithm for "set" interface:
#-------------------------------------------------------------------------------
function set(obj::Any, listfnmap::AttributeListFunctionMap, fnmap::AttributeFunctionMap, args...; kwargs...)
	for value in args
		setfn = get(listfnmap, typeof(value), nothing)

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

#Core algorithm for "get" interface:
#-------------------------------------------------------------------------------
function getattrib(obj::Any, fnmap::AttributeFunctionMap, attrib::Symbol)
	getfn = get(fnmap, attrib, nothing)

	if nothing == getfn
		argstr = string(attrib)
		objtype = typeof(obj)
		throw("Argument \"$argstr\" not recognized by \"set(::$objtype, ...)\"")
	end

	return getfn(obj)
end


#==Plot-level functionality
===============================================================================#

#-------------------------------------------------------------------------------
updateall(p::Plot) = sendcmd(p, "UPDATEALL")
redraw(p::Plot) = sendcmd(p, "REDRAW")

#-------------------------------------------------------------------------------
function setpagesize(p::Plot, a::CanvasAttributes)
	p.canvas = a
	width = round(Int, val(TPoint(a.width)))
	height = round(Int, val(TPoint(a.height)))
	sendcmd(p, "PAGE SIZE $width, $height")
	#Will also stretch entire plot if RESIZE is used instead:
	#sendcmd(p, "PAGE RESIZE $width, $height")
	return a
end

#Return cached canvas width/height
#-------------------------------------------------------------------------------
getwcanvas(p::Plot) = p.canvas.width
gethcanvas(p::Plot) = p.canvas.height

#Obtain "VIEW" width/height (given cached canvas width/height)
#-------------------------------------------------------------------------------
function getaspectratio(p::Plot)
	w = val(TPoint(p.canvas.width))
	h = val(TPoint(p.canvas.height))
	return w/h
end

#Return canvas width in normalized "view" coordinates:
function getwview(p::Plot)
	ar=getaspectratio(p)
	return (ar>1) ? ar : 1
end

#Return canvas width in normalized "view" coordinates:
function gethview(p::Plot)
	ar=getaspectratio(p)
	return (ar>1) ? 1 : (1/ar)
end

#-------------------------------------------------------------------------------
setnumcols(p::Plot, cols::Int) = (p.ncols = cols)

#-------------------------------------------------------------------------------
function arrange(p::Plot, gdim::GraphCoord; offset=0.15, hgap=0.15, vgap=0.15)
	(rows, cols) = gdim
	sendcmd(p, "ARRANGE($rows, $cols, $offset, $hgap, $vgap)")
	setnumcols(p, cols)
	newsize = rows*cols
	delta = newsize - length(p.graphs)

	for i in 1:delta
		push!(p.graphs, Graph())
	end

	if delta < 0
		resize!(p.graphs, newsize)
		if p.activegraph >= newsize
			setactive(graph(p, newsize-1))
		end
	end
end

 
#==Graph-level functionality
===============================================================================#

#-------------------------------------------------------------------------------
function Base.kill(g::GraphRef)
	gidx = graphindex(g)
	sendcmd(g.plot, "KILL g$gidx")
end

#-------------------------------------------------------------------------------
function setactive(g::GraphRef)
	gidx = graphindex(g)
	if g.plot.activegraph != gidx
		g.plot.activegraph = gidx
		sendcmd(g.plot, "WITH G$gidx")
	end
	return gidx
end

#-------------------------------------------------------------------------------
function setfocus(g::GraphRef)
	gidx = graphindex(g)
	sendcmd(g.plot, "FOCUS G$gidx")
end

#Convenience functions: Enables the use of set(::Plot, ...) interface:
#(Plot argument is otherwise redundant)
#-------------------------------------------------------------------------------
function setactive(p::Plot, g::GraphRef)
	@assert p==g.plot "setactive: GraphRef does not match Plot to control."
	setactive(g)
end

function setfocus(p::Plot, g::GraphRef)
	@assert p==g.plot "setfocus: GraphRef does not match Plot to control."
	setfocus(g)
end
#-------------------------------------------------------------------------------

#Add new graph to a plot
#NOTE: update = true sends UPDATEALL command to avoid having the GUI out of
#      sync with the plot itself. User expected to call updateall manually when
#      using update=false
#-------------------------------------------------------------------------------
function add(p::Plot, args...; update=true, kwargs...)
	gidx = length(p.graphs)
	g = graph(p, gidx)
	sendcmd(p, "G$gidx ON")
	setactive(g)
	if update; updateall(); end

	return g
end

#NOTE: AUTOSCALE X/Y does not seem to work...
#-------------------------------------------------------------------------------
function autofit(g::GraphRef; x=false, y=false)
	cmd = "AUTOSCALE"
	if x && y
		; #Send command by itself
	elseif x
		cmd *= " XAXES"
	elseif y
		cmd *= " YAXES"
	else
		return 0
	end

	setactive(g)
	sendcmd(g.plot, cmd)
end
autofit(g::GraphRef) = autofit(g, x=true, y=true)

#-------------------------------------------------------------------------------
const limits_attribcmdmap = AttributeCmdMap(
	:xmin => "XMIN",
	:xmax => "XMAX",
	:ymin => "YMIN",
	:ymax => "YMAX",
)

setview(g::GraphRef, a::CartesianLimAttributes) = setattrib(g, limits_attribcmdmap, "VIEW ", a)

#-------------------------------------------------------------------------------
const title_attribcmdmap = AttributeCmdMap(
	:value => "",
	:font  => "FONT",
	:size  => "SIZE",
	:color => "COLOR",
)

settitle(g::GraphRef, a::TextAttributes) = setattrib(g, title_attribcmdmap, "TITLE ", a)
setsubtitle(g::GraphRef, a::TextAttributes) = setattrib(g, title_attribcmdmap, "SUBTITLE ", a)
settitle(g::GraphRef, title::AbstractString) = settitle(g, text(title))
setsubtitle(g::GraphRef, title::AbstractString) = setsubtitle(g, text(title))

#-------------------------------------------------------------------------------
const label_attribcmdmap = AttributeCmdMap(
	:value => "",
	:font  => "FONT",
	:size  => "CHAR SIZE",
	:color => "COLOR",
)

setxlabel(g::GraphRef, a::TextAttributes) = setattrib(g, title_attribcmdmap, "XAXIS LABEL ", a)
setylabel(g::GraphRef, a::TextAttributes) = setattrib(g, title_attribcmdmap, "YAXIS LABEL ", a)
setxlabel(g::GraphRef, label::AbstractString) = setxlabel(g, text(label))
setylabel(g::GraphRef, label::AbstractString) = setylabel(g, text(label))

#-------------------------------------------------------------------------------
const frameline_attribcmdmap = AttributeCmdMap(
	:style => "LINESTYLE",
	:width => "LINEWIDTH",
)
setframeline(g::GraphRef, a::LineAttributes) = setattrib(g, frameline_attribcmdmap, "FRAME ", a)

const axes_attribcmdmap = AttributeCmdMap(
	:xmin => "WORLD XMIN", :xmax => "WORLD XMAX",
	:ymin => "WORLD YMIN", :ymax => "WORLD YMAX",
	:xscale  => "XAXES SCALE",
	:yscale  => "YAXES SCALE",
	:invertx => "XAXES INVERT",
	:inverty => "YAXES INVERT",
)
setaxes(g::GraphRef, a::AxesAttributes) = setattrib(g, axes_attribcmdmap, "", a)


#==Dataset-level functionality
===============================================================================#

#-------------------------------------------------------------------------------
function add(g::GraphRef, x::DataVec, y::DataVec, args...; kwargs...)
	@assert length(x) == length(y) "GracePlot.add(): x & y vlengths must match."
	p = g.plot
	gidx = graphindex(g)
	gdata = graphdata(g)
	dsid = gdata.datasetcount
	gdata.datasetcount += 1
	prefix = "G$(gidx).S$dsid"

	sendcmd(p, "$prefix TYPE XY")
	for (_x, _y) in zip(x, y)
		sendcmd(p, "$prefix POINT $_x, $_y")
	end

	ds = DatasetRef(g, dsid)
	set(ds, args...; kwargs...)
	return ds
end

#-------------------------------------------------------------------------------
const dsline_attribcmdmap = AttributeCmdMap(
	:_type => "LINE TYPE",
	:style => "LINE LINESTYLE",
	:width => "LINE LINEWIDTH",
	:color => "LINE COLOR",
)
setline(ds::DatasetRef, a::LineAttributes) = setattrib(ds, dsline_attribcmdmap, a)

#-------------------------------------------------------------------------------
const glyph_attribcmdmap = AttributeCmdMap(
	:_type     => "SYMBOL",
	:size      => "SYMBOL SIZE",
	:color     => "SYMBOL COLOR",
	:skipcount => "SYMBOL SKIP",
)
setglyph(ds::DatasetRef, a::GlyphAttributes) = setattrib(ds, glyph_attribcmdmap, a)


#==Define cleaner "set" interface (minimize # of "export"-ed functions)
===============================================================================#

#-------------------------------------------------------------------------------
const empty_listfnmap = AttributeListFunctionMap()
const empty_fnmap = AttributeFunctionMap()

#-------------------------------------------------------------------------------
const setplot_listfnmap = AttributeListFunctionMap(
	CanvasAttributes => setpagesize,
)
const setplot_fnmap = AttributeFunctionMap(
	:ncols  => setnumcols,
	:active => setactive,
	:focus  => setfocus,
)
set(p::Plot, args...; kwargs...) = set(p, setplot_listfnmap, setplot_fnmap, args...; kwargs...)

#-------------------------------------------------------------------------------
const setgraph_listfnmap = AttributeListFunctionMap(
	AxesAttributes => setaxes,
)
const setgraph_fnmap = AttributeFunctionMap(
	:view      => setview,
	:title     => settitle,
	:subtitle  => setsubtitle,
	:xlabel    => setxlabel,
	:ylabel    => setylabel,
	:frameline => setframeline,
)
set(g::GraphRef, args...; kwargs...) = set(g, setgraph_listfnmap, setgraph_fnmap, args...; kwargs...)

#-------------------------------------------------------------------------------
const setline_listfnmap = AttributeListFunctionMap(
	LineAttributes  => setline,
	GlyphAttributes => setglyph,
)
set(ds::DatasetRef, args...; kwargs...) = set(ds, setline_listfnmap, empty_fnmap, args...; kwargs...)

#==Define cleaner "get" interface (minimize # of "export"-ed functions)
===============================================================================#
const getplot_fnmap = AttributeFunctionMap(
	:wcanvas  => getwcanvas,
	:hcanvas  => gethcanvas,
	:wview    => getwview,
	:hview    => gethview,
)
Base.get(p::Plot, attrib::Symbol) = getattrib(p, getplot_fnmap, attrib)

#Last line
