#GracePlot demonstration 3: Generate proper plot & save/export
#(Uses template to avoid specifying too many parameters)
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


#==Generate plot
===============================================================================#
plot = GracePlot.new(template=engpaper)
g = graph(plot, 0)
	#No point in having a title with this particular template:
#	set(g, title = "Grace SVG Plot", subtitle = "(\\f{Times-Italic}y\\s1\\N=sin(x), y\\s2\\N=cos(x)\\f{})")
	set(g, xlabel = "Angle (rad)", ylabel = "Amplitude")
	#Add datasets:
		ds = add(g, x, y1)
		ds = add(g, x, y2)
	autofit(g)

#Finalize:
redraw(plot)

#Save plot in multiple formats:
save(plot, "sinewaveplot.agr")
save(plot, File{EPSFmt}("sinewaveplot.eps"))
save(plot, File{SVGFmt}("sinewaveplot.svg"))
save(plot, File{PNGFmt}("sinewaveplot.png"))
#Last line
