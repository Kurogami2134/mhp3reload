do_patch equ do_patch_ - MOD_DATA
sp_index equ sp_index_ - MOD_DATA
filesize equ filesize_ - MOD_DATA
file_id equ file_id_ - MOD_DATA
path_end equ path_end_ - MOD_DATA
path equ path_ - MOD_DATA
lastfile equ lastfile_ - MOD_DATA
size_path_end equ size_path_end_ - MOD_DATA
size_path equ size_path_ - MOD_DATA


.func get_file_size
    addiu       sp, sp, -0x14
    sw          ra, 0x0(sp)
    sw          a1, 0x4(sp)
    sw          a0, 0x8(sp)
    sw          s0, 0xC(sp)

    bal         @@get_offset
    nop
@@get_offset:
    addiu       s0, ra, (MOD_DATA - @@get_offset)

    move        v0, a1
    li          t6, 0x4
    addiu       t7, s0, size_path_end+3
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
    b           @@loop
    addiu       t6, t6, -1
@@end:
    addiu       a0, s0, size_path
    jal         sceIoGetStat
    addiu       a1, sp, -0x60

    slt         at, v0, zero
    bnel        at, zero, @@ret
    nop
    
    lw          ra, 0x0(sp)
    lw          s0, 0xC(sp)
    lw          v1, -0x58(sp)
    j           0x08863CD0
    addiu       sp, sp, 0x14

@@ret:
    lw          a1, 0x4(sp)
    lw          a0, 0x8(sp)
    lw          s0, 0xC(sp)
    lw          ra, 0x0(sp)
    sll         v0, a1, 2
    addu        v0, v0, a0
    j           SIZE_LOAD_HOOK + 8
    addiu       sp, sp, 0x14
.endfunc

checkfile:
    lhu         v0, 0x2(s2)
    li          t6, 0x4
    addiu       t7, s0, path_end+3
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
    b           @@loop
    addiu       t6, t6, -1
@@end:
    b           openfile
    nop

closeopenfile:
    addiu       t7, s0, file_id
    lb          t6, 0x0(t7)
    beq         t6, zero, checkfile
    nop
    jal         sceIoClose
    move        a0, t6
    addiu       t7, s0, file_id
    sb          zero, 0x0(t7)
    b           checkfile
    nop

patch_file:
    addiu       sp, sp, -0x4
    sb          a1, 0x0(sp)
    addiu       a0, s0, path_end
    sb          a1, 0x4(a0)
    addiu       a0, s0, path

    jal         sceIoGetStat
    addiu       a1, sp, 4

    slt         at, v0, zero
    bne         at, zero, @@skip
    nop

    addiu       a0, s0, do_patch
    lb          a1, 0x0(sp)
    sb          a1, 0x0(a0)

@@skip:
    li          a1, 0x50
    lb          a0, 0x0(sp)
    bnel        a1, a0, patch_file
    addiu       sp, sp, 4

    addiu       a0, s0, path_end
    sb          zero, 0x4(a0)

    b           ret_seek
    addiu       sp, sp, 0x64


openfile:
    addiu       sp, sp, -0x60
    addiu       a0, s0, path
    jal         sceIoGetStat
    move        a1, sp

    slt         at, v0, zero
    addiu       a0, s0, sp_index
    lb          a1, 0x0(a0)
    beql        a1, zero, @@patch_instead
    addiu       a1, a1, 0x50
    b           @@load_sp
    nop
@@patch_instead:
    bnel        at, zero, patch_file
    nop

@@load_sp:
    beq         at, zero, @@continue
    nop

    addiu       a0, s0, path_end
    addiu       a1, a1, 0x30
    sb          a1, 0x4(a0)
    addiu       a0, s0, path
    jal         sceIoGetStat
    move        a1, sp

    slt         at, v0, zero
    addiu       a0, s0, sp_index
    lb          a1, 0x0(a0)
    bnel        at, zero, patch_file
    addiu       a1, a1, 0x50

@@continue:

    lw          t7, 0x8(sp)
    addiu       t6, s0, filesize
    sw          t7, 0x0(t6)
    addiu       sp, sp, 0x60
    addiu       a0, s0, path
    li          a1, PSP_O_RDONLY
    jal         sceIoOpen
    li          a2, 0x1FF
    addiu       t7, s0, file_id
    sb          v0, 0x0(t7)

    lw          ra, 0x0(sp); return skipping the seek, and with the file open
    jr          ra
    addiu       sp, sp, 0x10

read:
    addiu       sp, sp, -0x8
    sw          ra, 0x0(sp)
    sw          s0, 0x4(sp)

    bal         @@get_offset
    nop
@@get_offset:
    addiu       s0, ra, (MOD_DATA - @@get_offset)

    addiu       t7, s0, file_id
    lb          t7, 0x0(t7)
    addiu       at, s0, lastfile
    beql        t7, zero, ret_read
    sh          zero, 0x0(at)
    addiu       t6, s0, filesize
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
    lw          s0, 0x4(sp)
    j           sceIoRead
    addiu       sp, sp, 0x8

seek:
    addiu       sp, sp, -0x14
    sw          ra, 0x0(sp)
    sw          a0, 0x4(sp)
    sw          a1, 0x8(sp)
    sw          a2, 0xC(sp)
    sw          s0, 0x10(sp)
    
    bal         @@get_offset
    nop
@@get_offset:
    addiu       s0, ra, (MOD_DATA - @@get_offset)
    
    lhu         v0, 0x2(s2)
    addiu       v1, s0, lastfile
    lh          at, 0x0(v1)
    bne         at, v0, @@after
    nop
    lw          ra, 0x0(sp)
    jr          ra
    addiu       sp, sp, 14
@@after:
    sh          v0, 0x0(v1)
    j           closeopenfile
    nop
ret_seek:
    lw          ra, 0x0(sp)
    lw          a0, 0x4(sp)
    lw          a1, 0x8(sp)
    lw          a2, 0xC(sp)
    lw          s0, 0x10(sp)
    li          a3, 0x0
    li          t0, 0x0
    j           sceIoSeek
    addiu       sp, sp, 0x14

.func cryptoskip
    addiu       sp, sp, -4
    sw          ra, 0x0(sp)
    bal         @@get_offset
    nop
@@get_offset:
    addiu       t7, ra, (MOD_DATA - @@get_offset) + file_id
    lw          ra, 0x0(sp)
    addiu       sp, sp, 4

    lb          t6, 0x0(t7)
    beq         t6, zero, decrypter
    nop
    j           0x088641F8
    nop
.endfunc

load_patch:
    addiu       sp, sp, -0x10
    sw          ra, 0x00(sp)
    sw          a2, 0x04(sp)
    sw          s0, 0x08(sp)
    sw          v0, 0x0C(sp)

    bal         @@get_offset
    nop
    @@get_offset:
    addiu       s0, ra, (MOD_DATA - @@get_offset)

    addiu       t3, s0, do_patch
    lb          a1, 0x0(t3)
    sb          zero, 0x0(t3)

    addiu       a0, s0, path_end
    sb          a1, 0x4(a0)
    addiu       a0, s0, path

    jal         load_mods
    nop

    addiu       a0, s0, path_end
    sb          zero, 0x4(a0)
    
    lw          ra, 0x00(sp)
    lw          a2, 0x04(sp)
    lw          s0, 0x08(sp)
    lw          v0, 0x0C(sp)
    j           0x088641F8
    addiu       sp, sp, 0xC

decrypter:
    addiu       sp, sp, -4
    sw          ra, 0x0(sp)
    bal         @@get_offset
    nop
@@get_offset:
    addiu       t7, ra, (MOD_DATA - @@get_offset)
    lw          ra, 0x0(sp)
    addiu       sp, sp, 4


    addiu       t3, t7, do_patch
    lb          t4, 0x0(t3)
    beq         t4, zero, @@default
    nop
    addiu       ra, t7, (MOD_DATA - load_patch)
    b           @@decrypt
    nop
@@default:
    la          ra, 0x088641F8
@@decrypt:
    j           0x08863998
    addiu       ra, ra, 0x

MOD_DATA:
size_path_:
    .ascii      "ms0:/P33DML/FILES/"
size_path_end_:
    .asciiz      "file"
    .word       0
    .align      2
lastfile_:
    .halfword       0
path_:
    .ascii      "ms0:/P3RDML/FILES/"
path_end_:
    .asciiz      "FILE"
    .word       0
file_id_:
    .byte       0
do_patch_:
    .byte       0
sp_index_:
    .byte       0
    .align 4
filesize_:
    .word       0
