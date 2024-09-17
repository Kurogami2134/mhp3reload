.area 0x28, 0x0
@path:
    .ascii      "ms0:/P3rdML/mods"
@path_end:
    .ascii      ".bin"
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
    li          a2, 0x4

    lw          a2, 0x10(sp)
    li          t8, 0xFFFFFFFF
    beq         a2, t8, @ret
    nop

    lh          a0, 0xC(sp)
    li          a1, @path_end
    jal         sceIoRead
    nop

    j           load_mods
    nop

@ret:

    lh          a0, 0xC(sp)
    jal         sceIoClose
    nop

    lw          v0, 0x0(sp)
    lw          v1, 0x4(sp)
    lw          ra, 0x8(sp)

    jr          ra
    addiu       sp, sp, 0x18

load_mods:
    li          a0, @path
    li          a1, PSP_O_RDONLY
    jal         sceIoOpen
    li          a2, 0x1FF
    
    sh          v0, 0xE(sp)

@ml_loop:
    lh          a0, 0xE(sp)
    addiu       a1, sp, 0x10
    jal         sceIoRead
    li          a2, 0x8

    lw          t9, 0x10(sp)
    li          t8, 0xFFFFFFFF
    beq         t9, t8, @end
    nop

    lw          a1, 0x10(sp)
    lw          a2, 0x14(sp)

; discard first bit from file size
    sll         a2, a2, 0x1
    srl         a2, a2, 0x1

    jal         sceIoRead
    lh          a0, 0xE(sp)

; check if mod is to be run at load time
    lw          a0, 0x14(sp)
    srl         a0, a0, 0x1F
    beq         a0, zero, @no_run
    nop
    lw          a0, 0x10(sp)
    jalr        a0
    nop

@no_run:

    j           @ml_loop
    nop

@end:
    lh          a0, 0xE(sp)
    jal         sceIoClose
    nop

    j           @loop
    nop
