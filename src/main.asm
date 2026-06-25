PSP_O_RDONLY    equ         0x00000001
PSP_O_WRONLY    equ         0x00000002
PSP_O_RDWR      equ         0x00000003
PSP_O_NBLOCK    equ         0x00000010
PSP_O_APPEND    equ         0x00000100
PSP_O_CREAT     equ         0x00000200
PSP_O_TRUNC     equ         0x00000400
PSP_O_EXCL      equ         0x00000800
PSP_O_NOWAIT    equ         0x00008000
PSP_O_NPDRM     equ         0x40000000

.openfile EBOOT_FILE, "../bin/eboot.bin", EBOOT_LOAD

.org            PRELOAD_HOOK

j               preload

.org            PRELOAD_LOAD

.include        "preload.asm"

.close

.create         "../bin/modloader.bin", 0x08800000 - 0x10
.ascii "0.01"

.word 1
.word @main_block_end - @main_block_start
.ascii "FLRP"

@main_block_start:

.include        "modelloader.asm"

@main_block_end:


.word 2
.word           READ_HOOK
.halfword       read - @main_block_start
.byte           8
.byte           0


.word 2
.word           CRYPTO_HOOK
.halfword       cryptoskip - @main_block_start
.byte           8
.byte           0


.word 0
.word           SIZE_CHECK_SKIP
.word           0x4
    nop


.word 2
.word           SIZE_LOAD_HOOK; fix bugged sizes when loading non existent files
.halfword       get_file_size - @main_block_start
.byte           8
.byte           1


.word 2
.word           SEEK_HOOK
.halfword       seek - @main_block_start
.byte           0xC
.byte           0


.word 0
.word           CONT_SEEK_PATCH ;  allow seek in contiguous files
.word           0x4
    nop

.word -1

.asciiz "File Replacer v1.5 - Kurogami2134"
.close
