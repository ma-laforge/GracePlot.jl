#GracePlot functions to control Grace/xmgrace
#-------------------------------------------------------------------------------

#==Plot-level functionality
===============================================================================#

#-------------------------------------------------------------------------------
redraw(p::Plot) = sendcmd(p, "REDRAW")

#-------------------------------------------------------------------------------
function save(p::Plot, path::String)
	@assert !contains(path, "\"") "File path contains '\"'."
	sendcmd(p, "SAVEALL \"$path\"")
end

#-------------------------------------------------------------------------------
function arrange(p::Plot, gdim::GraphCoord; offset=0.08, hgap=0.15, vgap=0.2)
	(rows, cols) = gdim
	sendcmd(p, "ARRANGE($rows, $cols, $offset, $hgap, $vgap)")
	p.gdim = gdim
	newsize = rows*cols
	delta = newsize - length(p.graphs)

	for i in 1:delta
		push!(p.graphs, Graph())
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
	if gidx == g.plot.activegraph
		return 0 #Already active
	end
	g.plot.activegraph = gidx
	sendcmd(g.plot, "WITH G$gidx")
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
const title_propertycmdmap = PropertyCmdMap([
	(:value, "")
	(:font, "FONT")
	(:size, "SIZE")
	(:color, "COLOR")
])

settitle(g::GraphRef, p::TextProp) = applypropchanges(g, title_propertycmdmap, "TITLE ", p)
setsubtitle(g::GraphRef, p::TextProp) = applypropchanges(g, title_propertycmdmap, "SUBTITLE ", p)
settitle(g::GraphRef, title::String) = settitle(g, text(title))
setsubtitle(g::GraphRef, title::String) = setsubtitle(g, text(title))

#-------------------------------------------------------------------------------
const label_propertycmdmap = PropertyCmdMap([
	(:value, "")
	(:font, "FONT")
	(:size, "CHAR SIZE")
	(:color, "COLOR")
])

setxlabel(g::GraphRef, p::TextProp) = applypropchanges(g, title_propertycmdmap, "XAXIS LABEL ", p)
setylabel(g::GraphRef, p::TextProp) = applypropchanges(g, title_propertycmdmap, "YAXIS LABEL ", p)
setxlabel(g::GraphRef, label::String) = setxlabel(g, text(label))
setylabel(g::GraphRef, label::String) = setylabel(g, text(label))

#-------------------------------------------------------------------------------
const frameline_propertycmdmap = PropertyCmdMap([
	(:style, "LINESTYLE")
	(:width, "LINEWIDTH")
])
setframeline(g::GraphRef, p::LineProp) = applypropchanges(g, frameline_propertycmdmap, "FRAME ", p)

const axes_propertycmdmap = PropertyCmdMap([
	(:xmin, "WORLD XMIN"), (:xmax, "WORLD XMAX"),
	(:ymin, "WORLD YMIN"), (:ymax, "WORLD YMAX"),
	(:xscale, "XAXES SCALE"),
	(:yscale, "YAXES SCALE"),
	(:invertx, "XAXES INVERT"),
	(:inverty, "YAXES INVERT"),
])
setaxes(g::GraphRef, p::AxesProp) = applypropchanges(g, axes_propertycmdmap, "", p)


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
const dsline_propertycmdmap = PropertyCmdMap([
	(:_type, "LINE TYPE")
	(:style, "LINE LINESTYLE")
	(:width, "LINE LINEWIDTH")
	(:color, "LINE COLOR")
])
setline(ds::DatasetRef, p::LineProp) = applydatasetpropchanges(ds, dsline_propertycmdmap, p)

#-------------------------------------------------------------------------------
const glyph_propertycmdmap = PropertyCmdMap([
	(:_type, "SYMBOL")
	(:size, "SYMBOL SIZE")
	(:color, "SYMBOL COLOR")
	(:skipcount, "SYMBOL SKIP")
])
setglyph(ds::DatasetRef, p::GlyphProp) = applydatasetpropchanges(ds, glyph_propertycmdmap, p)


#==Define cleaner "set" interface (minimize # of "export"-ed functions)
===============================================================================#

#-------------------------------------------------------------------------------
const empty_ptmap = PropTypeFunctionMap()
const empty_fnmap = PropertyFunctionMap()

#-------------------------------------------------------------------------------
const setplot_fnmap = PropertyFunctionMap([
	(:active, setactive)
	(:focus, setfocus)
])
set(g::Plot, args...; kwargs...) = set(g, empty_ptmap, setplot_fnmap, args...; kwargs...)

#-------------------------------------------------------------------------------
const setgraph_ptmap = PropTypeFunctionMap([
	(AxesProp, setaxes)
])
const setgraph_fnmap = PropertyFunctionMap([
	(:title, settitle)
	(:subtitle, setsubtitle)
	(:xlabel, setxlabel)
	(:ylabel, setylabel)
	(:frameline, setframeline)
])
set(g::GraphRef, args...; kwargs...) = set(g, setgraph_ptmap, setgraph_fnmap, args...; kwargs...)

#-------------------------------------------------------------------------------
const setline_ptmap = PropTypeFunctionMap([
	(LineProp, setline)
	(GlyphProp, setglyph)
])
set(g::DatasetRef, args...; kwargs...) = set(g, setline_ptmap, empty_fnmap, args...; kwargs...)

#Last line
