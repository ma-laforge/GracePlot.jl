#GracePlot functions to control Grace/xmgrace
#-------------------------------------------------------------------------------

#==Plot-level functionality
===============================================================================#
redraw(p::Plot) = sendcmd(p, "REDRAW")

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

function save(p::Plot, path::String)
	@assert !contains(path, "\"") "File path contains '\"'."
	sendcmd(p, "SAVEALL \"$path\"")
end

 
#==Graph-level functionality
===============================================================================#

function Base.kill(g::GraphRef)
	gidx = graphindex(g)
	sendcmd(g.plot, "KILL g$gidx")
end

function setactive(g::GraphRef)
	gidx = graphindex(g)
	if gidx == g.plot.activegraph
		return 0 #Already active
	end
	g.plot.activegraph = gidx
	sendcmd(g.plot, "WITH G$gidx")
end

function setfocus(g::GraphRef)
	gidx = graphindex(g)
	sendcmd(g.plot, "FOCUS G$gidx")
end

#Set graph properties for a given element:
function applypropchanges(g::GraphRef, fmap::PropertyCmdMap, prefix::String, data::Any)
	setactive(g)

	for prop in names(data)
		v = eval(:($data.$prop))

		if v != nothing
			subcmd = get(fmap, prop, nothing)

			if subcmd != nothing
				if typeof(v) <: String; v = "\"$v\""; end#Quote the string
				sendcmd(g.plot, "$prefix$subcmd $v")
			else
				dtype = typeof(data)
				warn("Property \"$prop\" of $dtype not currently supported.")
			end
		end
	end
end

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

#NOTE: AUTOSCALE X/Y does not seem to work...
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

#==Dataset-level functionality
===============================================================================#
function add(g::GraphRef, x::DataVec, y::DataVec; kwargs...)
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
	set(ds; kwargs...)
	return ds
end

function applylinepropchanges(ds::DatasetRef, fmap::PropertyCmdMap, data::Any)
	dsid = ds.id
	applypropchanges(ds.graph, fmap::PropertyCmdMap, "S$dsid ", data::Any)
end

const line_propertycmdmap = PropertyCmdMap([
	(:_type, "LINE TYPE")
	(:style, "LINE LINESTYLE")
	(:width, "LINE LINEWIDTH")
	(:color, "LINE COLOR")
])
setline(ds::DatasetRef, p::LineProp) = applylinepropchanges(ds, line_propertycmdmap, p)

const glyph_propertycmdmap = PropertyCmdMap([
	(:_type, "SYMBOL")
	(:size, "SYMBOL SIZE")
	(:color, "SYMBOL COLOR")
	(:skipcount, "SYMBOL SKIP")
])
setglyph(ds::DatasetRef, p::GlyphProp) = applylinepropchanges(ds, glyph_propertycmdmap, p)


#==Cleaner "set" interface (minimal "export" count)
===============================================================================#

#==Cleaner "set" interface providing plot-level functionality
===============================================================================#

#Convenience functions to use set(::Plot, ...) interface:
function setactive(p::Plot, g::GraphRef)
	@assert p==g.plot "setactive: GraphRef does not match Plot to control."
	setactive(g)
end
function setfocus(p::Plot, g::GraphRef)
	@assert p==g.plot "setfocus: GraphRef does not match Plot to control."
	setfocus(g)
end

#Maps keyword arguments of the set function with the associated module function:
const setplot_fnmap = PropertyFunctionMap([
	(:active, setactive)
	(:focus, setfocus)
])

#"set" interface for GraphRef:
function set(p::Plot; kwargs...)
	for (arg, value) in kwargs
		setfn = get(setplot_fnmap, arg, nothing)

		if setfn != nothing
			setfn(p, value)
		else
			argstr = string(arg)
			warn("Argument \"$argstr\" not recognized by \"set(::Plot, ...)\"")
		end
	end
	return
end

#==Cleaner "set" interface providing graph-level functionality
===============================================================================#

#Maps keyword arguments of the set function with the associated module function:
const setgraph_fnmap = PropertyFunctionMap([
	(:title, settitle)
	(:subtitle, setsubtitle)
	(:xlabel, setxlabel)
	(:ylabel, setylabel)
])

#"set" interface for GraphRef:
function set(g::GraphRef; kwargs...)
	for (arg, value) in kwargs
		setfn = get(setgraph_fnmap, arg, nothing)

		if setfn != nothing
			setfn(g, value)
		else
			argstr = string(arg)
			warn("Argument \"$argstr\" not recognized by \"set(::GraphRef, ...)\"")
		end
	end
	return
end

#==Cleaner "set" interface providing dataset-level functionality
===============================================================================#

#Maps keyword arguments of the set function with the associated module function:
const setline_fnmap = PropertyFunctionMap([
	(:line, setline)
	(:glyph, setglyph)
])

#"set" interface for DatasetRef:
function set(ds::DatasetRef; kwargs...)
	for (arg, value) in kwargs
		setfn = get(setline_fnmap, arg, nothing)

		if setfn != nothing
			setfn(ds, value)
		else
			argstr = string(arg)
			warn("Argument \"$argstr\" not recognized by \"set(::DatasetRef, ...)\"")
		end
	end
	return
end

#Last line
