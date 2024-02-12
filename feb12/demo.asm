;;; Professor Bailey
;;; Spring 2024

include cs240.inc
	
include notes\cmdline.asm
	
DOSEXIT = 4C00h
DOS = 21h

.8086

.data
	
cmd BYTE 257 DUP(0)

.code


;;; Entry point for the program

main PROC
	mov	ax, @data	; Setup the data segment
	mov	ds, ax

	;; Start of DOS program...
	mov	dx, OFFSET cmd
	call	GetCommandLine
	push	dx
	mov	dl, "'"
	call	WriteChar
	pop	dx
	call	WriteString
	mov	dl, "'"
	call	WriteChar
	call	NewLine

	mov	ax, DOSEXIT	; Signal DOS that we are done
	int	DOS
main ENDP
END main
