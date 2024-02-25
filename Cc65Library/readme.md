# CC65 Library Import

This project demonstrates how a CC65 library can be imported into a BitMagic project.

The library used in the example is [ZSMKit](https://github.com/mooinglemur/zsmkit) by Mooinglemur. It is a music playback library, which can play exports from Furnace.

It loads the library and outputs the libraries `ZSMKITLIB` segment that contains the code into the Main segment in the BitMagic project. The segment `ZSMKITBANK` is written to a BitMagic segment within the Banked RAM.

The file is loaded at the end of the example's code. ZSMKit is then called to point to that code. The filename is a macro variable, so we can write the filename into the source but also ensure the length parameter is always correct.

A simple loop that waits until the VSYNC IRQ and then calls ZSMKit's 'tick' function to play back the music.

## Prerequisites

ZSMKit's git repo is included as a [submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules).

This will need to have a recent version pulled and built. To do this please check CC65 and the ZSMKit repo for instructions. The output library file `lib\zsmkit.lib` must be present as this will be imported into the BitMagic project.

## Usage

To import a CC65 library, there is a `import` which ships with BitMagic called `cc65library.bmasm`.

The imported object has three methods:

### Parse

`Cc65Obj Parse(string filename, string scopeName, string sourcePath)`

Loads in a library file and returns the class that represents the object file within.

| Parameter | Description |
| --------- | ----------- |
| filename  | The `.lib` file to load. |
| scopeName | The scope to load the file's exports into. This is to segregate the library from your code. |
| sourcePath | The base path for the library. If the library is compiled with source code mapping, BitMagic will be able to step into the original code. |

### Code

`void Code(string segmentName, Cc65Obj lib)`

Places the code for a given _segment name_ from the referenced library. Check the documentation of the library for the segment names used.

_Note: This is not the segment name in the BitMagic project._

### Exports

`void Exports(Cc65Obj lib)`

Writes the API exports, for example procedure locations and other variables. These will be written to the scope which was set when the library was created.
