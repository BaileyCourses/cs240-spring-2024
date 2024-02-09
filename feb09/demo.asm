;;; Professor Bailey
;;; Spring 2024

include cs240.inc
	
DOSEXIT = 4C00h
DOS = 21h

include notes\fileio.asm

.8086

.data

filename BYTE "demo.lst", 0
buffer BYTE 100 DUP(0)

	
.code

;;; Entry point for the program

main PROC
	mov	ax, @data	; Setup the data segment
	mov	ds, ax

	;; Start of DOS program...

	mov	dx, OFFSET filename
	call	OpenFile

	mov	dx, OFFSET buffer
	mov	cx, 100
	call	ReadFile

	mov	dx, OFFSET buffer
	call	WriteString
	call	NewLine

	mov	ax, DOSEXIT	; Signal DOS that we are done
	int	DOS
main ENDP
END main
