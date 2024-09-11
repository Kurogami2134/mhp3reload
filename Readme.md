# Monster Hunter Portable 3rd mod loader + file replacer

A delusional lance main's attempt at making a mod loader.

## File replacer format

| U Int       | File length - 8  |
| File tables | 8 bytes per file |

### File table row

| U Int   | Offset in `DATA.BIN`|
| char[4] | Filename            |

## Mods file format

| Section | Description                |
| ------- | -------------------------- |
| Header  | Short containing mod count |
| Mods    | Mods one after another     |

### Mod format

| Type    | Description  |
| ------- | ------------ |
| U Int   | Load Address |
| U Int   | Mod Length   |
| Byte[n] | Mod content  |

## File structure

 - `ms0:/P3rdML/mods.bin` is the file where mods are loaded from.
 - `ms0:/P3rdML/files/` should contain all the files to load as replacements
 - `ms0:/P3rdML/files/file` should contain file tables

## Required files

- Decrypted `eboot.bin`
