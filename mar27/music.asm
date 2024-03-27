TIMER_DATA_PORT		= 42h
TIMER_CONTROL_PORT	= 43h
SPEAKER_PORT		= 61h
READY_TIMER		= 0B6h

.data
CE3K	BYTE	"4D 4E 4C 3C 3G 3Z 3Z", 0

MusicPointer	WORD	0
MusicScore	WORD	0

.code
	
PlayScore PROC
	;; DX = OFFSET of location of score

	mov	MusicScore, dx
	mov	MusicPointer, dx
	ret
PlayScore ENDP

NOTE_TICKS = 8

PlayNextNote PROC
	push	ax
	push	dx
	
	mov	si, MusicPointer
	cmp	BYTE PTR [si], 0
	jne	cont

	;; Repeat tune
	
	mov	si, MusicScore
	mov	MusicPointer, si

cont:	
	call	GetNoteFrequency
	call	PlayFrequency

 	mov	ax, NOTE_TICKS
 	mov	dx, OFFSET StopNote
	call	RegisterAlarm

done:	
	pop	dx
	pop	ax
	ret
PlayNextNote ENDP

NOTE_GAP_TICKS = 1

StopNote PROC
	pushf
	push	ax
	push	dx

	call	SpeakerOff
	
 	mov	ax, NOTE_GAP_TICKS
 	mov	dx, OFFSET PlayNextNote
	call	RegisterAlarm

done:	
	pop	dx
	pop	ax
	popf
	ret
StopNote ENDP

PlayFrequency PROC
	;; Frequency is found in DX

	pushf
	push	ax
	
	cmp	dx, 0
	je	rest

	call	NoteFrequencyToTimerCount

	mov	al, READY_TIMER			; Get the timer ready
	out	TIMER_CONTROL_PORT, al

	mov	al, dl
	out	TIMER_DATA_PORT, al		; Send the count low byte
	
	mov	al, dh
	out	TIMER_DATA_PORT, al		; Send the count high byte
	
	call	SpeakerOn

done:	
	pop	ax
	popf
	ret
rest:
	call	SpeakerOff
	jmp	done
PlayFrequency ENDP

SpeakerOn PROC
	pushf
	push	ax
	
	test	SpeakerMuted, 1
	jnz	done
	
	in	al, SPEAKER_PORT		; Read the speaker register
	or	al, 03h				; Set the two low bits high
	out	SPEAKER_PORT, al		; Write the speaker register

done:	
	pop	ax
	popf
	ret
SpeakerOn ENDP
	
SpeakerOff PROC

	pushf
	push	ax
	
	in	al, SPEAKER_PORT		; Read the speaker register
	and	al, 0FCh			; Clear the two low bits high
	out	SPEAKER_PORT, al		; Write the speaker register

	pop	ax
	popf
	ret
SpeakerOff ENDP
