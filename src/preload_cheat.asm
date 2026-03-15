.psp

HOOK            equ         0x08896C98

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


.createfile "../bin/preload.bin", 0x089E02A0 - 8
.word 0x089E02A0
.word end-start
start:

.area 0x28, 0x0
@path:
    .ascii      "ms0:/P3RDML/MODS"
@path_end:
    .ascii      ".BIN"
.endarea

preload:
    addiu       sp, sp, -0x18
    sw          v0, 0x0(sp)
    sw          v1, 0x4(sp)
    sw          ra, 0x8(sp)

    li          a0, @path
    li          a1, PSP_O_RDONLY
    jal         sceIoOpen
    li          a2, 0x1FF
    
    sh          v0, 0xC(sp)

@loop:
    lh          a0, 0xC(sp)
    addiu       a1, sp, 0x10
    jal         sceIoRead
    li          a2, 0x1

    lb          a2, 0x10(sp)
    li          t8, -1
    beq         a2, t8, @ret
    nop

    lh          a0, 0xC(sp)
    li          a1, @path_end
    jal         sceIoRead
    nop

    li          a0, @path
    jal         load_mods
    nop

    b           @loop

@ret:

    lh          a0, 0xC(sp)
    jal         sceIoClose
    nop

    lui         v0, 0x9BB
    lw          a0, 0x7E78(v0)

    j           HOOK + 8
    addiu       sp, sp, 0x18

load_mods:
    addiu       sp, sp, -0x16
    sw          ra, 0x2(sp)
    li          a1, PSP_O_RDONLY
    jal         sceIoOpen
    li          a2, 0x1FF
    
    sh          v0, 0x0(sp)

@ml_loop:
    lh          a0, 0x0(sp)
    addiu       a1, sp, 0x6
    jal         sceIoRead
    li          a2, 0x8

    lw          t9, 0x6(sp)
    li          t8, 0xFFFFFFFF
    beq         t9, t8, @end
    nop

    lw          a1, 0x6(sp)
    lw          a2, 0xA(sp)

; discard first bit from file size
    sll         a2, a2, 0x1
    srl         a2, a2, 0x1

    jal         sceIoRead
    lh          a0, 0x0(sp)

; check if mod is to be run at load time
    lw          a0, 0xA(sp)
    srl         a0, a0, 0x1F
    beq         a0, zero, @no_run
    nop
    lw          a0, 0x6(sp)
    jalr        a0
    nop

@no_run:

    b           @ml_loop
    nop

@end:
    lh          a0, 0x0(sp)
    jal         sceIoClose
    nop

    lw          ra, 0x2(sp)
    jr          ra
    addiu       sp, sp, 0x16


end:
.word           HOOK
.word 8
j               preload
nop
.word -1
.word 0
.close
