# ROM Building and Debugging

This example shows how to write ROM code using BitMagic and debug the official ROM from the X16 Community.

## Writing ROM Code

To write ROM code using BitMagic is as simple as defining the segment to start within ROM and be outputted to its own file.

For example this defines a ROM segment called `ROM` starting at 0xc000, with a maximum length of 0x4000 to a file called 'ROMEXAMPLE.BIN'.

To load that into the ROM we need to BitMagic where in ROM the file is. this is done using the `romSource` objects in `project.json, for example this will load our example into bank 16.

```json
    "romSource": [
        {
            "filename": "app/ROMEXAMPLE.BIN",
            "bank": 16,
            "address": "0xc000"
        }
    ],
```

A very basic example and application to call into the test ROM is included.

## Debugging the Community X16 ROM

Included in this example is a git 'submodule' for the community X16 ROM. To ensure this is brought in correctly use the `--include-submodules` option when cloning this repository.

There is no extensions within this project to build the ROM, so you will need to do that before starting the debugging session.

### CC65

Debugging the ROM is defined in two parts. How the individual parts of the ROM are built, which is defined within config files that CC65 uses to build and link the ROM. We need to mirror what the Makefile does within the `files` array within `project.json`.

The files which are generated must then be added to the ROM like the BitMagic example so the debugger knows which files are where within ROM.

If you are debugging the ROM, be sure to always use the `rom.bin` that is built and not the default one to avoid conflicts.
