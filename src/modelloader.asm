checkfile:
    lhu         v0, 0x2(s2)
    li          t6, 0x4
    li          t7, path_end+3
@@loop:
    beq         t6, zero, @@end
    nop
    andi        v1, v0, 0xF
    addiu       v1, v1, 0x30

    slti        at, v1, 0x3A
    bne         at, zero, @@write
    nop
    addiu       v1, v1, 0x7
@@write:
    sb          v1, 0x0(t7)
    srl         v0, v0, 0x4
    addiu       t7, t7, -1
    j           @@loop
    addiu       t6, t6, -1
@@end:
    j           openfile
    nop

closeopenfile:
    li          t7, file_id
    lb          t6, 0x0(t7)
    beq         t6, zero, checkfile
    nop
    jal         sceIoClose
    move        a0, t6
    li          t7, file_id
    sb          zero, 0x0(t7)
    j           checkfile
    nop

patch_file:
    la          a0, path_end
    li          a1, 0x50
    sb          a1, 0x4(a0)
    la          a0, path

    jal         sceIoGetStat
    move        a1, sp

    slt         at, v0, zero
    bne         at, zero, @@skip
    nop

    la          a0, do_patch
    li          a1, 0x50
    sb          a1, 0x0(a0)

@@skip:
    la          a0, path_end
    sb          zero, 0x4(a0)

    b           ret_seek
    addiu       sp, sp, 0x60


openfile:
    addiu       sp, sp, -0x60
    li          a0, path
    jal         sceIoGetStat
    move        a1, sp

    slt         at, v0, zero
    bnel        at, zero, patch_file
    nop

    lw          t7, 0x8(sp)
    li          t6, filesize
    sw          t7, 0x0(t6)
    addiu       sp, sp, 0x60
    li          a0, path
    li          a1, PSP_O_RDONLY
    jal         sceIoOpen
    li          a2, 0x1FF
    li          t7, file_id
    sb          v0, 0x0(t7)

    lw          ra, 0x0(sp); return skipping the seek, and with the file open
    jr          ra
    addiu       sp, sp, 0x10

read:
    addiu       sp, sp, -0x4
    sw          ra, 0x0(sp)
    li          t7, file_id
    lb          t7, 0x0(t7)
    li          at, lastfile
    beql        t7, zero, ret_read
    sh          zero, 0x0(at)
    li          t6, filesize
    lw          t6, 0x0(t6)
    
    lui         a0, 0x2
    slt         a0, t6, a0
    beq         a0, zero, @@after
    nop
    sh          zero, 0x0(at)
    move        a2, t6
    
@@after:
    move        a0, t7
ret_read:
    lw          ra, 0x0(sp)
    j           sceIoRead
    addiu       sp, sp, 0x4

seek:
    addiu       sp, sp, -0x10
    sw          a0, 0x4(sp)
    sw          a1, 0x8(sp)
    sw          a2, 0xC(sp)
    
    lhu         v0, 0x2(s2)
    li          v1, lastfile
    lh          at, 0x0(v1)
    bne         at, v0, @@after
    nop
    jr          ra
    nop
@@after:
    sh          v0, 0x0(v1)
    j           closeopenfile

    sw          ra, 0x0(sp)
ret_seek:
    lw          ra, 0x0(sp)
    lw          a0, 0x4(sp)
    lw          a1, 0x8(sp)
    lw          a2, 0xC(sp)
    li          a3, 0x0
    li          t0, 0x0
    j           sceIoSeek
    addiu       sp, sp, 0x10

cryptoskip:
    li          t7, file_id
    lb          t6, 0x0(t7)
    beq         t6, zero, decrypter
    nop
    j           0x088641F8
    nop

load_patch:
    addiu       sp, sp, -0xC
    sw          ra, 0x00(sp)
    sw          a2, 0x04(sp)
    sw          v0, 0x08(sp)

    la          a0, path_end
    li          a1, 0x50
    sb          a1, 0x4(a0)
    la          a0, path

    jal         load_mods
    nop

    la          a0, path_end
    sb          zero, 0x4(a0)
    
    lw          ra, 0x00(sp)
    lw          a2, 0x04(sp)
    lw          v0, 0x08(sp)
    j           0x088641F8
    addiu       sp, sp, 0x8

decrypter:
    la          t3, do_patch
    nop
    lb          t4, 0x0(t3)
    sb          zero, 0x0(t3)
    beq         t4, zero, @@default
    nop
    la          ra, load_patch
    b           @@decrypt
    nop
@@default:
    la          ra, 0x088641F8
@@decrypt:
    j           0x08863998
    addiu       ra, ra, 0x

    .align      2
lastfile:
    .halfword       0
path:
    .ascii      "ms0:/P3rdML/files/"
path_end:
    .asciiz      "file"
    .byte       0
file_id:
    .byte       0
do_patch:
    .byte       0
    .align
filesize:
    .word       0
