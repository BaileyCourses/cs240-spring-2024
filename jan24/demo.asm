;;; Professor Bailey
;;; Spring 2024

include cs240.inc
	
DOSEXIT = 4C00h
DOS = 21h

.8086

.data
	
.code

swapHighsLows PROC
	push	cx

	mov	cl, ah		; AH <-> DL
	mov	ah, dl
	mov	dl, cl

	pop	cx

	ret
swapHighsLows ENDP

;;; Entry point for the program

main PROC
	mov	ax, @data	; Setup the data segment
	mov	ds, ax

	;; Start of DOS program...

	mov	cx, 7777h

;	...

	mov	ax, 1020h
	mov	dx, 0AABBh

	call	DumpRegs

	call	swapHighsLows

	call	DumpRegs

	mov	ax, DOSEXIT	; Signal DOS that we are done
	int	DOS
main ENDP
END main
