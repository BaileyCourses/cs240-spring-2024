;;; Professor Bailey
;;; Spring 2024

include cs240.inc
	
DOSEXIT = 4C00h
DOS = 21h

.8086

.data
	
msg BYTE "Welcome!", 0
msg2 BYTE "To Hamilton!", 0
.code

occur PROC
	pushf
	push	cx
	push	si
	
	mov	ax, 0
	mov	si, 0
	jmp	cond
top:
	cmp	ch, cl
	jne	nope
	inc	ax
nope:	
	inc	si
cond:	
	mov	cx, [bx + si]
	cmp	cx, 0
	jne	top

	pop	si
	pop	cx
	popf

	ret
occur ENDP

;;; Entry point for the program

main PROC
	mov	ax, @data	; Setup the data segment
	mov	ds, ax

	;; Start of DOS program...

	mov	bx, OFFSET msg
	mov	cl, 'o'
	call	occur
	call	DumpRegs

	mov	ax, DOSEXIT	; Signal DOS that we are done
	int	DOS
main ENDP
END main
