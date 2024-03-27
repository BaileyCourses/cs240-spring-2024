;;; Professor Bailey
;;; Spring 2024

include cs240.inc
include alarms.asm
include eloop.asm
include music.asm
include notes\macros.asm
include notes\io.asm
include notes\video.asm
include notes\game.asm
include notes\inter.asm
include notes\musiclib.asm
	
DOSEXIT = 4C00h
DOS = 21h

.8086

.data
	
.code

MusicLoop PROC
	pushf
	push	ax
	
	jmp	cond
top:	
	call	CheckAlarms
	call	GameUserAction
;	call	UserAction
cond:
	cmp	GameOver, 0
	je	top
	
	pop	ax
	popf
	ret
MusicLoop ENDP


;;; Entry point for the program

main PROC
	mov	ax, @data	; Setup the data segment
	mov	ds, ax

	call	InstallTimerHandler

	;; Point the music generator to the score to play
	
	mov	dx, OFFSET CE3K
	call	PlayScore

	;; Register the music system play note function

 	mov	ax, 3
 	mov	dx, OFFSET PlayNextNote
	call	RegisterAlarm
	call	SpeakerMute

	call	MusicLoop

	call	RestoreTimerHandler

	mov	ax, DOSEXIT	; Signal DOS that we are done
	int	DOS
main ENDP

END main
