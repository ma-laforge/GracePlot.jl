#GracePlot demonstration 4: More advanced tests
#-------------------------------------------------------------------------------

using GracePlot

#==Input data
===============================================================================#
x=collect(-10:0.1:10)
y2 = x.^2
y3 = x.^3


#=="Defaults"
===============================================================================#
smallplot = GracePlot.template("smallplot_mono")
defltline = line(width=2.5, color=1)
defltframeline = line(width=2.5)
loglin = axes(xscale = gconst[:log], yscale = gconst[:lin])


#==Generate plot
===============================================================================#
#plot = GracePlot.new(fixedcanvas=true)
plot = GracePlot.new(fixedcanvas=true, template=smallplot)
#throw("stop")
	set(plot, plot.canvas) #Force default canvas size (ignore template size)
	w = get(plot, :wview); h = get(plot, :hview)
g = graph(plot, 0)
	set(g, view=limits(xmin=.15, xmax=w-.15, ymin=.15, ymax=h-.15))
	set(g, title = "Title", subtitle = "Subtitle")
		ds = add(g, x, y2)
		ds = add(g, x, 2.*y2)
		ds = add(g, x, 3.*y2)
		ds = add(g, x, 4.*y2)
	autofit(g)
#throw("stop")

#Finalize:
redraw(plot)

#Last line
