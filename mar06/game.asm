;;; Professor Bailey
;;; Spring 2024

include cs240.inc
include alarms.asm
include eloop.asm
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

main PROC
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
	
	call	ReadCharNoEcho

	;; Game clean up
	call	RestoreTimerHandler
	call	CursorOn


	mov	ax, DOSEXIT	; Signal DOS that we are done
	int	DOS
main ENDP
END main
