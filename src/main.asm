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


.relativeinclude on

.openfile "../base_files/eboot.bin", "../bin/eboot.bin", 0x880134C

.org            0x088215D4

j               preload

.org            0x0886242C; read hook

j               read

.org            0x088641F0; cryptoskip hook

j               cryptoskip

.org            0x088642E8; skip size check

nop

.org            0x08864390; seek hook

jal             seek

.org            0x089E02A0

.include        "preload.asm"
.include        "modelloader.asm"

.close
