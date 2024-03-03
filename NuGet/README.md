# NuGet

This project demonstrates how to use the NuGet package manager within a BitMagic project.

## Referencing a NuGet package

The project references the NuGet project on the first line of the `main.bmasm` file. Note, NuGet references do not need to be at the top of the file, however it is a good place for them.

Consider the following;

``` C#
nuget SixLabors.ImageSharp, 3.0.2;
```

This instructs BitMagic to download `SixLabors.ImageSharp` version 3.0.2 from the NuGet repository, and places the dlls in the binary folder along with the other binaries that are produced by the build process. It will also load the assembly into memory so it needs no further references within the code.

Your code will still need to include `using` declarations.

If the version number is omitted then the latest version will be used.

## How the example works

The example code will use [ImageSharp](https://sixlabors.com/products/imagesharp/) to take an arbitrary image, resize it to 320x240, and reduce the palette to that of the Commander X16.

This is achieved by these lines near the start of the file:

``` C#
var image = Image.Load<Rgba32>(@"..\assets\m65.png");
image.Mutate(i => i.Resize(320, 240).Quantize(new PaletteQuantizer(palette)));
File.WriteAllBytes(@$"..\sdcard\{filename}", GetX16Image(image, palette));
```

The default palette is stored in the int array `palette`. A helper function is then called to convert to a array of `Color` objects which ImageSharp can use. A second helper function can then lookup a `Color` to find the index to create a binary file in the local folder `sdcard`.

In the `project.json` we set that folder to be imported onto the virtual SD Card within the emulator.

The rest of the `main.bmasm` file then sets up the display so that layer 0 is a 8bpp bitmap where the base address is at $00000 in VRAM. We then use [MACPTR](https://github.com/X16Community/x16-docs/blob/master/X16%20Reference%20-%2005%20-%20KERNAL.md#function-name-macptr) to load the binary data into VRAM via `DATA0`.
