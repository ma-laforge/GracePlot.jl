[Gallery]: <https://github.com/ma-laforge/FileRepo/tree/master/GracePlot/sampleplots/README.md>
[GallerySProc]: <https://github.com/ma-laforge/FileRepo/tree/master/SignalProcessing/sampleplots/grace_old/README.md>
[JuliaDL]: <https://julialang.org/downloads/>

# GracePlot.jl: Build Grace/xmgrace plots with Julia!

[![Build Status](https://travis-ci.org/ma-laforge/GracePlot.jl.svg?branch=master)](https://travis-ci.org/ma-laforge/GracePlot.jl)

:art: [Galleries (sample output)][Gallery] / [:satellite: CMDimCircuits.jl/SignalProcessing samples][GallerySProc] (Likely out of date.) :art:

## Description

The GracePlot.jl module is a simple control interface for Grace/xmgrace - providing more publication-quality plotting facilities to Julia.

 - GracePlot.jl is ideal for seeding a Grace session with plot data before fine-tuning the output with Grace itself.
 - Grace "templates" (.par) files can then be saved/re-loaded to maintain a uniform appearance in publication.
 - The user is encouraged to pre-process data using math facilities from Julia instead of those built-in to Grace.

## Table of Contents

 1. [Installation](#Installation)
    1. [Configuration](#Configuration)
 1. [Sample Usage](#SampleUsage)
 1. [Interface Documentation](doc/interfacedoc.md)
 1. [Known Limitations](#KnownLimitations)

<a name="Installation"></a>
## Installation

 1. Install Grace/xmgrace ([details](doc/grace_install.md)).
 1. Install Julia ([download here][JuliaDL]).
 1. Install `GracePlot` from the Julia package prompt:
```julia
]add GracePlot
```
 1. Test `GracePlot` from the Julia prompt:
```julia
using GracePlot
include(joinpath(dirname(pathof(GracePlot)), "../sample/runsamples.jl"))
```
<a name="Configuration"></a>
### Configuration

By default, GracePlot.jl assumes Grace is accessible from the environment path as `xmgrace`.  To specify a different command/path, simply set the `GRACEPLOT_COMMAND` environment variable.

The value of `GRACEPLOT_COMMAND` can therefore be set from `~/.julia/config/startup.jl` with the following:

	ENV["GRACEPLOT_COMMAND"] = "/home/laforge/bin/xmgrace2"

<a name="SampleUsage"></a>
## Sample Usage

The [sample](sample/) directory contains a few demonstrations on how to use GracePlot.jl.

The [template](sample/template/) directory contains a repository of sample Grace template (parameter) files.

<a name="KnownLimitations"></a>
## Known Limitations

GracePlot.jl currently provides a relatively "bare-bones" interface (despite offering significant functionality).

 - Does not currently provide much in terms of input validation.
 - Does not support the entire Grace control interface.
   - In particular: GracePlot.jl does not support Grace math operations.  Users are expected to leverage Julia for processing data before plotting.
 - On certain runs, Grace will complain that some commands cannot be executed... almost like commands are sent too fast for Grace, or something...  Not sure what this is.  Try re-running.

### SVG Issues

GracePlot.jl will post-process SVG files in an attempt to support the W3C 1999 standard.  The changes enable most new web browsers to display the SVG outputs.  Note, however, that text will not appear correctly on these plots.

The EPS format is therefore suggested if high-quality vector plots are desired.

### Crashes

The ARRANGE command appears to cause [crashes/logouts](doc/crashissues.md) on certain Linux installs with relatively high occurance.

### Compatibility

Extensive compatibility testing of GracePlot.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-1.1.1 / Grace-5.1.25.

## Disclaimer

The GracePlot.jl API is not perfect.  Backward compatibility issues are to be expected as the module matures.
