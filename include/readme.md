# TODO

CI builds

# current state

bins built with:
```
zig build-lib -fstrip -dynamic -O ReleaseFast -z nocopyreloc --gc-sections -fno-allow-shlib-undefined -fno-formatted-panics -fPIC -fPIE -freference-trace -fno-unwind-tables -Bsymbolic -fno-emit-implib  -fbuiltin -fno-single-threaded .\dicemath.zig -target $TARGET
```

to get some proof this works prior to automating any of this.