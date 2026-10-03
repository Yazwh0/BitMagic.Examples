# Dream Tracker

[Dream Tracker](https://www.dreamtracker.org/) by Tim Soderstrom is an excellent [tracker](https://en.wikipedia.org/wiki/Music_tracker) for the X16, written with ca65. It's a much larger application than the [ca65 Application](../Ca65Application/readme.md) example, so it shows more of the cc65 support in `project.json`, including overlay files loaded at runtime.

The source is on GitLab at [m00dawg/dream-tracker](https://gitlab.com/m00dawg/dream-tracker), and is included here as the `dream-tracker` submodule, so clone with `--recurse-submodules`.

BitMagic debugs the application using the debug file (`.dbg`) written by `ld65`, which maps the output files back to the source. The source must be assembled with `-g` so the debug file has line information.

## ROM version

Dream Tracker currently needs an R47 ROM. BitMagic can download it for you: see [ROM](https://bitmagic.org/emulator/rom).

## Building

BitMagic can't build a ca65 application, so you'll need cc65 installed with `cl65` on your path. The `Build` task in `.vscode/tasks.json` runs automatically before the debugger starts.

It runs the same `cl65` command as Dream Tracker's `Makefile`, with two additions:

- `-g` to include line information. `cl65` only applies options to the files after them, so it must come before `dreamtracker.asm`.
- `-Wl --dbgfile,../dreamtracker.dbg` to write the debug file. It's written outside the `dream-tracker` folder so the build doesn't change the Dream Tracker repository.

## The project file

The `cc65` entry in `project.json` points at the debug file and lists the output files to debug: `DT.PRG`, and the overlay modules in `DAT/*` that Dream Tracker loads at runtime. `basePath` is the folder the build runs from, as paths in the debug file are relative to it.

```json
{
    "type": "cc65",
    "outputs": [
        {
            "filename": "DT.PRG",
            "default": true,
            "hasHeader": true
        },
        {
            "filename": "DAT/*",
            "hasHeader": false
        }
    ],
    "debugFile": "../dreamtracker.dbg",
    "basePath": "dream-tracker"
}
```

The project also copies Dream Tracker's `SAMPLES`, `SCR` and `SONGS` folders to the SD card, and boots straight into `DT.PRG` with `autobootFile`.

## Activating the extension

The BitMagic extension only starts when VSCode opens a `.bmasm` file, so the project includes an empty `blank.bmasm`. Open it before you start debugging. Otherwise, pick BitMagic using the *Language Mode* button in the status bar.

## Setting breakpoints

By default VSCode won't let you set breakpoints in `.asm` files. To allow it, set the language of the `.asm` files to `BitMagic X16 Asm`. Sadly this changes how they're formatted, but I haven't found another way to get VSCode to allow it.
