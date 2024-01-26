;;; Professor Bailey
;;; Spring 2024

include cs240.inc
	
.8086

.data
	
prompt BYTE "The value of dx is ", 0

.code

DumpDX PROC
	push	cx
	
	push	dx
	mov	dx, OFFSET prompt
	call	WriteString
	pop	dx
	call	WriteInt

	ret
DumpDX ENDP
END
