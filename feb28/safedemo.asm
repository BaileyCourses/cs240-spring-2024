;;; Professor Bailey
;;; Spring 2023

include cs240.inc
include notes\macros.asm
include notes\safe.asm
	
DOSEXIT = 4C00h
DOS = 21h
BIOS = 10h

TIMER = 1Ch

.8086

.data
	
.code

.data
bufblock	LABEL	BYTE
startcan	BYTE	"*****************"
buffer	BYTE	10 DUP("-")
endcan		BYTE	"**********"
blocksize = $ - bufblock
.code
	
WriteBlock PROC
	push	dx
	push	cx

	mov	dx, OFFSET bufblock
	mov	cx, blocksize
	call	WriteBuffer
	call	NewLine
	pop	cx
	pop	dx
	ret
WriteBlock ENDP

main PROC
	mov	ax, @data	; Setup the data segment
	mov	ds, ax

	call	NewLine
	call	WriteBlock

	mWrite	"Enter your name: "
	mov	dx, OFFSET buffer
	push	dx
	mov	dx, LENGTHOF buffer
	push	dx
	call	SafeRead
	add	sp, 4
	call	NewLine

	mWriteLn "This is the value that was returned:"
	call	WriteBlock

	mWriteLn "Program exited normally"
	mov	ax, DOSEXIT	; Signal DOS that we are done
	int	DOS
main ENDP
END main
