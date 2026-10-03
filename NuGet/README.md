# NuGet

How to use a NuGet package in a BitMagic project. The example uses [ImageSharp](https://sixlabors.com/products/imagesharp/) to convert an image to the X16 palette while the program is built, then displays it.

## How to run it

Open the folder in VSCode and press `F5`. The build converts `assets/m65.png` and writes it to the SD card, and the program loads it into VRAM as a 320x240 bitmap. You'll need an internet connection the first time, so BitMagic can download the package.

## Referencing a NuGet package

The first line of `src/main.bmasm` references the package:

```bmasm
nuget SixLabors.ImageSharp, 3.0.2;
```

This downloads version 3.0.2 of `SixLabors.ImageSharp` from NuGet and puts its DLLs in the `bin` folder with the rest of the build output. It also loads the assembly, so there's nothing else to reference. Leave out the version number to use the latest one.

The reference doesn't have to be on the first line, but the top of the file is a good place for it. Your code will still need `using` statements:

```bmasm
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;
using SixLabors.ImageSharp.Processing.Processors.Quantization;
using SixLabors.ImageSharp.PixelFormats;
```

## Converting the image

These lines near the start of the file load the image, resize it to 320x240, reduce it to the X16's default palette and write the result as a binary file:

```bmasm
    var image = Image.Load<Rgba32>(@"..\assets\m65.png");
    image.Mutate(i => i.Resize(320, 240).Quantize(new PaletteQuantizer(palette)));
    File.WriteAllBytes(@$"..\sdcard\{filename}", GetX16Image(image, palette));
```

The default palette is the `int` array `colours`. One helper method turns it into the `Color` objects ImageSharp needs. A second looks up each pixel's `Color` to find its palette index, which gives one byte per pixel.

`project.json` adds the `sdcard` folder to the emulator's SD card, so the program can load the file.

## Displaying it

The rest of `src/main.bmasm` sets layer 0 to an 8bpp bitmap at `$00000` in VRAM, then uses the kernal's [MACPTR](https://github.com/X16Community/x16-docs/blob/master/X16%20Reference%20-%2005%20-%20KERNAL.md#function-name-macptr) to load the file straight into VRAM through `DATA0`.
