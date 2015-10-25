#GracePlot demonstration 4: More advanced tests
#-------------------------------------------------------------------------------

using GracePlot

#==Input data
===============================================================================#
x=collect(-10:0.1:10)
y = []
for i in 1:4
	push!(y, (x.^i)./(10^i)) 
end


#=="Defaults"
===============================================================================#
template = GracePlot.template("plot2x2thick_mono")
defltline = line(width=2.5, color=1)
defltframeline = line(width=2.5)
loglin = axes(xscale = gconst[:log], yscale = gconst[:lin])

deltaxmin = .09
deltaxmax = .02
deltaymin = .065
deltaymax = 0.055
hpage = 1
wpage = 1.425

(nrows, ncols) = (2,2)
h = hpage/nrows
w = wpage/ncols

graphpos = []
for gidx in 0:3
	#NOTE: row here counts from the bottom:
	row = (nrows-1) - div(gidx, ncols)#0-based
	col = mod(gidx, ncols)#0-based
	xstart = w*col; ystart = h*row;
	push!(graphpos, limits(xmin = xstart+deltaxmin, xmax = xstart+w-deltaxmax,
		ymin = ystart+deltaymin, ymax = ystart+h-deltaymax))
#	@show graphpos[end]
end


function update(graphpos)
	for gidx in 0:3
		set(g, view=graphpos[gidx+1])
	end
end

#==Generate plot
===============================================================================#
#==
graphpos = [
	limits(xmax=w/2-.05, ymax=h/2-.05),
		limits(xmin=w/2+.05, xmax=w-.1, ymin=h/2+.05, ymax=h-.1),
	limits(xmin=w/2+.05, xmax=w-.1, ymin=h/2+.05, ymax=h-.1),
		limits(xmax=w/2-.05, ymax=h/2-.05),
]
==#

#plot = GracePlot.new()
plot = GracePlot.new(fixedcanvas=true, template=template)
#throw("stop")
	set(plot, plot.canvas) #Force default canvas size (ignore template size)
	w = get(plot, :wview); h = get(plot, :hview)




#Add subplots:
for gidx in 0:3
g = graph(plot, gidx)
	set(g, view=graphpos[gidx+1])
	set(g, title = "", subtitle = "Subplot $gidx")
	for i in 1:10
		ds = add(g, x, i.*y[gidx+1])
	end
	autofit(g)
	add(plot) #next graph
end
	GracePlot.sendcmd(plot, "G4 OFF")
#	plot.log=true
#	GracePlot.sendcmd(plot, "G4 OFF")
#	GracePlot.setactive(g)



#throw("stop")

#Finalize:
redraw(plot)

#Last line
