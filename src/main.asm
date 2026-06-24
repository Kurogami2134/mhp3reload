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

.create         "../bin/modloader.bin", 0x08800000 - 0x10
.ascii "0.01FLRP"

.word 1
.word @main_block_end - @main_block_start

@main_block_start:

.include        "modelloader.asm"

@main_block_end:


.word 2
.word           0x0886242C; read hook
.halfword       read - @main_block_start
.byte           8
.byte           0

.word 2
.word           0x088641F0; cryptoskip 
.halfword       cryptoskip - @main_block_start
.byte           8
.byte           0

.word 0
.word           0x088642E8; skip size check
.word           0x4
    nop


.word 2
.word           SIZE_LOAD_HOOK; fix bugged sizes when loading non existent files
.halfword           get_file_size - @main_block_start
.byte           8
.byte           1

.word 2
.word           0x08864390; seek hook
.halfword           seek - @main_block_start
.byte           0xC
.byte           0

.word 0
.word           0x08864374; allow seek in contiguous files
.word           0x4
    nop

.word -1
.close
