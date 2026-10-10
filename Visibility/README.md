# Visibility

A small text library that keeps most of itself private. `main` prints a line through the library's one public procedure, then prints how many lines the library has written, read through a name the library exports. Everything else in the library is out of `main`'s reach, and the build tells you so if `main` tries.

## How to run it

Open the folder in VSCode and press `F5`. The project has `autobootRun` set, so the program runs as soon as the emulator starts:

```text
HELLO FROM MAIN
1
```

## The library

The library is wrapped in its own `.scope`, so its names don't mix with `main`'s and `main` reaches them as `text:...`. The scope is the boundary for visibility: code in the `text` scope can use every name in it, and code outside can only use the public ones. See [Scope](https://bitmagic.org/compiler/scope) for how names are resolved.

```bmasm
.scope private text
    .export line_count lines    ; exports are always public: a public name for lines

    .const RETURN 13            ; private
    .padvar byte lines          ; private: how many lines print has written

    .proc public print
        ...
    .endproc

    .proc newline               ; private
        lda #RETURN
        jmp BSOUT
    .endproc
.endscope
```

- `private` after `.scope` makes private the default, so everything in the library is private unless it says `public`. A library usually wants most of itself hidden, so this saves writing `private` on every line.
- `print` is marked `public`, so it's the one procedure `main` can call.
- `newline`, `RETURN` and `lines` are private. Code anywhere in the `text` scope can use them, which is how `print` calls `newline` and counts into `lines`, but nothing outside can.
- `.export` gives `lines` a second name, `line_count`, and an export is always public, even in a private scope. It's an alias, not a copy, so `main` reads the same byte `print` writes. It sits at the top so the library's public names are easy to find, and it can name `lines` before `lines` is declared, like any forward reference. It has to be inside the `text` scope, though: written anywhere else it can't open up a name `text` keeps private.

## Using it from main

`main` only uses the public names:

```bmasm
    ldx #<hello
    ldy #>hello
    jsr text:print              ; print is public, so main can call it

    lda text:line_count         ; 1, through the export
```

## What main can't reach

`main` has four lines commented out, each reaching for something the library keeps to itself. Uncomment one and build to see what happens:

| Line | What it reaches for | Result |
| ---- | ------------------- | ------ |
| `jsr text:newline` | a private procedure | Error: `'text:newline' is private to 'App:text'.` |
| `lda #text:RETURN` | a private constant | Error: `Cannot compile line '#text:RETURN': 'text:RETURN' is private to 'App:text'.` |
| `lda text:lines` | a private variable | Error: `'text:lines' is private to 'App:text'.` |
| `lda text:print:loop` | a label inside `print` | Builds, with a warning: `'text:print:loop' is a label in 'App:text:print', so is private to 'App:text'. Use .export to make it visible.` |

Labels are always private to their scope, as they're how the library finds its way around inside rather than part of what it offers. For now reaching in still builds, with that warning; it will become an error in a later release.

## Operand labels

`print` reads the string with a label inside the `lda` itself, so it doesn't need a zero page pointer. `source` is the address of the `lda`'s operand, and `print` writes the string's address there before the loop:

```bmasm
    stx source              ; source is the operand of the lda below
    sty source + 1
    ldx #0
.loop:
    lda source: $ffff, x    ; an operand label
```

Like any label, `source` is private to the `text` scope. To let other code set it, export it inside the scope: `.export print_source print:source`. The export keeps its `ushort` type, so `print_source + 1` is still the high byte. An export can also be an expression: `.export print_source_hi print:source + 1` names the high byte directly.

## Debugging

The debugger ignores all of this. Private names, labels and exports are all listed in the Variables pane and can be evaluated, and an export shows the name or expression it stands for.
