;;; Professor Bailey
;;; Spring 2024

include cs240.inc
include alarms.asm
include eloop.asm
include notes\macros.asm
include notes\io.asm
include notes\video.asm
include notes\game.asm
include notes\inter.asm
	
DOSEXIT = 4C00h
DOS = 21h

.8086

.data
	
.code

;;; Entry point for the program

gamemain PROC
	mov	ax, @data	; Setup the data segment
	mov	ds, ax

	;; Start of DOS program...

	;; Game Setup
	call	CursorOff	; int 10h; AH=01
	call	InstallTimerHandler

	call	SplashScreen

	;; Start the game

	call	GameScreen	

;	Status	"Game is starting!"

	call	GameLoop

	;; Wait for a key press
	
;	call	ReadCharNoEcho

	;; Game clean up
	call	RestoreTimerHandler
	call	CursorOn


	mov	ax, DOSEXIT	; Signal DOS that we are done
	int	DOS
gamemain ENDP

tick10 PROC
	push	ax
	push	dx
	mWrite	"Tick 10 called!"

	mov	ax, 15
	mov	dx, OFFSET tick15
	call	RegisterAlarm

	pop	dx
	pop	ax
	ret
tick10 ENDP

tick15 PROC
	mWrite	"Tick 15 called!"

	mov	ax, 10
	mov	dx, OFFSET tick10
	call	RegisterAlarm

	ret
tick15 ENDP

gloop PROC

top:
	call	CheckAlarms
	jmp	top
	
gloop ENDP

main PROC
	mov	ax, @data	; Setup the data segment
	mov	ds, ax

	call	InstallTimerHandler

	mov	ax, 10
	mov	dx, OFFSET tick10
	call	RegisterAlarm

	call	gloop

;	call	ReadCharNoEcho

	call	RestoreTimerHandler

	mov	ax, DOSEXIT	; Signal DOS that we are done
	int	DOS
main ENDP

END main
