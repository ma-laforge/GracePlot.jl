#GracePlot demonstration 1: Plot basics
#-------------------------------------------------------------------------------

using GracePlot

#==Input data
===============================================================================#
x=[-10:0.1:10]
y2 = x.^2
y3 = x.^3
template = @filerelpath("sample_template.par")


#=="Defaults"
===============================================================================#
defltline = line(width=2.5, color=1)
defltframeline = line(width=2.5)
axes_loglin = axes(xscale = gconst[:log], yscale = gconst[:lin])


#==Plot 1: Basics (use template to avoid specifying too many parameters)
===============================================================================#
plt = GracePlot.new(fixedcanvas=false, templatefile=template)
g = graph(plt, 0)
	set(g, title = "Parabolas", subtitle = "(\\f{Times-Italic}y=+/- x\\f{}\\S2\\N)")
	set(g, xlabel = text("Time (s)", color=2), ylabel = "Normalized height")
	set(g, unsupported = "no dice")
	ds = add(g, x, y2) #Use only Grace default line settings
	ds = add(g, x, -y2)
	autofit(g)

#Finalize:
redraw(plt)


#==Plot 2: Multi-plot
===============================================================================#
plt = GracePlot.new()
	arrange(plt, (3, 2), offset=0.08, hgap=0.15, vgap=0.3)
g = graph(plt, (1, 2))
	txt = text("Parabola (\\f{Times-Italic}y=x\\f{}\\S2\\N)", size=2)
	set(g, subtitle = txt)
	set(g, frameline = defltframeline)
	ds = add(g, x, y2, glyph(_type=3, color=5, char=4), defltline)
		set(ds, glyph(color=5, skipcount=10))
		set(ds, line(color=3))
	autofit(g)
g = graph(plt, (0, 1))
	set(g, subtitle = "Cubic Function (\\f{Times-Italic}y=x\\f{}\\S3\\N)")
	set(g, frameline = defltframeline)
	ds = add(g, x, y3, defltline)
		set(ds, line(style=3, width=8, color=1)) #Overwrite defaults
	autofit(g)
	#autofit(g, x=true) #Not supported by Grace v5.1.23?
g = graph(plt, (1, 1)) #Play around with another graph
	plt.log = true
	set(g, axes(xmin = 0.1, xmax = 1000, ymin = 1000, ymax = 5000))
	set(g, axes_loglin, axes(inverty = gconst[:on]))
	plt.log = false

#Finalize:
set(plt, focus=g)
redraw(plt)


#Other possible operations... but don't test here:
#save(plt, "sampleoutput.agr")
#sleep(1); close(plt)

#Last line
