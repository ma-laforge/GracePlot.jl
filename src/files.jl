#GracePlot file tools
#-------------------------------------------------------------------------------
#TODO: Rename io.jl

#==Register new DataFormat/File types
===============================================================================#

#Parameter file format (Not exported):
abstract ParamFmt <: FileIO2.DataFormat

#Convenient accessor for sample GracePlot template (parameter) files:
template(name::AbstractString) =
	File{ParamFmt}(joinpath(GracePlot.rootpath, "sample/template/$name.par"))

#OR: Could have shorthand:
#FileIO2.File(::FileIO2.Shorthand{:graceparam}, path::AbstractString) = File{ParamFmt}(path)


#==Helper functions
===============================================================================#
#Opens a file for read, after it is done being written:
#(Writing files with grace is a non-blocking operation.)
#timeout in seconds
function openreadafterexport(p::Plot, filepath::AbstractString; timeout=15)
	const poll_interval = .1 #sec
	timeout = timeout*1_000_000_000
	flushpipe(p) #Make sure last write operation is registered with Grace.
	tstart = time_ns()
	local io

	while true
		try
#			filepath = "nope"
			io = open(filepath, "r")
			break
		catch e
			sleep(poll_interval)
			if time_ns()-tstart > timeout
				rethrow(e)
			end
		end
	end

	szlast = 0
	while true
		sleep(poll_interval)
		sz = filesize(io)
		if sz == 0
			if time_ns()-tstart > timeout
				close(io)
				throw("$filepath access timed out.")
			end
		elseif sz == szlast
			break
		end
		szlast = sz
	end
#	@show filesize(io)/1e6
	return io
end
#-------------------------------------------------------------------------------
function exportplot(p::Plot, filefmt::AbstractString, filepath::AbstractString)
	sendcmd(p, "HARDCOPY DEVICE \"$filefmt\"")
	sendcmd(p, "PRINT TO \"$filepath\"")
	sendcmd(p, "PRINT")
	flushpipe(p)
	#Sadly, Grace does not wait unil file is saved to return from "PRINT"
end


#==Load/save/export plots
===============================================================================#

#Save a Grace plot:
#-------------------------------------------------------------------------------
function Base.write(file::File{ParamFmt}, p::Plot)
	path = file.path
	_ensure(!contains(path, "\""), ArgumentError("File path contains '\"'."))
	sendcmd(p, "SAVEALL \"$path\"")
	flushpipe(p)
end
Base.write(path::AbstractString, p::Plot) = Base.write(File{ParamFmt}(path), p)


#Save to PNG (avoid use of "export" keyword):
#-------------------------------------------------------------------------------
function Base.write(file::File{PNGFmt}, p::Plot; dpi=200)
	w = round(Int, val(TPoint(p.canvas.width)));
	h = round(Int, val(TPoint(p.canvas.height)));
	sendcmd(p, "DEVICE \"PNG\" DPI $dpi") #Must set before PAGE SIZE
	sendcmd(p, "DEVICE \"PNG\" PAGE SIZE $w, $h")
	exportplot(p, "PNG", file.path)
end

#Save to EPS (avoid use of "export" keyword):
#-------------------------------------------------------------------------------
function Base.write(file::File{EPSFmt}, p::Plot)
	sendcmd(p, "DEVICE \"EPS\" OP \"bbox:page\"")
	exportplot(p, "EPS", file.path)
end

#Export to SVG.  (Fix Grace output according W3C 1999 format):
#TODO: Make more robust... use more try/catch.
#NOTE: Replace xml (svg) statements using Julia v3 compatibility.
#-------------------------------------------------------------------------------
function Base.write(file::File{SVGFmt}, p::Plot)
	tmpfilepath = "$(tempname())_export.svg"
	#Export to svg, using the native Grace format:
	exportplot(p, "SVG", tmpfilepath)
	#NOTE: Is this the 2001 format?  Most programs do not appear to read it.

	src = openreadafterexport(p, tmpfilepath)
	filedat = readall(src)
	close(src)

	#Remove <!DOCTYPE svg ...> statement:
	pat = r"^[ \t]*<!DOCTYPE svG.*$"mi
	filedat = replace(filedat, pat, "")

	#Modify <svg ...> statement:
	pat = r"(^[ \t]*<svg) xml:space=\"preserve\" (.*$)"mi
	captures = match(pat, filedat).captures
	cap1 = captures[1]; cap2 = captures[2]
	filedat = replace(filedat, pat, "$cap1 xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" $cap2")

	dest = open(file.path, "w")
	write(dest, filedat)
	close(dest)

	rm(tmpfilepath)
end


#==MIME support
===============================================================================#
function Base.writemime(io::IO, ::MIME{symbol("image/png")}, p::Plot; dpi=200)
	tmpfile = File(:png, "$(tempname())_export.png")
	Base.write(tmpfile, p, dpi = dpi)
	flushpipe(p)
	src = openreadafterexport(p, tmpfile.path)
	data = readall(src)
	write(io, data)
	close(src)
	rm(tmpfile.path)
end

#Last line
