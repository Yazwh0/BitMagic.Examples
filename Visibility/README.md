# Visibility

A small text library that keeps most of itself private, and hands out a few carefully chosen names with `.export`. One of them is a label on the operand of an `lda`, two procedures deep, so `main` can reach straight into the library's code and change which string it prints.

## How to run it

Open the folder in VSCode and press `F5`. The project has `autobootRun` set, so the program runs as soon as the emulator starts:

```text
V1.2
HELLO FROM MAIN
FROM MAIN
WRITTEN STRAIGHT INTO THE LDA
3
```

## The library

The library lives in its own file, [text.bmasm](src/text.bmasm), written as plain bmasm with no C#. Its first line, `file library code`, makes it a library whose code goes after the main program, and `main.bmasm` brings it in with an import:

```bmasm
import Text="text.bmasm";
```

See [Libraries](https://bitmagic.org/templateengine/libraries) for how `file library` and sections work.

Inside the file, the library is wrapped in its own `.scope`, so its names don't mix with `main`'s and `main` reaches them as `text:...`. The scope is the boundary for visibility: code in the `text` scope can use every name in it, and code outside can only use the public ones. See [Scope](https://bitmagic.org/compiler/scope) for how names are resolved.

```bmasm
file library code

.scope private text
    .export line_count lines                    ; a second name for lines
    .export reprint print:write                 ; the procedure inside print
    .export string print:write:source           ; the operand label inside that
    .export version MAJOR * 256 + MINOR         ; an expression

    .const MAJOR 1              ; private
    .const MINOR 2              ; private
    .const RETURN 13            ; private
    .padvar byte lines          ; private: how many lines have been written

    .proc public print
        stx write:source
        sty write:source + 1

        ; print falls through into write, which prints whatever source points at
        .proc write
            ldx #0
        .loop:
            lda source: $ffff, x    ; an operand label
            ...
        .endproc
    .endproc

    .proc newline               ; private
        ...
    .endproc
.endscope
```

- `private` after `.scope` makes private the default, so everything in the library is private unless it says `public`. A library usually wants most of itself hidden, so this saves writing `private` on every line.
- `print` is marked `public`, so it's the one procedure `main` can call by its own name.
- `newline`, `write`, `lines` and the constants are private. Code anywhere in the `text` scope can use them, which is how `write` calls `newline` and counts into `lines`, but nothing outside can.
- The four `.export` lines are the rest of the library's public face. An export is always public, even in a private scope, and they sit at the top so the public names are easy to find. They can name things declared further down, like any forward reference. They have to be inside the `text` scope, though: written anywhere else they can't open up a name `text` keeps private.

## Operand labels

`print` reads the string with a label inside the `lda` itself, so it doesn't need a zero page pointer. `source` is the address of the `lda`'s operand: `print` writes the string's address there, then falls through into `write` to print it.

That makes `source` the library's "current string", and `write` a way to print it again. Exporting them gives `main` both, under names that don't give away how the library works:

- `string` is `print:write:source`, an operand label two procedures deep. It's an alias, not a copy, so writing to `text:string` changes the `lda`. It keeps its `ushort` type, so `string + 1` is the high byte.
- `reprint` is `print:write`. An export can name a procedure as easily as a variable, so `main` can call into the middle of `print` without `write` being public.
- `line_count` is `lines`, so `main` can read the count but the name `lines` stays private.

## Exporting an expression

An export doesn't have to be a single name. `version` is `MAJOR * 256 + MINOR`, evaluated like a `.const` written in the library, so it can use the private constants without making them public. `main` gets one value and takes it apart with `>` and `<`:

```bmasm
    lda #>text:version          ; the major version
    clc
    adc #'0'
    jsr BSOUT
    ...
    lda #<text:version          ; the minor version
```

If the library moves to 1.3, only `MINOR` changes, and `main` can't come to depend on how the version is stored.

## Using it from main

After printing the version, `main` prints a string the normal way:

```bmasm
    ldx #<hello
    ldy #>hello
    jsr text:print              ; HELLO FROM MAIN
```

`string` still points at `hello` afterwards, so `main` steps it on past `HELLO ` and prints what's left:

```bmasm
    clc
    lda text:string
    adc #6
    sta text:string
    lda text:string + 1
    adc #0
    sta text:string + 1
    jsr text:reprint            ; FROM MAIN
```

Or points it somewhere new without going through X and Y:

```bmasm
    lda #<poked
    sta text:string
    lda #>poked
    sta text:string + 1
    jsr text:reprint            ; WRITTEN STRAIGHT INTO THE LDA
```

Finally it reads `text:line_count`, which is 3 as `write` counts every line, however it was reached.

## What main can't reach

`main` has five lines commented out, each reaching for something the library keeps to itself. Uncomment one and build to see what happens:

| Line | What it reaches for | Result |
| ---- | ------------------- | ------ |
| `jsr text:newline` | a private procedure | Error: `'text:newline' is private to 'App:text'.` |
| `lda #text:RETURN` | a private constant | Error: `Cannot compile line '#text:RETURN': 'text:RETURN' is private to 'App:text'.` |
| `lda text:lines` | a private variable | Error: `'text:lines' is private to 'App:text'.` |
| `jsr text:print:write` | a private procedure inside `print` | Error: `'text:print:write' is private to 'App:text'.` |
| `lda text:print:write:source` | a label inside that procedure | Error: `'text:print:write:source' is private to 'App:text'.` |

The exports are the only way in. `text:reprint` and `text:string` are the same addresses as the last two lines, but the library chose to make them public.

Labels are always private to their scope, as they're how the library finds its way around inside rather than part of what it offers. Reaching a label in a public procedure still builds for now, with a warning suggesting `.export`; it will become an error in a later release.

## Debugging

The debugger ignores all of this. Private names, labels and exports are all listed in the Variables pane and can be evaluated, and an export shows the name or expression it stands for.
