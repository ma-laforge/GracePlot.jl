#GracePlot template accessor functions
#-------------------------------------------------------------------------------

#==
===============================================================================#

#Parameter file format (Not exported):
abstract ParamFmt <: FileIO2.DataFormat

#Return a param
template(name::String) =
	File{ParamFmt}(joinpath(GracePlot.rootpath, "sample/template/$name.par"))

#Last line
