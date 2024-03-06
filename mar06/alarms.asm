.data
Alarms	LABEL	WORD
	WORD	20 DUP(0)
HandlerCount = ($ - Alarms) / 4

.code

;;; Note, these data definitions are in the CODE segment (and must be)

OldTimerInterruptVector DWORD 1234ABCDh

timerTickCount	WORD 0

InterruptHandler PROC
	inc	cs:timerTickCount

	pushf
	call	cs:OldTimerInterruptVector
	iret
InterruptHandler ENDP

ErrorExit MACRO text
        LOCAL string
.data
string	BYTE text, 0Dh, 0Ah, 0
.code
        push	dx
	mov	dx, OFFSET string
	call	WriteString
	pop	dx
	mov	ax, DOSEXIT	; Signal DOS that we are done
	int	DOS
ENDM

RegisterAlarm PROC
	;; AX=tick count
	;; DX=Handler offset
	
	pushf
	push	bx
	push	cx

	mov	cx, 0
	mov	bx, OFFSET Alarms
	jmp	cond
top:
	cmp	WORD PTR [bx], 0
	jne	used
	mov	WORD PTR [bx], ax
	mov	WORD PTR [bx + 2], dx
	jmp	done
used:	
	inc	cx
	add	bx, 4
cond:	
	cmp	cx, HandlerCount
	jl	top
	
	ErrorExit	"Error, out of handler slots"
	
done:	
	pop	cx
	pop	bx
	popf
	ret
RegisterAlarm ENDP

CheckAlarms PROC
	
	pushf
	push	bx
	push	cx
	
	cmp	cs:timerTickCount, 0
	je	notick
	mov	cs:timerTickCount, 0

	;; for (cx = 0; cx < HandlerCount; cx += 4)...
	mov	cx, 0
	mov	bx, OFFSET Alarms ;
	jmp	cond
top:
	cmp	WORD PTR [bx], 0 ; See if this alarm is in use
	je	unused
	dec	WORD PTR [bx]	; Yup. Take a tick away
	cmp	WORD PTR [bx], 0 ; Did it go off?
	ja	running
	call	WORD PTR [bx + 2] ; Yup. Call the alarm code
	
running:	
unused:	
	add	bx, 4		; Skip to the next handler
	inc	cx
cond:	
	cmp	cx, HandlerCount
	jl	top
	
notick:	
	pop	cx
	pop	bx
	popf
	ret
CheckAlarms ENDP
