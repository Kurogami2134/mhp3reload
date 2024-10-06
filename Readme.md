# Monster Hunter Portable 3rd mod loader + file replacer

A delusional lance main's attempt at making a mod loader.

## File replacer format

Files for file replacer should be placed in `ms0:P3rdML/files/`, and should be named as their file id/index.

## Mods file format

Mods are now divided into multiple mod files, with `mods.bin` now containing tables with their paths.

### `mods.bin` Format

| Type    | Description                                       |
| ------- | ------------------------------------------------- |
| U Byte  | Path length                                       |
| Byte[n] | File path, starting with `/` and ending in `0x00` |

* Max path length is 22 (not counting the `/` at the start, nor the null byte at the end).

`mods.bin` must end in `0xFFFFFFFF`.

### Mod file format

Mod files must contain mods in the following format:

| Type    | Description   |
| ------- | ------------- |
| U Int   | Load Address  |
| U Int   | *Mod Length   |
| Byte[n] | Mod content   |

* Most significant bit from Mod Length is used to determine if the mod should be run as it's loaded.

and end in `0xFFFFFFFF00000000`.

## File structure

 - `ms0:/P3rdML/mods.bin` should contain a list of mod files.
 - `ms0:/P3rdML/mods/` should contain mod files or folders.
 - `ms0:/P3rdML/files/` should contain all the files to load as replacements.

## Required files

- Decrypted `eboot.bin`
