.area 0x28, 0x0
@path:
    .ascii      "ms0:/P3RDML/MODS"
@path_end:
    .ascii      ".BIN"
.endarea

@load_address:
.word 0x08800000

@prev_load_address:
.word -1

@format_ver:
.ascii "0.01"

.func preload
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

    lw          v0, 0x0(sp)
    lw          v1, 0x4(sp)
    lw          ra, 0x8(sp)

    jr          ra
    addiu       sp, sp, 0x18

.endfunc

.func load_mods
    addiu       sp, sp, -0x18
    sw          ra, 0x4(sp)
    li          a1, PSP_O_RDONLY
    jal         sceIoOpen
    li          a2, 0x1FF
    
    sh          v0, 0x0(sp)

    lh          a0, 0x0(sp)
    addiu       a1, sp, 0x8
    jal         sceIoRead
    li          a2, 0x8 ;  load mod format ver and id
    
    ;  skip if format ver doesn't match
    lw          a1, 0x8(sp)
    lw          a2, @format_ver
    bne         a1, a2, @end
    nop

@parse_blocks:
    lh          a0, 0x0(sp)
    addiu       a1, sp, 0x8
    jal         sceIoRead
    li          a2, 0x4 ;  load block type

    lh          v0, 0x8(sp)
    seh         v0, v0
    bltz        v0, @end
    nop

    beq         v0, zero, patch_block
    li          v1, 1
    beq         v0, v1, main_block
    li          v1, 2
    beq         v0, v1, hook_block
    nop

@end:
    lh          a0, 0x0(sp)
    jal         sceIoClose
    nop

    lw          ra, 0x4(sp)
    jr          ra
    addiu       sp, sp, 0x18
.endfunc

.func main_block
    lh          a0, 0x0(sp)
    addiu       a1, sp, 0x8
    jal         sceIoRead
    li          a2, 0x4

    lw          a1, @load_address
    lw          a2, 0x8(sp)

; discard first bit from file size
    sll         a2, a2, 0x1
    srl         a2, a2, 0x1

    jal         sceIoRead
    lh          a0, 0x0(sp)

; check if mod is to be run at load time
    lw          a0, 0x8(sp)
    srl         a0, a0, 0x1F
    beq         a0, zero, @@no_run
    nop
    lw          a0, @load_address
    jalr        a0
    nop

@@no_run:
    la          at, @load_address
    lw          a1, 0x0(at)
    sw          a1, 0x4(at)
    lw          a2, 0x8(sp)
    addu        a1, a1, a2
    b           @parse_blocks
    sw          a1, 0x0(at)
.endfunc

.func hook_block
    lh          a0, 0x0(sp)
    addiu       a1, sp, 0x8
    jal         sceIoRead
    li          a2, 0x8

    lw          a0, @prev_load_address
    lh          a1, 0xC(sp)  ; hook offset
    addu        a0, a0, a1
    srl         a0, a0, 2
    
    lb          a1, 0xE(sp)  ; hook op
    sll         a1, a1, 24
    or          a0, a0, a1

    lw          a1, 0x8(sp)  ; hook address
    sw          a0, 0x0(a1)

;  fill with nop
    lb          a0, 0xF(sp)  ; nop fill count
@@add_nop:
    beq         a0, zero, @@end
    addiu       a1, a1, 4
    sw          zero, 0x0(a1)
    b           @@add_nop
    addiu       a0, a0, -1
@@end:
    b           @parse_blocks
    nop
.endfunc

.func patch_block ;  "legacy mod support"
    lh          a0, 0x0(sp)
    addiu       a1, sp, 0x8
    jal         sceIoRead
    li          a2, 0x8

    lw          a1, 0x8(sp)
    lw          a2, 0xC(sp)

; discard first bit from file size
    sll         a2, a2, 0x1
    srl         a2, a2, 0x1

    jal         sceIoRead
    lh          a0, 0x0(sp)

; check if mod is to be run at load time
    lw          a0, 0xC(sp)
    srl         a0, a0, 0x1F
    beq         a0, zero, @@no_run
    nop
    lw          a0, 0x8(sp)
    jalr        a0
    nop

@@no_run:
    b           @parse_blocks
    nop
.endfunc
