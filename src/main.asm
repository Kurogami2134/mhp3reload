.psp


PSP_O_RDONLY    equ         0x00000001
PSP_O_WRONLY    equ         0x00000002
PSP_O_RDWR      equ         0x00000003
PSP_O_NBLOCK    equ         0x00000010
PSP_O_APPEND    equ         0x00000100
PSP_O_CREAT     equ         0x00000200
PSP_O_TRUNC     equ         0x00000400
PSP_O_EXCL      equ         0x00000800
PSP_O_NOWAIT    equ         0x00008000
PSP_O_NPDRM     equ         0x40000000

sceIoWrite      equ         0x08960A00
sceIoRead       equ         0x08960A10
sceIoRename     equ         0x08960A18
sceIoClose      equ         0x08960A20
sceIoGetStat    equ         0x08960A28
sceIoOpen       equ         0x08960A40
sceIoSeek       equ         0x08960A48

SIZE_LOAD_HOOK  equ         0x08863CB8


.relativeinclude on

.openfile "../base_files/eboot.bin", "../bin/eboot.bin", 0x880134C

.org            0x088215D4

j               preload

.org            0x089E02A0

.include        "preload.asm"

.close

.create         "../bin/mlhooks.bin", 0x08800500

.word           0x0886242C; read hook
.word           0x4

j               read

.word           0x088641F0; cryptoskip 
.word           0x4
.resetdelay

j               cryptoskip

.word           0x088642E8; skip size check
.word           0x4

nop

.word           SIZE_LOAD_HOOK; fix bugged sizes when loading non existent files
.word           0x8

j               fix_file_size
nop

.word           0x08864390; seek hook
.word           0x4

jal             seek

.word           -1
.word           0

.close

.create         "../bin/ml", 0x08801140

.include        "modelloader.asm"

.close

.include        "mldebug.asm"
