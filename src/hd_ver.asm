.psp

sceIoWrite      equ         0x08965690
sceIoRead       equ         0x089656A0
sceIoRename     equ         0x089656A8
sceIoClose      equ         0x089656B0
sceIoGetStat    equ         0x089656B8
sceIoOpen       equ         0x089656D0
sceIoSeek       equ         0x089656D8

EBOOT_LOAD      equ         0x0880134C
PRELOAD_HOOK    equ         0x08821818
PRELOAD_INIT    equ         0x089DFE60

;  289.75kb free
MOD_ENTRY_ADD   equ         0x083b5600
MOD_LOAD_ADD    equ         MOD_ENTRY_ADD + 0x800 ;  reserve 256 entries

SIZE_LOAD_HOOK  equ         0x08864EE8
READ_HOOK       equ         0x0886365C
SEEK_HOOK       equ         0x088655c0
CRYPTO_HOOK     equ         0x08865420
CRYPTO_CONT     equ         0x08864bc8
SIZE_CHECK_SKIP equ         0x08865518
CONT_SEEK_PATCH equ         0x088655A4

MAIN_DIR        equ         "ms0:/P3RDHDML/"
ALIGN_PATH      equ         2
FILES_DIR       equ         "ms0:/P3RDHDML/FILES/"

EBOOT_FILE      equ         "../base_files/hd_eboot.bin"

.relativeinclude on

.include "main.asm"
