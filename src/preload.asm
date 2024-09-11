@path:
    .asciiz     "ms0:/P3rdML/mods.bin"
    .align
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

    move        a0, v0
    addiu       a1, sp, 0xE
    jal         sceIoRead
    li          a2, 0x2
    
    lh          t9, 0xE(sp)
@loop:
    beq         t9, zero, @end
    nop

    lh          a0, 0xC(sp)
    addiu       a1, sp, 0x10
    jal         sceIoRead
    li          a2, 0x8

    lh          a0, 0xC(sp)
    lw          a1, 0x10(sp)
    jal         sceIoRead
    lw          a2, 0x14(sp)

    lh          t9, 0xE(sp)
    addiu       t9, -0x1
    j           @loop
    sh          t9, 0xE(sp)
@end:
    lh          a0, 0xC(sp)
    jal         sceIoClose
    nop

; Load Model Loader tables
    addiu		sp, sp, -0x1
    li			a0,	path
    li			a1, PSP_O_RDONLY
    jal 		sceIoOpen
    li			a2, 0x1FF
    sb			v0, 0x0(sp)
    move		a0, v0
    li			a1, 0x8802030
    jal 		sceIoRead
    li			a2, 0x4
    lb			a0, 0x0(sp)
    li			a1, 0x8802030
    jal 		sceIoRead
    lw			a2, 0x0(a1)
    jal 		sceIoClose
    lb			a0, 0x0(sp)
    lui			t7, 0x886
    sw			zero, 0x42E8(t7)
    addiu		sp, sp, 0x1

    lw          v0, 0x0(sp)
    lw          v1, 0x4(sp)
    lw          ra, 0x8(sp)

    jr          ra
    addiu       sp, sp, 0x18
