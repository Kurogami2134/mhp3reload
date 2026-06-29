@path:
.asciiz MAIN_DIR + "PRELOAD.BIN"

.align 4

.func initialize_preload
    addiu       sp, sp, -0x18
    sw          v0, 0x0(sp)
    sw          v1, 0x4(sp)
    sw          ra, 0x8(sp)
    sw          s0, 0x10(sp)
    sw          s1, 0x14(sp)

    
    li          a0, @path
    jal         sceIoGetStat
    addiu       a1, sp, -0x60

    slt         at, v0, zero
    bnel        at, zero, @preload_not_found
    nop

    lw          s1, -0x58(sp)

    li          a0, @path
    li          a1, PSP_O_RDONLY
    jal         sceIoOpen
    li          a2, 0x1FF
    move        s0, v0

    li          a1, PRELOAD_LOAD
    move        a2, s1
    jal         sceIoRead
    move        a0, v0

    move        a0, s0
    jal         sceIoClose
    nop

    lw          v0, 0x0(sp)
    lw          v1, 0x4(sp)
    lw          ra, 0x8(sp)
    lw          s0, 0x10(sp)
    lw          s1, 0x14(sp)

    j           preload + PRELOAD_LOAD
    addiu       sp, sp, 0x18

@preload_not_found:
    lw          v0, 0x0(sp)
    lw          v1, 0x4(sp)
    lw          ra, 0x8(sp)
    lw          s0, 0x10(sp)
    lw          s1, 0x14(sp)

    jr          ra
    addiu       sp, sp, 0x18

.endfunc
