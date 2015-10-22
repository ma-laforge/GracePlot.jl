#GracePlot demonstration 1: Plot basics
#(Uses template to avoid specifying too many parameters)
#-------------------------------------------------------------------------------

using GracePlot

#==Input data
===============================================================================#
x=collect(-10:0.1:10)
y2 = x.^2
y3 = x.^3

#=="Defaults"
===============================================================================#
defltline = line(width=2.5, color=1)
defltframeline = line(width=2.5)
loglin = axes(xscale = gconst[:log], yscale = gconst[:lin])


#==Generate plot
===============================================================================#
plot = GracePlot.new(fixedcanvas=false)
g = graph(plot, 0) #Get a reference to graph 0
	set(g, title = "Parabolic Trajectory", subtitle = "(\\f{Times-Italic}y=+/- x\\f{}\\S2\\N)")
	set(g, xlabel = "Time (s)", ylabel = "Normalized height")
	#Add datasets:
		ds = add(g, x, y2)
		ds = add(g, x, -y2)
	autofit(g)

#Finalize:
redraw(plot)

#Last line
