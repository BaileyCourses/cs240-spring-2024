;;; Professor Bailey
;;; Spring 2024

include cs240.inc
include notes\macros.asm
include notes\inter.asm
	
DOSEXIT = 4C00h
DOS = 21h

.8086

.data
	
.code

;; NOTE: in code segment

OriginalTimerHandler DWORD	0AAAA5555h

crumb	BYTE	0

NewTimerHandler PROC
	inc	cs:crumb
	iret
;	jmp	cs:OriginalTimerHandler
NewTimerHandler ENDP

Delay PROC
	push	bx
	push	cx

	mov	cx, 15
toptop:	
	push	cx

	mov	cx, 0
top:	
	inc	bx
	loop	top

	pop	cx
	loop	toptop

	pop	cx
	pop	bx
	ret
Delay ENDP

BIOSWriteString PROC
	;; Writes a string at CS:BX using BIOS
	
	ret
BIOSWriteString ENDP

INTERRUPT_NUM = 1Ch		; Timer interrupt number

;;; Entry point for the program

main PROC
	mov	ax, @data	; Setup the data segment
	mov	ds, ax

	bWrite	"Hi"

	;; Start of DOS program...

	mWriteLn	"Starting configuration"

	mov	al, INTERRUPT_NUM
	call	WriteInstalledVector ; AL = interrupt number
	call	NewLine

	mov	bx, OFFSET OriginalTimerHandler
	call	WriteInterruptVector ; CS:BX = vector to display
	call	NewLine

	mWriteLn	"Saving interrupt vector"

	mov	al, INTERRUPT_NUM
	mov	bx, OFFSET OriginalTimerHandler
	call	SaveInterruptVector ; AL = interrupt number, CS:BX = location

	mov	bx, OFFSET OriginalTimerHandler
	call	WriteInterruptVector ; CS:BX = vector to display
	call	NewLine

	mWriteLn	"Setting interrupt vector"

	mov	al, INTERRUPT_NUM
	mov	dx, OFFSET NewTimerHandler
	call	SetInterruptVector ; AL = interrupt vector, CS:DX = offset of code

	mov	al, INTERRUPT_NUM
	call	WriteInstalledVector ; AL = interrupt number
	call	NewLine

	call	Delay

	mWriteLn	"Restoring interrupt vector"

	mov	al, INTERRUPT_NUM
	mov	bx, OFFSET OriginalTimerHandler
;	call	RestoreInterruptVector ; AL = interrupt number, CS:BX = location

	mov	al, INTERRUPT_NUM
	call	WriteInstalledVector ; AL = interrupt number
	call	NewLine

	mov	dh, 0
	mov	dl, cs:crumb
	call	WriteHexWord
	call	NewLine

	mov	ax, DOSEXIT	; Signal DOS that we are done
	int	DOS
main ENDP
END main







	mWriteLn	"Starting configuration"

	mov	al, INTERRUPT_NUM
	call	WriteInstalledVector ; AL = interrupt number
	call	NewLine

	mov	bx, OFFSET OriginalTimerHandler
	call	WriteInterruptVector ; CS:BX = vector to display
	call	NewLine

	mWriteLn	"Saving interrupt vector"

	mov	al, INTERRUPT_NUM
	mov	bx, OFFSET OriginalTimerHandler
	call	SaveInterruptVector ; AL = interrupt number, CS:BX = location

	mov	bx, OFFSET OriginalTimerHandler
	call	WriteInterruptVector ; CS:BX = vector to display
	call	NewLine

	mWriteLn	"Setting interrupt vector"

	mov	al, INTERRUPT_NUM
	mov	dx, OFFSET NewTimerHandler
	call	SetInterruptVector ; AL = interrupt vector, CS:DX = offset of code

	mov	al, INTERRUPT_NUM
	call	WriteInstalledVector ; AL = interrupt number
	call	NewLine

	call	Delay

	mWriteLn	"Restoring interrupt vector"

	mov	al, INTERRUPT_NUM
	mov	bx, OFFSET OriginalTimerHandler
	call	RestoreInterruptVector ; AL = interrupt number, CS:BX = location

	mov	al, INTERRUPT_NUM
	call	WriteInstalledVector ; AL = interrupt number
	call	NewLine

	mov	dh, 0
	mov	dl, cs:crumb
	call	WriteHexWord
	call	NewLine
