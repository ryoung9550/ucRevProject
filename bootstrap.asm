bits 16

jmp boot_start

bootStr db "huh? lul", 0xa, 0xd, 0
readSuc db "Disk Read successful!", 0xa, 0xd, 0
startDiskRead db "Starting Disk Read...", 0xa, 0xd, 0
readFail db "Disk Read Failed!", 0xa, 0xd, 0
numSectors db "Number of sectors read: ", 0
printNum_errMsg db "ERROR: printNum", 0xa, 0xd, 0
asciiNumLow db 0x30
asciiNumHigh db 0x39
newline_char db 0xa
carriageRet_char db 0xd
diskVerify_err db "ERROR: Disk failed validation!", 0xa, 0xd, 0
diskVerify_suc db "Disk validation successful!", 0xa, 0xd, 0

boot_start:
	xor eax, eax
	mov ax, 0x07C0
	mov ds, ax ; Set data segment
	add ax, 0x1000 ; after the bootstrap section

	; Set up for the stack frame
	cli ; Stop interupts
	mov ss, ax
	add ax, 0x800 ; 2 MegaBytes
	mov sp, ax
	mov bp, sp
	sti ; Restart interupts

	call clear
	call verifyDisk

	push bootStr
	call printStr ; print bootStr
	add sp, 2


	mov al, 234 ; al = 5
	call printNum_r8 ; print al(5)

	; Check for successful printNum
	cmp ax, 0
	je printNum_errDone
	push printNum_errMsg
	call printStr
	add sp, 2
printNum_errDone:
	

	; Setup disk Read
	mov bx, 0x7E00
	mov al, 1 ; num of sectors to be read
	mov cx, 0x0002
	mov dh, 0 ; head number
	mov dl, 2 ;	driver number
	xor dl, dl
	call read_sectors_16

	jb readDiskSuc
	jmp readDiskFail
	readDiskSuc:
	push readSuc
	jmp readDiskStat
	readDiskFail:
	call printNum_r8
	push readFail
	jmp readDiskStat
readDiskStat:
	call printStr
	add sp, 2

	push bootStr
	call printStr
	add sp, 2

	

	; Swap es and ds for easy access from disk read
	;mov ax, es
	;mov ds, ax

	jmp $


;############################################################
;#                       SUBROUTINES                        #
;############################################################


;###############################################
; METHOD: printNum
; BREIF: Prints the digit in the AL register then 
;        prints a newline
; ARGS: AL - Number printed on screen
;###############################################

printNum_r8:
	push bp
	mov bp, sp
	push bx
	xor bx, bx
	and ax, 0x00ff ; mask low 8 bits of ax
	mov bl, 100
	idiv bl
	add al, 0x30 ; convert decimal to ascii
	call printChar
	mov al, ah
	and ax, 0x00ff
	mov bl, 10
	idiv bl
	add al, 0x30
	call printChar
	mov al, ah
	add al, 0x30
	call printChar
	;jb outOfBounds_num
	;cmp al, [asciiNumHigh]
	;ja outOfBounds_num
	mov al, [newline_char]
	call printChar
	mov al, [carriageRet_char]
	call printChar
	mov ax, 0

	jmp printNum_end
outOfBounds_num:
	mov ax, 1
printNum_end:
	pop bx
	pop bp
	ret

;###############################################
; METHOD: printChar()
; BREIF: Prints the ascii character in AL
; ARGS: AL - Ascii character that will print to screen
;###############################################

; al = char code to print
printChar:
	push ax
	push bx
	mov ah, 0xe
	mov bh, 0
	int 0x10
	pop bx
	pop ax
	ret

;###############################################
; METHOD: printStr()
;###############################################

printStr:
	push bp
	mov bp, sp
	mov di, [bp + 4]
printStr_loop:
	mov al, [di]
	or al, al
	jz printStr_end
	call printChar
	inc di
	jmp printStr_loop
printStr_end:
	pop bp
	mov ax, 0
	ret

;###############################################
; METHOD: readSectors_16()
;###############################################

read_sectors_16:
	pusha
	mov di, 0x04

	.attempt:
	push startDiskRead
	call printStr
	add sp, 2
	mov ah, 0x02
	int 0x13
	jnc .end
	dec di
	cmp di, di
	jz .end
	xor ah, ah
	int 0x13
	jnc .attempt
	jmp .end

	.end:
	popa
	ret

;###############################################
; METHOD: readDisk()
;###############################################

readDisk:
	mov ah, 0x02
	int 0x13
	ret

;###############################################
; METHOD: verifyDisk()
;###############################################

verifyDisk:
	push ax
	push cx
	push dx

	mov ah, 0x04 ; interrupt argument
	mov al, 0x01 ; number of sectors to verify
	mov ch, 0x00 ; cylinder number
	mov cl, 0x22 ; sector number
	mov dh, 0x00 ; head number
	mov dl, 0x00 ; driver number
	int 0x13 ; call disk management service

	jb verifyDisk_err ; if there are errors
	push diskVerify_suc
	call printStr
	add sp, 2
	jmp verifyDisk_end

verifyDisk_err:
	push diskVerify_err
	call printStr
	add sp, 2

verifyDisk_end:
	pop dx
	pop cx
	pop ax
	ret

;###############################################
; METHOD: clear()
;###############################################
clear:
	push ax
	xor ax, ax
	mov ah, 0x42
	int 0x10
	pop ax
	ret


	TIMES 510 - ($-$$) db 0
	dw 0xaa55

;###############################################
;#          AFTER BOOT RECORD                  #
;###############################################

ChickenStr db "Chicken lul", 0xa, 0xd, 0
C9lulStr db "C9 LUL", 0xa, 0xd, 0

TIMES 1024 db 0
