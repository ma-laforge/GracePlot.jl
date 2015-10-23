#GracePlot demonstration 2: Stress test
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
plot = GracePlot.new()
	#Try a multi-graph plot:
	arrange(plot, (3, 2), offset=0.08, hgap=0.15, vgap=0.3)
g = graph(plot, (1, 2)) #Get a reference to graph (1,2)
	txt = text("Parabola (\\f{Times-Italic}y=x\\f{}\\S2\\N)", size=2)
	set(g, xlabel = text("x-axis", color=2), ylabel = "y-axis")
	set(g, unsupported = "no dice")
	set(g, subtitle = txt)
	set(g, frameline = defltframeline)
	#Add datasets:
		ds = add(g, x, y2, glyph(_type=3, color=5, char=4), defltline)
			set(ds, glyph(color=5, skipcount=10))
			set(ds, line(color=3))
	autofit(g)
g = graph(plot, (0, 1))
	set(g, subtitle = "Cubic Function (\\f{Times-Italic}y=x\\f{}\\S3\\N)")
	set(g, frameline = defltframeline)
	#Add datasets:
		ds = add(g, x, y3, defltline)
			set(ds, line(style=3, width=8, color=1)) #Overwrite defaults
	autofit(g)
	#autofit(g, x=true) #Not supported by Grace v5.1.23?
g = graph(plot, (1, 1)) #Play around with another graph
	#Test message logging functionality:
	plot.log = true
	set(g, axes(xmin = 0.1, xmax = 1000, ymin = 1000, ymax = 5000))
	set(g, loglin, axes(inverty = gconst[:on]))
	plot.log = false

#Finalize:
set(plot, focus=g)
redraw(plot)

#Other possible operations... but don't test here:
#sleep(1); close(plot)

#Last line

