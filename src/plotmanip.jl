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

function exportplot(p::Plot, filefmt::String, filepath::String)
	sendcmd(p, "HARDCOPY DEVICE \"$filefmt\"")
	sendcmd(p, "PRINT TO \"$filepath\"")
	sendcmd(p, "PRINT")
	#Sadly, Grace does not wait unil file is saved to return from "PRINT"
end

#Save to PNG (avoid use of "export" keyword):
save(::Type{File{PNGFmt}}, p::Plot, filepath::String) = exportplot(p, "PNG", filepath)

#Save to EPS (avoid use of "export" keyword):
function save(::Type{File{EPSFmt}}, p::Plot, filepath::String) 
	sendcmd(p, "DEVICE \"EPS\" OP \"bbox:page\"")
	exportplot(p, "EPS", filepath)
end

#Export to svg.  (Fix Grace output according W3C 1999 format):
#TODO: Make more robust... use more try/catch.
#NOTE: Replace xml (svg) statements using Julia v3 compatibility.
function save(::Type{File{SVGFmt}}, p::Plot, filepath::String)
	tmpfilepath = "./.tempgraceplotexport.svg"
	#Export to svg, using the native Grace format:
	exportplot(p, "SVG", tmpfilepath)
	#NOTE: Is this the 2001 format?  Most programs do not appear to read it.

	local src
	retries = 3
	twait = 1 #sec
	wait_expfact = 2#Exponential factor to increase wait time
	success = false


	while !success
		try
#			tmpfilepath = "nope"
			src = open(tmpfilepath, "r")
			success = true
		catch e
			retries -= 1
			sleep(twait)
#			@show twait
			twait *= wait_expfact
			if retries < 0
				rethrow(e)
			end
		end
	end
	
	filedat = readall(src)
	close(src)

	#Remove <!DOCTYPE svg ...> statement:
	pat = r"^[ \t]*<!DOCTYPE svG.*$"mi
	filedat = replace(filedat, pat, "")

	#Modify <svg ...> statement:
	pat = r"(^[ \t]*<svg) xml:space=\"preserve\" (.*$)"mi
	captures = match(pat, filedat).captures
	cap1 = captures[1]; cap2 = captures[2]
	filedat = replace(filedat, pat, "$cap1 xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" $cap2")

	dest = open(filepath, "w")
	write(dest, filedat)
	close(dest)

	rm(tmpfilepath)
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
