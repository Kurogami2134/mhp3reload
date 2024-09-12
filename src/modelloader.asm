checkfile:
		li			t7, MLTables
	@@loop:
		lw			t6, 0x0(t7)
		beq			t6, zero, openfile
		nop
		bnel		t6, a2, @@loop
		addiu		t7, t7, 0x8
		lw			t5, 0x4(t7)
		li			t7, path_end
		sw			t5, 0x0(t7)
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
		bne			a2, t6, ret_seek
		nop
		addiu		sp, sp, -0x60
		li			a0, path
		jal 		sceIoGetStat
        move		a1, sp
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
		addiu		sp, sp, 0x4
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
		addiu		sp, sp, -0x4
		j			closeopenfile
		sw			ra, 0x0(sp)
ret_seek:
		lw			ra, 0x0(sp)
		j           sceIoSeek
		addiu		sp, sp, 4

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
MLTables:
.word       0x22e41000
.ascii      "1496"
