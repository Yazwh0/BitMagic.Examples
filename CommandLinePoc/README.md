# Command Line POC

A proof of concept showing how a machine code program on the X16 can read parameters passed to it on the BASIC command line, much like a command line tool on a modern OS.

The example is a minimal `cat`: it takes a filename as a parameter, opens that file on the SD card and prints its contents to the screen.

## How it works

When a command is typed at the BASIC prompt it is held in the input buffer at `$0200`. Loading and running a program with the `^` wedge leaves that buffer intact, so the program can read the rest of the line itself.

`src/cat.bmasm`:

1. Scans the input buffer for the closing `"` after the program name.
2. Skips any spaces to find the start of the parameter, then copies it into `buffer`.
3. Uses the parameter as the filename for `SETNAM`, then `OPEN`s it on device 8.
4. Reads the file with `CHRIN` and writes each character with `CHROUT` until `READST` reports end of file.
5. Closes the file and returns to BASIC.

There is no error handling: a missing file or an over long parameter raises an exception in the debugger via `.exception`.

## Running it

1. Open this folder in VSCode and start the **Debug Application** launch configuration. This compiles `src/cat.bmasm` to `app/CAT` and puts it, together with `bit.txt` and `magic.txt`, onto the SD card image.
2. At the BASIC prompt type:

```
^CAT" BIT.TXT
```

The contents of `bit.txt` will be printed. Try `^CAT" MAGIC.TXT` to show the other file.
