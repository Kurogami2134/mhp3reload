.psp

sceIoWrite      equ         0x08960A00
sceIoRead       equ         0x08960A10
sceIoRename     equ         0x08960A18
sceIoClose      equ         0x08960A20
sceIoGetStat    equ         0x08960A28
sceIoOpen       equ         0x08960A40
sceIoSeek       equ         0x08960A48

EBOOT_LOAD      equ         0x0880134C
PRELOAD_HOOK    equ         0x088215D4
PRELOAD_LOAD    equ         0x089E02A0

;  289.75kb free
MOD_ENTRY_ADD   equ         0x09FA2100
MOD_LOAD_ADD    equ         MOD_ENTRY_ADD + 0x800 ;  reserve 256 entries

SIZE_LOAD_HOOK  equ         0x08863CB8
READ_HOOK       equ         0x0886242C
SEEK_HOOK       equ         0x08864390
CRYPTO_HOOK     equ         0x088641F0
CRYPTO_CONT     equ         0x08863998
SIZE_CHECK_SKIP equ         0x088642E8
CONT_SEEK_PATCH equ         0x08864374

MODS_FILE       equ         "ms0:/P3RDML/MODS"
ALIGN_PATH      equ         0
FILES_DIR       equ         "ms0:/P3RDML/FILES/"

EBOOT_FILE      equ         "../base_files/eboot.bin"

.relativeinclude on

.include "main.asm"
