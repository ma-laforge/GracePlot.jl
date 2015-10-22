#GracePlot demonstration 2: Generate .svg
#-------------------------------------------------------------------------------

using GracePlot
using FileIO2

#==Input data
===============================================================================#
#x=collect(-1:0.1:1).*pi
x=collect(-1:0.02:1).*pi
y1 = sin(x)
y2 = cos(x)
engpaper = GracePlot.template("engpaper_mono")

#=="Defaults"
===============================================================================#


#==Plot 1: Basics (use template to avoid specifying too many parameters)
===============================================================================#
plt = GracePlot.new(fixedcanvas=true, template=engpaper)
g = graph(plt, 0)
	#No point in having a title with this particular template:
#	set(g, title = "Grace SVG Plot", subtitle = "(\\f{Times-Italic}y\\s1\\N=sin(x), y\\s2\\N=cos(x)\\f{})")
	set(g, xlabel = "Angle (rad)", ylabel = "Amplitude")
	ds = add(g, x, y1)
	ds = add(g, x, y2)
	autofit(g)

#Finalize:
redraw(plt)

#Save plot in multiple formats:
save(plt, "sinewaveplot.agr")
save(File{EPSFmt}, plt, "sinewaveplot.eps")
save(File{SVGFmt}, plt, "sinewaveplot.svg")
save(File{PNGFmt}, plt, "sinewaveplot.png")
#Last line
