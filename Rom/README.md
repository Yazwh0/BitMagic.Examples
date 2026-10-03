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

The ROM source is included as the `x16-rom` submodule, so clone with `--recurse-submodules`. BitMagic doesn't build the ROM, so build it with its own `Makefile` (which needs cc65) before you start debugging.

The ROM is made of several parts, each built from its own cc65 config and object files. Each part is a `cc65` entry in the `files` array of `project.json`, mirroring what the `Makefile` does. For example, the kernal:

```json
{
    "type": "cc65",
    "outputs": [
        {
            "filename": "kernal.bin",
            "referenceFile": "build/x16/kernal.bin",
            "startAddress": 49152,
            "hasHeader": false,
            "default": false
        }
    ],
    "config": "cfg/kernal-x16.cfgtpl",
    "objectFiles": [
        "build/x16/kernal/declare.o",
        "build/x16/kernal/vectors.o",
        "..."
    ],
    "sourcePath": "kernal",
    "basePath": "x16-rom",
    "defaultOutputFile": "kernal.bin"
}
```

The example has entries for the kernal, DOS, FAT32 and BASIC. Like the BitMagic example, each output is then added to `romSource` with its bank, so the debugger knows which file is where. `romBankSymbols` loads the symbols for the other banks.

Note: the `includes` in each entry point at `c:\dev\CC65`. Change them to match your cc65 install.

When debugging the ROM, `romFile` must point at the `rom.bin` you built (`x16-rom/build/x16/rom.bin`), not the default one, otherwise the source won't match what's running.
