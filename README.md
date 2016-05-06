# GracePlot.jl

[Sample Plots](https://github.com/ma-laforge/FileRepo/tree/master/GracePlot/sampleplots/README.md) (might be out of date).<br>

## Description

The GracePlot.jl module is a simple control interface for Grace/xmgrace - providing more publication-quality plotting facilities to Julia.

## Samples

The [sample](sample/) directory contains a few demonstrations on how to use GracePlot.jl.

The [template](sample/template/) directory contains a repository of sample Grace template (parameter) files.

A few [sample plots](https://github.com/ma-laforge/FileRepo/tree/master/GracePlot/sampleplots/) are included in a separate repository.

## Configuration

By default, GracePlot.jl assumes Grace is accessible from the environment path as `xmgrace`.  To specify a different command/path, simply set the `GRACEPLOT_COMMAND` environment variable.

The value of `GRACEPLOT_COMMAND` can therefore be set from `.juliarc.jl` with the following:

	ENV["GRACEPLOT_COMMAND"] = "/home/laforge/bin/xmgrace2"

## Dependencies

The GracePlot.jl module requires the following software/modules:

 - The Julia Language <http://julialang.org/>
 - Grace/xmgrace: 2D Plotting Tool <http://plasma-gate.weizmann.ac.il/Grace/>

## Known Limitations

GracePlot.jl currently provides a relatively "bare-bones" interface (despite offering significant functionality).

 - Does not currently provide much in terms of input validation.
 - Does not support the entire Grace control interface.
  - In particular: GracePlot.jl does not support Grace math operations.  Users are expected to leverage Julia for processing data before plotting.
 - On certain runs, Grace will complain that some commands cannot be executed... almost like commands are sent too fast for Grace, or something...  Not sure what this is.  Try re-running.

### SVG Issues

GracePlot.jl will post-process SVG files in an attempt to support the W3C 1999 standard.  The changes enable most new web browsers to display the SVG outputs.  Note, however, that text will not appear correctly on these plots.

The EPS format is therefore suggested if high-quality vector plots are desired.

### Compatibility

Extensive compatibility testing of GracePlot.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.4.2 / Grace-5.1.23.

## Disclaimer

The GracePlot.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
