# Hello World

An over engineered Hello World! The program prints `HELLO WORLD!` five times, each in a different way. Not all of them are the right way to do it, but each one shows off a different BitMagic feature.

## How to run it

Open the folder in VSCode and press `F5`. The project has `autobootRun` set, so the program runs as soon as the emulator starts and you'll see the message five times.

The project also has `saveGeneratedBmasm` and `saveGeneratedTemplate` set, so after a build you can look in the `bin` folder to see exactly what the C# in `src/main.bmasm` turned into.

## The string

The text is a C# constant at the top of the file, so every method uses the same value:

```bmasm
const string hello_world_string = "HELLO WORLD!\r\n";
```

At the end of the file it's converted to PETSCII and written out as data. `BM.Bytes` adds a null terminator by default.

```bmasm
.hello_world:
    BM.Bytes(BM.StringToPetscii(hello_world_string));
```

## The five methods

### 1. Indexed loop

`bsout_indexed` is the standard approach: index through the string with `x` and call `BSOUT` until it reaches the null terminator.

```bmasm
    ldx #0
.loop:
    lda hello_world, x
    beq done
    jsr BSOUT
    inx
    jmp loop
```

### 2. Self modifying code

`bsout_selfmodifying` isn't the best way to print a string, but it shows two things:

- A label inside an instruction. `read_address` points at the operand of the `lda`, so the code can change the address it reads from.
- Anonymous labels. `.:` defines one, and `+` and `-` jump to the next or previous one.

```bmasm
.:  lda read_address: $1234
    beq +
    jsr BSOUT
    inc read_address
    bne -
    inc read_address + 1
    jmp -
.:  rts
```

### 3. Length from C#

`bsout_indexed_macro` uses a C# expression to get the length of the string at compile time, so it doesn't need the null terminator. `@(...)` puts the result of any C# expression into the assembly.

```bmasm
    ldx #@(hello_world_string.Length)    ; ldx #14
    ldy #0
.:  lda hello_world, y
    jsr BSOUT
    iny
    dex
    bne -
```

### 4. Unrolled loop

`bsout_unrolled` uses a C# `for` loop to write out an `lda` and `jsr BSOUT` for every character. There's no loop at runtime and no data block, just straight line code.

```bmasm
    var toDisplay = BM.StringToPetscii(hello_world_string).ToArray();

    for(var i = 0; i < toDisplay.Length; i++)
    {
        lda #@(toDisplay[i])
        jsr BSOUT
    }
```

The generated `.bmasm` in the `bin` folder shows the 14 pairs of instructions this produces.

### 5. PRIMM

`primm` calls the kernal's `PRIMM`, which prints the null terminated string that directly follows the `jsr`, then returns to the instruction after it. The string is placed inline with `BM.Bytes`. The code selects the kernal ROM bank (bank 0) before the call and restores the previous bank afterwards.

```bmasm
    lda ROM_BANK
    pha
    stz ROM_BANK        ; kernal ROM bank

    jsr PRIMM
    BM.Bytes(BM.StringToPetscii(hello_world_string));

    pla
    sta ROM_BANK
```
