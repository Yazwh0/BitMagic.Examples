# BitMagic Example Projects

A set of small projects, each showing a different part of [BitMagic](https://bitmagic.org). They're also on the website at [bitmagic.org/examples](https://bitmagic.org/examples/).

Most are ready to go: open the folder in VSCode and press `F5`. A few need some setup first, so check the example's readme.

Some examples pull in other repositories, so clone with submodules:

```sh
git clone --recurse-submodules https://github.com/Yazwh0/BitMagic.Examples.git
```

## [Hello World](HelloWorld/README.md)

An over engineered Hello World! Five different ways to print `HELLO WORLD!`, each using a different BitMagic feature.

## [Data Generation](DataGeneration/README.md)

Uses C# to generate sine tables at compile time, then uses them to move a sprite around the screen.

## [NuGet](NuGet/README.md)

References a NuGet package from a `.bmasm` file, using ImageSharp to convert an image to the X16 palette as part of the build.

## [FX Cache](FX/Cache/README.md)

How to use VERA's FX cache to copy VRAM four bytes at a time.

## [Command Line POC](CommandLinePoc/README.md)

A proof of concept for passing parameters to a machine code program from the BASIC prompt, demonstrated with a minimal `cat`.

## [ROM](Rom/README.md)

How to write your own ROM code with BitMagic, and how to debug the official X16Community ROM.

## [cc65 Library](Cc65Library/README.md)

Imports a library built with cc65 into a BitMagic project, using ZSMKit to play music.

## [ca65 Application](Ca65Application/readme.md)

A simple application written in ca65 and debugged in BitMagic using the `ld65` debug file.

## [Dream Tracker](Ca65DreamTracker/readme.md)

A much larger ca65 application: Dream Tracker, debugged in BitMagic.

## [BitBench](https://github.com/Yazwh0/BitBench)

A proof of concept task switching and text based windowing system.
