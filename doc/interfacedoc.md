## Grace.jl: Interface Documentation

### Axes

Objects describing axis types are created with the `paxes` function:
```
log_lin = paxes(xscale = :log, yscale = :lin)
```
**Supported scales:**
 - `:lin`, `:log`, `:reciprocal`

The `paxes` function also allows the user to specify axis ranges:
```
ax_rng = paxes(xmin = 0.1, xmax = 1000, ymin = 1000, ymax = 5000)
```

### Line Style

Objects describing line style are created with the `line` function:
```
default_line = line(style=:ldash, width=8, color=1)
```

**Supported styles:**
 - `:none`, `:solid`, `:dot`, `:dash`, `:ldash`, `:dotdash`, `:dotldash`,
   `:dotdotdash`, `:dotdashdash`

### Glyphs

Objects describing display glyphs (markers/symbols) are created with the `glyph` function:
```
glyph(shape=:diamond, color=5)
```

**Supported shapes:**
 - `:circle`, `:o`, `:square`, `:diamond`, `:uarrow`, `:larrow`, `:darrow`,
   `:rarrow`, `:cross`, `:+`, `:diagcross`, `:x`, `:star`, `:*`, `:char`\*
 - \*See demo2 for use of `:char`.

