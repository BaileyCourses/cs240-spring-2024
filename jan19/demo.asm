;;; Professor Bailey
;;; Spring 2024

include cs240.inc
	
DOSEXIT = 4C00h
DOS = 21h

.8086

.data

greeting BYTE "Hello, from DOS!!", 0
	
.code

;;; Entry point for the program

greet PROC
	mov	dx, OFFSET greeting
	call	WriteString
;	call	NewLine
	ret
greet ENDP

main PROC
	mov	ax, @data	; Setup the data segment
	mov	ds, ax

	;; Start of DOS program...

	call	greet
	
	mov	ax, DOSEXIT	; Signal DOS that we are done
	int	DOS
main ENDP
END main
