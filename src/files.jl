#GracePlot file tools
#-------------------------------------------------------------------------------

#==Register new DataFormat/File types
===============================================================================#

#Parameter file format (Not exported):
abstract ParamFmt <: FileIO2.DataFormat

#Convenient accessor for sample GracePlot template (parameter) files:
template(name::AbstractString) =
	File{ParamFmt}(joinpath(GracePlot.rootpath, "sample/template/$name.par"))


#==Helper functions
===============================================================================#
#-------------------------------------------------------------------------------
function exportplot(p::Plot, filefmt::AbstractString, filepath::AbstractString)
	sendcmd(p, "HARDCOPY DEVICE \"$filefmt\"")
	sendcmd(p, "PRINT TO \"$filepath\"")
	sendcmd(p, "PRINT")
	#Sadly, Grace does not wait unil file is saved to return from "PRINT"
end


#==Load/save/export plots
===============================================================================#

#Save a Grace plot:
#-------------------------------------------------------------------------------
function FileIO2.save(p::Plot, file::File{ParamFmt})
	path = file.path
	@assert !contains(path, "\"") "File path contains '\"'."
	sendcmd(p, "SAVEALL \"$path\"")
end
FileIO2.save(p::Plot, path::AbstractString) = save(p, File{ParamFmt}(path))


#Save to PNG (avoid use of "export" keyword):
#-------------------------------------------------------------------------------
FileIO2.save(p::Plot, file::File{PNGFmt}) = exportplot(p, "PNG", file.path)

#Save to EPS (avoid use of "export" keyword):
#-------------------------------------------------------------------------------
function FileIO2.save(p::Plot, file::File{EPSFmt})
	sendcmd(p, "DEVICE \"EPS\" OP \"bbox:page\"")
	exportplot(p, "EPS", file.path)
end

#Export to SVG.  (Fix Grace output according W3C 1999 format):
#TODO: Make more robust... use more try/catch.
#NOTE: Replace xml (svg) statements using Julia v3 compatibility.
#-------------------------------------------------------------------------------
function FileIO2.save(p::Plot, file::File{SVGFmt})
	tmpfilepath = "./.tempgraceplotexport.svg"
	#Export to svg, using the native Grace format:
	exportplot(p, "SVG", tmpfilepath)
	#NOTE: Is this the 2001 format?  Most programs do not appear to read it.

	local src
	retries = 3
	twait = 1 #sec
	wait_expfact = 2#Exponential factor to increase wait time
	success = false


	while !success
		try
#			tmpfilepath = "nope"
			src = open(tmpfilepath, "r")
			success = true
		catch e
			retries -= 1
			sleep(twait)
#			@show twait
			twait *= wait_expfact
			if retries < 0
				rethrow(e)
			end
		end
	end
	
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

#Last line
