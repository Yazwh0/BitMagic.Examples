# Command Line POC

A proof of concept for passing parameters to a machine code program from the BASIC prompt, much like a command line tool on a modern OS. The example is a minimal `cat`: give it a filename and it prints that file from the SD card.

## How to run it

Open the folder in VSCode and press `F5`. This builds `src/cat.bmasm` to `app/CAT` and puts it on the SD card with `bit.txt` and `magic.txt`. At the BASIC prompt, type:

```text
^CAT" BIT.TXT
```

The contents of `bit.txt` are printed. Try `^CAT" MAGIC.TXT` to show the other file.

## How it works

A line typed at the BASIC prompt is held in the input buffer at `$0200`. Loading and running a program with the `^` wedge leaves that buffer alone, so the program can read the rest of the line itself.

First it scans the buffer for the `"` that closes the program name:

```bmasm
    .const startAddress = 0x200 + 3;

    ldx #0
.loop:
    inx
    beq overflow
    lda startAddress, x
    cmp #'"'
    bne -loop
```

Then it skips any spaces and copies the rest of the line into `buffer`, up to the null at the end of the line. Its length is the `y` register, which is pushed for later.

The parameter is then used as the filename:

1. `SETLFS` and `SETNAM` set up logical file 3 on device 8 with the filename from `buffer`, and `OPEN` opens it.
2. `CHKIN` makes it the input channel.
3. A loop reads each character with `CHRIN` and prints it with `CHROUT`, until `READST` reports the end of the file.
4. `CLRCHN` and `CLOSE` tidy up, and the program returns to BASIC.

```bmasm
.read_loop:
    jsr CHRIN
    jsr CHROUT

    jsr READST
    beq read_loop       ; any status bit (EOF or error) ends the read
```

As a proof of concept there's no error handling. A missing file or a parameter longer than 128 bytes stops at a `.exception` in the debugger.
