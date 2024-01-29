;;; Professor Bailey
;;; Spring 2024

include cs240.inc
	
DOSEXIT = 4C00h
DOS = 21h

.8086

.data
	
hi BYTE "Hi", 0

.code

Nhi PROC
	pushf
	push	cx
	push	si
	push	dx

	mov	cx, dx
	mov	dx, OFFSET hi

	mov	si, 0
	jmp	cond
top:
	call	WriteString
	call	NewLine
	inc	si
cond:	
	cmp	si, cx
	jb	top

done:	
	pop	dx
	pop	si
	pop	cx
	popf
	ret
Nhi ENDP

;;; Entry point for the program

main PROC
	mov	ax, @data	; Setup the data segment
	mov	ds, ax

	;; Start of DOS program...

	mov	dx, 5
	call	Nhi
	
	mov	ax, DOSEXIT	; Signal DOS that we are done
	int	DOS
main ENDP
END main
