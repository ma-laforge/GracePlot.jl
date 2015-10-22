# GracePlot.jl

## Description

The GracePlot.jl module is a simple control interface for Grace/xmgrace - providing more publication-quality plotting facilities to Julia.

## Samples

The [sample](sample/) directory contains a few demonstrations on how to use GracePlot.jl.

The [template](sample/template/) directory contains a repository of sample Grace template (parameter) files.

## Dependencies

The GracePlot.jl module requires the following software/modules:

 - The Julia Language <http://julialang.org/>
 - <sup>1</sup>Grace/xmgrace: 2D Plotting Tool <http://plasma-gate.weizmann.ac.il/Grace/>

NOTE:

 - <sup>1</sup>GracePlot.jl expects Grace to be present in the Julia shell environment through the command `xmgrace`.

## Known Limitations

GracePlot.jl currently provides a relatively "bare-bones" interface (despite offering significant functionality).

 - Does not currently provide much in terms of input validation.
 - Does not support the entire Grace control interface.
  - In particular: GracePlot.jl does not support Grace math operations.  Users are expected to leverage Julia for processing data before plotting.
 - On certain runs, Grace will complain that some commands cannot be executed... almost like commands are sent too fast for Grace, or something...  Not sure what this is.  Try re-running.

### Compatibility

Extensive compatibility testing of GracePlot.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.4.0 / Grace-5.1.23.

## Disclaimer

The GracePlot.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
