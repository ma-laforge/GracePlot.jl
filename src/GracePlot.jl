#GracePlot: Publication-quality plots through Grace/xmgrace
#-------------------------------------------------------------------------------

module GracePlot

using FileIO2

const rootpath = realpath(joinpath(dirname(realpath(@__FILE__)),"../."))

include("graceconst.jl")
include("codegen.jl")
include("units.jl")
include("base.jl")
include("plotmanip.jl")
include("files.jl")


#==Exported symbols
===============================================================================#
export arrange #Re-tile plot with specified number of rows/cols
export graph #Obtain reference to an individual graph
export autofit #Re-compute axes to fit data
export add #Add new dataset
export set #Set Plot/Graph/Dataset properties
#   set(::Plot, arg1, arg2, ..., kwarg1=v1, kwarg2=v1, ...)
#      kwargs: active, focus,
#   set(::GraphRef, arg1, arg2, ..., kwarg1=v1, kwarg2=v1, ...)
#      args: axes()
#      kwargs: title, subtitle, xlabel, ylabel, frameline
#   set(::DatasetRef, arg1, arg2, ..., kwarg1=v1, kwarg2=v1, ...)
#      args: line(), glyph()
export canvas #Creates CanvasAttributes to resize plot, etc
export limits #Creates CartesianLimAttributes to set view, world, ...
export text #Creates TextAttributes to set titles, etc
export axes #Creates AxesAttributes to modify axis
export line #Creates LineAttributes to modify line
export glyph #Creates GlyphAttributes to modify glyph
export redraw #Whole plot

#==
Other interface tools (symbols not exported to avoid collisions):
	Inch, Meter, TPoint... should be provided by external module
	Plot: Main plot object.
	new(): Creates a new Plot object.
	kill(graph): Kill already in Base.
	template("<GracePlot-provided template name>")
	File{GracePlot.ParamFmt}("filename.par")
	Base.get.... get is already part of base, so can't export it...
==#

end #GracePlot

#Last line
