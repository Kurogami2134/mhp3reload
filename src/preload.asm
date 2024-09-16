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

@loop:
    lh          a0, 0xC(sp)
    addiu       a1, sp, 0x10
    jal         sceIoRead
    li          a2, 0x8

    lw          t9, 0x10(sp)
    li          t8, 0xFFFFFFFF
    beq         t9, t8, @end
    nop

    lh          a0, 0xC(sp)
    lw          a1, 0x10(sp)
    jal         sceIoRead
    lw          a2, 0x14(sp)

    j           @loop
    nop
@end:
    lh          a0, 0xC(sp)
    jal         sceIoClose
    nop

    lw          v0, 0x0(sp)
    lw          v1, 0x4(sp)
    lw          ra, 0x8(sp)

    jr          ra
    addiu       sp, sp, 0x18
