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
		j			openfile
		nop
closeopenfile:
		li			t7, file_id
		lb			t6, 0x0(t7)
		beq			t6, zero, checkfile
		nop
		jal			sceIoClose
		move		a0, t6
		li			t7, file_id
		sb			zero, 0x0(t7)
		j			checkfile
		nop
openfile:
		addiu		sp, sp, -0x60
		li			a0, path
		jal 		sceIoGetStat
        move		a1, sp

        slt         at, v0, zero
        bnel        at, zero, ret_seek
        addiu		sp, sp, 0x60

		lw			t7, 0x8(sp)
		li			t6, filesize
		sw			t7, 0x0(t6)
		addiu		sp, sp, 0x60
		li			a0, path
		li			a1, PSP_O_RDONLY
		jal 		sceIoOpen
        li			a2, 0x1FF
		li			t7, file_id
		sb			v0, 0x0(t7)

		lw			ra, 0x0(sp); return skipping the seek, and with the file open
		jr			ra
		addiu		sp, sp, 0x10
read:
		addiu		sp, sp, -0x4
		sw			ra, 0x0(sp)
		li			t7, file_id
		lb			t7, 0x0(t7)
		beq			t7, zero, ret_read
		nop
		li			t6, filesize
		lw			t6, 0x0(t6)
		move		a0, t7
		move		a2, t6
ret_read:
		lw			ra, 0x0(sp)
		j   		sceIoRead
		addiu		sp, sp, 0x4
seek:
		addiu		sp, sp, -0x10
        sw          a0, 0x4(sp)
        sw          a1, 0x8(sp)
        sw          a2, 0xC(sp)
		j			closeopenfile
		sw			ra, 0x0(sp)
ret_seek:
		lw			ra, 0x0(sp)
        lw          a0, 0x4(sp)
        lw          a1, 0x8(sp)
        lw          a2, 0xC(sp)
        li          a3, 0x0
        li          t0, 0x0
		j           sceIoSeek
		addiu		sp, sp, 0x10

cryptoskip:
    li			t7, file_id
    lb			t6, 0x0(t7)
    beq			t6, zero, decrypter
    nop
    j			0x088641F8
    nop

decrypter:
    lui			ra, 0x0886
    j			0x08863998
    addiu		ra, ra, 0x41F8

    .halfword   0
path:
    .ascii		"ms0:/P3rdML/files/"
path_end:
    .ascii      "file"
    .byte		0
file_id:
    .byte       0
    .align
filesize:
    .word       0
