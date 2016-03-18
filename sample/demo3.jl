#GracePlot demonstration 3: Generate proper plot & save/export
#(Uses template to avoid specifying too many parameters)
#-------------------------------------------------------------------------------

using GracePlot
using FileIO2

#==Input data
===============================================================================#
x=collect(-1:0.02:1).*pi
y1 = sin(x)
y2 = cos(x)


#=="Defaults"
===============================================================================#
smallplot = GracePlot.template("smallplot_mono")


#==Generate plot
===============================================================================#
plot = GracePlot.new(guimode=true, template=smallplot)
g = add(plot, title = "Grace SVG Plot")
	set(g, subtitle = "(\\f{Times-Italic}y\\s1\\N=sin(x), y\\s2\\N=cos(x)\\f{})")
	set(g, xlabel = "Angle (rad)", ylabel = "Amplitude")
	#Add datasets:
		ds = add(g, x, y1)
		ds = add(g, x, y2)
	autofit(g)

#Finalize:
redraw(plot)

#Save plot in multiple formats:
GracePlot._write("sinewaveplot.agr", plot)
GracePlot._write(File(:eps, "sinewaveplot.eps"), plot)
GracePlot._write(File(:svg, "sinewaveplot.svg"), plot)
GracePlot._write(File(:png, "sinewaveplot.png"), plot, dpi=300)
#Last line
