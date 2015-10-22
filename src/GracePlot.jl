#GracePlot: Publication-quality plots through Grace/xmgrace
module GracePlot

const rootpath = realpath(joinpath(dirname(realpath(@__FILE__)),"../."))

using FileIO2

include("codegen.jl")
include("base.jl")
include("plotmanip.jl")
include("files.jl")

#Provide some constant litterals for the user.
#(Use dict to avoid polluting namespace too much)
const gconst = Dict{Symbol, GraceConstLitteral}([
	(:lin, GraceConstLitteral("NORMAL")),
	(:log, GraceConstLitteral("LOGARITHMIC")),
	(:reciprocal, GraceConstLitteral("RECIPROCAL")),
	(:on, GraceConstLitteral("ON")),
	(:off, GraceConstLitteral("OFF")),
])

export graph #Obtain reference to an individual graph
export arrange #Re-tile the plot with different number of graphs
export autofit #Re-compute axes to fit data
export add #Add new dataset
export set #Set Plot/Graph properties
#   set(::Plot, arg1, arg2, ..., kwarg1=v1, kwarg2=v1, ...)
#      kwargs: active, focus,
#   set(::GraphRef, arg1, arg2, ..., kwarg1=v1, kwarg2=v1, ...)
#      args: axes()
#      kwargs: title, subtitle, xlabel, ylabel, frameline
#   set(::DatasetRef, arg1, arg2, ..., kwarg1=v1, kwarg2=v1, ...)
#      args: line(), glyph()
export text #Creates TextAttributes to set titles, etc
export axes #Creates AxesAttributes to modify axis
export line #Creates LineAttributes to modify line
export glyph #Creates GlyphAttributes to modify glyph
export redraw #Whole plot
export gconst #Dict proivding constant litterals to the user

#==
Other interface tools (symbols not exported to avoid collisions):
	Plot: Main plot object.
	new(): Creates a new Plot object.
	kill(graph): Kill already in Base.
	template("<GracePlot-provided template name>")
	File{GracePlot.ParamFmt}("filename.par")
==#

end #GracePlot

#Last line
