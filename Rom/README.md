# ROM

How to write your own ROM code with BitMagic, and how to debug the official [X16Community ROM](https://github.com/X16Community/x16-rom) with full source.

## Writing ROM code

To write ROM code, define a segment that starts in the ROM window and writes to its own file. This defines a segment called `ROM` at `$c000`, up to `$4000` bytes long, written to `ROMEXAMPLE.BIN`:

```bmasm
.segment ROM, $c000, $4000, ROMEXAMPLE.BIN

.0xc000_entry:
    nop
.breakpoint
    nop

    rts
```

To tell the emulator where that file goes, add it to `romSource` in `project.json`. This puts it in ROM bank 16:

```json
"romSource": [
    {
        "filename": "app/ROMEXAMPLE.BIN",
        "bank": 16,
        "address": "0xc000"
    }
]
```

`src/test.bmasm` is a small program that switches to bank 16 and calls `$c000`, so you can step from your program into the ROM code:

```bmasm
    lda ROM_BANK
    pha

    lda #16
    sta ROM_BANK
    jsr $c000

    pla
    sta ROM_BANK
```

## Debugging the X16Community ROM

The ROM source is included as the `x16-rom` submodule, so clone with `--recurse-submodules`. BitMagic doesn't build the ROM, so build it before you start debugging.

### Building the ROM with debug information

BitMagic maps the ROM back to its source using the debug files ld65 writes with `--dbgfile`. The ROM's own `Makefile` doesn't ask for them, and we don't change the submodule, so build it with the `Makefile` in this folder instead:

```sh
make
```

This needs `make`, `patch` and cc65, eg in WSL. It applies `patches/x16-rom-dbgfile.patch` to a copy of the ROM's `Makefile` in `build/`, which adds `--dbgfile` to each ld65 line, then runs that copy in `x16-rom`. The output is the same as the ROM's own build, plus a `.dbg` file for each part, eg `x16-rom/build/x16/kernal.dbg`. `make clean` runs the ROM's clean.

If the patch no longer applies after the submodule is updated, recreate it by adding `--dbgfile $(BUILD_DIR)/<part>.dbg` after `-o $@` on each ld65 line of `x16-rom/Makefile` and saving the diff over `patches/x16-rom-dbgfile.patch`.

### The project

The ROM is made of several parts, each linked separately. Each part is a `cc65` entry in the `files` array of `project.json`. For example, the kernal:

```json
{
    "type": "cc65",
    "outputs": [
        {
            "filename": "build/x16/kernal.bin",
            "hasHeader": false
        }
    ],
    "debugFile": "build/x16/kernal.dbg",
    "objectFiles": [
        "build/x16/kernal/declare.o",
        "build/x16/kernal/vectors.o",
        "..."
    ],
    "sourcePath": "kernal",
    "includes": [
        "c:\dev\CC65\asminc\longbranch.mac"
    ],
    "basePath": "x16-rom"
}
```

- `outputs` names the file as ld65 did, so with the path from the `Makefile`. The load address comes from the debug file.
- `objectFiles` is optional, and is used to warn if the build is out of date.
- `includes` are cc65 files the ROM uses from the cc65 install. If the ROM was built in WSL, the debug file has the Linux path, so these are matched by filename. Change them to match your cc65 install.

The example has entries for the kernal, DOS, FAT32 and BASIC. Each output is written to `outputFolder` with its path, eg `app/build/x16/kernal.bin`, and added to `romSource` with its bank, so the debugger knows which file is where. `romBankSymbols` loads the symbols for the other banks.

When debugging the ROM, `romFile` must point at the `rom.bin` you built (`x16-rom/build/x16/rom.bin`), not the default one, otherwise the source won't match what's running.
