#GracePlot: Publication-quality plots through Grace/xmgrace
module GracePlot

export graph #Obtain reference to an individual graph
export arrange #Re-tile the plot with different number of graphs
export autofit #Re-compute axes to fit data
export add #Add new dataset
export set #Set Plot/Graph properties
#      set(Plot, arg1=value, arg2=value, ...)
#         active, focus,
#      set(GraphRef, arg1=value, arg2=value, ...)
#         settitle, setsubtitle,
#      set(LineProp, arg1=value, arg2=value, ...)
#         linestyle,
export text #Creates a TextProp object to set titles, etc
export line #Creates a LineProp object to modify line properties
export glyph #Creates a GlyphProp object to modify gliph properties
export save
export redraw #Whole plot

#==
Other interface tools (symbols not exported to avoid collisions):
	Plot: Main plot object.
	new(): Creates a new Plot object.
	kill(graph): Kill already in Base.
==#

include("codegen.jl")
include("base.jl")
include("plotmanip.jl")

end #GracePlot

#Last line
