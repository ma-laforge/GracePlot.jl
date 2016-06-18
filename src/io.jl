#GracePlot: I/O facilities
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
typealias MIMEpng MIME"image/png"
#typealias MIMEsvg MIME"image/svg+xml"
#typealias MIMEeps MIME"image/eps"
#typealias MIMEpdf MIME"application/pdf"


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


#==_write interface
===============================================================================#

#Write plot to Grace .agr file:
#-------------------------------------------------------------------------------
function _write(path::AbstractString, p::Plot)
	_ensure(!contains(path, "\""), ArgumentError("File path contains '\"'."))
	sendcmd(p, "SAVEALL \"$path\"")
	flushpipe(p)
end


#==write_FILEFMT interface
===============================================================================#

#Write to PNG:
#-------------------------------------------------------------------------------
function _write_png(path::AbstractString, p::Plot, dpi::Int)
	w = round(Int, val(TPoint(p.canvas.width)));
	h = round(Int, val(TPoint(p.canvas.height)));
	sendcmd(p, "DEVICE \"PNG\" DPI $dpi") #Must set before PAGE SIZE
	sendcmd(p, "DEVICE \"PNG\" PAGE SIZE $w, $h")
	exportplot(p, "PNG", path)
end
_write_png(path::AbstractString, p::Plot, ::Void) =
	_write_png(path, p, p.dpi) #Use dpi setting in plot

#User-level wrapper function:
write_png(path::AbstractString, p::Plot; dpi::Union{Int,Void}=nothing) =
	_write_png(path, p, dpi)

#Write to EPS:
#-------------------------------------------------------------------------------
function write_eps(path::AbstractString, p::Plot)
	sendcmd(p, "DEVICE \"EPS\" OP \"bbox:page\"")
	exportplot(p, "EPS", path)
end

#Write to SVG.  (Fix Grace output according W3C 1999 format):
#TODO: Make more robust... use more try/catch.
#NOTE: Replace xml (svg) statements using Julia v3 compatibility.
#-------------------------------------------------------------------------------
function write_svg(path::AbstractString, p::Plot)
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

	dest = open(path, "w")
	write(dest, filedat)
	close(dest)

	rm(tmpfilepath)
end


#==MIME support
===============================================================================#
function Base.writemime(io::IO, ::MIMEpng, p::Plot; dpi::Union{Int,Void}=nothing)
	tmpfile = "$(tempname())_export.png"
	_write_png(tmpfile, p, dpi)
	flushpipe(p)
	src = openreadafterexport(p, tmpfile)
	data = readall(src)
	write(io, data)
	close(src)
	rm(tmpfile)
end


#=
#==FileIO2 support:
===============================================================================#
#	-Deactivated to avoid un-necessary dependency (at this point).
#	-TODO: Re-activate once FileIO2 is registered?

using FileIO2

#Declare file formats (Not exported):
abstract GraceFmt <: FileIO2.DataFormat #Grace plot file
abstract ParamFmt <: FileIO2.DataFormat #Grace "parameter" (.par template) format

#Could also define shorthand:
#FileIO2.File(::FileIO2.Shorthand{:grace}, path::AbstractString) = File{GraceFmt}(path)
#FileIO2.File(::FileIO2.Shorthand{:graceparam}, path::AbstractString) = File{ParamFmt}(path)

#Typed _write interface:
#_write(file::File{ParamFmt}, p::Plot) = #TODO: Is there a way to write .par files?
_write(file::File{GraceFmt}, p::Plot) = _write(path::AbstractString, p::Plot)
_write(file::File{PNGFmt}, p::Plot) = write_png(path::AbstractString, p::Plot)
_write(file::File{SVGFmt}, p::Plot) = write_svg(path::AbstractString, p::Plot)
_write(file::File{EPSFmt}, p::Plot) = write_eps(path::AbstractString, p::Plot)
=#

#Last line
