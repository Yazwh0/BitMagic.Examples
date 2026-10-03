# ca65 Application

A simple application written with ca65 and debugged in BitMagic. For a much larger example, see [Dream Tracker](../Ca65DreamTracker/readme.md). For how ca65 debugging works in general, see [ca65 Projects](https://bitmagic.org/debugger/ca65).

BitMagic debugs the application using the debug file (`.dbg`) written by `ld65`, which maps the output back to the source. The source must be assembled with `-g` and linked with `--dbgfile`. Object files (`.o`) are optional: if they're listed in `project.json`, BitMagic checks them against the output to catch out of date builds.

## Building

BitMagic can't build a ca65 application, so you'll need cc65 installed with `ca65` and `ld65` on your path. `.vscode/tasks.json` has a `Build` task that assembles and links the application:

```text
ca65 -g -v --cpu 65c02 -g -t cx16 ./src/main.asm -l main.lst
ld65 -v -Ln main.sym -m main.map --dbgfile main.dbg -o BUILD.PRG -C cx16-asm.local.cfg --lib c64.lib ./src/main.o
```

This is a quick example that you can get running without a large toolchain, so it may not be the best way to build a ca65 application.

## Activating the extension

The BitMagic extension only starts when VSCode opens a `.bmasm` file, so the project includes an empty `blank.bmasm`. Open it before you start debugging. Otherwise, pick BitMagic using the *Language Mode* button in the status bar.

## Setting breakpoints

By default VSCode won't let you set breakpoints in `.asm` files. To allow it, set the language of the `.asm` files to `BitMagic X16 Asm`. Sadly this changes how they're formatted, but I haven't found another way to get VSCode to allow it.
