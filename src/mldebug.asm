.psp

address	equ	0x08800850

printf	equ	0x88EAA64
hook	equ	0x88E6D64
next	equ	0x88EBAB8

.createfile "../bin/mldebug.bin", address-20

.word	hook
.word	4
jal		start

.word	address
.word	endaddress-address

fmt:
	.asciiz "%s"
	.align 4

start:
    addiu	    sp,sp,-0x8
    sw	        ra, 0x0(sp)
    sw	        a0, 0x4(sp)

    li	        a1, fmt
    li	        a2, path
    sw	        zero, 0x120(a0)
    li	        t7, 0x3
    sb	        t7, 0x12E(a0)
    jal	        printf
    nop

    lw	        a0, 0x4(sp)
    li	        a1, 0x0
    li	        a2, 0x1
    lw	        ra, 0x0(sp)
    addiu	    sp,sp,0x8
    j           next
    nop

endaddress:
    .word	    0xFFFFFFFF
    .word	    0

.close
