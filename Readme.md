# Monster Hunter Portable 3rd mod loader + file replacer

A delusional lance main's attempt at making a mod loader.

## File replacer format

Files for file replacer should be placed in `ms0:P3rdML/files/`, and should be named as their file id/index.

## Mods file format

`mods.bin` file must contain mods in the following format:

| Type    | Description   |
| ------- | ------------- |
| U Int   | Load Address  |
| U Int   | *Mod Length   |
| Byte[n] | Mod content   |

* Most significant bit from Mod Length is used to determine if the mod should be run as it's loaded.

and end in `0xFFFFFFFF00000000`.

## File structure

 - `ms0:/P3rdML/mods.bin` is the file where mods are loaded from.
 - `ms0:/P3rdML/files/` should contain all the files to load as replacements

## Required files

- Decrypted `eboot.bin`
