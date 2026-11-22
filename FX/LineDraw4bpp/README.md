# FX Line Draw 4bpp

Draws eight lines with VERA FX's line draw helper, one for each octant, first on a 4bpp bitmap and then on an 8bpp one. It's for comparing the emulator against real hardware.

For the full behaviour of VERA FX, see the [VERA FX reference](https://github.com/X16Community/x16-docs/blob/master/X16%20Reference%20-%2010%20-%20VERA%20FX%20Reference.md).

## How to run it

Open the folder in VSCode and press `F5`, or copy `app/MAIN.PRG` to an SD card and run it on an X16. Press any key to switch between the 4bpp and 8bpp screens.

## What it draws

Each line starts at the centre of the screen and draws 80 pixels, with an X increment of 3/8 of a pixel. A white marker is plotted by the CPU, without FX, where the 81st pixel would go. A correct line runs up to its marker with no gap and doesn't go past it.

| Lines | ADDR1 steps (each pixel) | ADDR0 steps (each time X passes a pixel) |
| --- | --- | --- |
| Shallow, 4bpp | half a byte, using the nibble increment | 160 bytes, a row |
| Steep, 4bpp | 160 bytes, a row | half a byte, using the nibble increment |
| Shallow, 8bpp | 1 byte | 320 bytes, a row |
| Steep, 8bpp | 320 bytes, a row | 1 byte |

The steep 4bpp lines are the interesting ones. In the VERA Verilog (`addr_data.v`), the line helper adds what ADDR0 would step by to ADDR1's address but leaves ADDR1's nibble alone. With ADDR0 on nibble 0, as here, that step is nothing going forwards, and back a byte going backwards. So on hardware the steep 4bpp lines should come out wrong: vertical going right, and two pixels a step going left. The official emulator flips ADDR1's nibble instead, so it draws them correctly.

BitMagic follows the Verilog by default. Set `fixedFxLineDraw` to `true` in `project.json` (or run X16E with `--fixedfxlinedraw`) to draw the steep lines properly, as the official emulator does. See [Fixed FX line draw](https://bitmagic.org/debugger/projectfile#fixed-fx-line-draw).

| `fixedFxLineDraw` | Steep 4bpp lines going right | Steep 4bpp lines going left |
| --- | --- | --- |
| `false` (hardware) | vertical | two pixels a step, so they go past their markers |
| `true` | reach their markers | reach their markers |

The 4bpp lines are drawn with both nibbles of the colour set (`$22`, `$33` and so on). If a write changes the whole byte, the lines look two pixels wide in places.

## Nibble strip

On the 4bpp screen there's a short strip at the top left. With 4 bit mode on and the line helper off, it writes `$23` and `$45` alternately through `DATA0` with the nibble increment set, starting on nibble 0.

- Red, green, red, green: only the addressed nibble is written, taken from the matching nibble of the value.
- Cyan, green, cyan, green: only the addressed nibble is written, taken from the low nibble of the value.
- Anything else: whole bytes are written.
