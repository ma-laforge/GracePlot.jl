#GracePlot demonstration 1: Plot basics
#-------------------------------------------------------------------------------

using GracePlot
gp = GracePlot

#Data
#-------------------------------------------------------------------------------
x=[-10:0.1:10]
y2 = x.^2
y3 = x.^3


#Plot 1
#-------------------------------------------------------------------------------
plt = GracePlot.new()
g = graph(plt, 0)
	set(g, title = "Parabola", subtitle = "(\\f{Times-Italic}y=x\\f{}\\S2\\N)")
	set(g, xlabel = text("Time (s)", color=2), ylabel = "Normalized height")
	set(g, unsupported = "no dice")
	ds = add(g, x, y2)
	autofit(g)

#Finalize:
redraw(plt)


#Plot 2
#-------------------------------------------------------------------------------
plt = GracePlot.new()
	arrange(plt, (3, 2), offset=0.08, hgap=0.15, vgap=0.3)
g = graph(plt, (1, 2))
	txt = text("Parabola (\\f{Times-Italic}y=x\\f{}\\S2\\N)", size=2)
	set(g, subtitle = txt)
	ds = add(g, x, y2, glyph=glyph(_type=3, color=5, char=4))
	plt.log = true
		set(ds, glyph=glyph(color=5, skipcount=10))
		set(ds, line=line(color=3))
	plt.log = false
	autofit(g)
g = graph(plt, (0, 1))
	set(g, subtitle = "Cubic Function (\\f{Times-Italic}y=x\\f{}\\S3\\N)")
	ds = add(g, x, y3)
		set(ds, line=line(_type=1, width=4, color=1))
	autofit(g)
	#autofit(g, x=true) #Not supported by Grace v5.1.23?

#Finalize:
set(plt, focus=g)
redraw(plt)

save(plt, "sampleoutput.agr")
#sleep(1); close(plt)

#Last line
