.data
	
GameOver	BYTE	0

.code

UserAction PROC
	pushf
	push	ax
	
	call	KeyPress	; Character in AL (or 0 for no character)
	cmp	al, 0		; Was a key pressed?
	je	ignore		; No, return
	
	cmp	al, 27		; Is it the ESC key?
	je	endGame
	
	jmp	ignore
	
endGame:	
	mov	GameOver, 1
	
ignore:	
done:	
	pop	ax
	popf
	ret
UserAction ENDP

GameLoop PROC
	pushf
	push	ax
	push	dx
	
;	mov	ax, 18*3
;	mov	dx, ClearStatus
;	call	RegisterAlarm

 	mov	ax, CharacterSpeed
 	mov	dx, OFFSET MoveCharacter
 	call	RegisterAlarm


	jmp	cond
top:	
	call	CheckAlarms
;	call	GameUserAction
	call	UserAction
cond:
	cmp	GameOver, 0
	je	top
	
	pop	dx
	pop	ax
	popf
	ret
GameLoop ENDP
	
