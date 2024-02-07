;;; Professor Bailey
;;; Spring 2024

include cs240.inc
	
DOSEXIT = 4C00h
DOS = 21h

.8086

.data
	
.code

                                                 
	;;        (0-99)           1-12         1-31
	;;  Year: 7 bits, Month: 4 bits, Day: 5 bits

;;; Entry point for the program

setMonth PROC
	;; AX = new month value
	;; DX = packed value
	and	dx, 0FE1Fh	; Clear the month field in DX

	and	ax, 0Fh		; Clears the high bits of ax, leaving just month
	mov	cl, 5		; Shifts new month value to correct position
	shl	ax, cl
	or	dx, ax		; Inserts new month value into DX packed value
	
	ret
setMonth ENDP

getMonth PROC
	;; DX = packed value
	;; AX returns month value

	pushf
	push	cx
	
	mov	ax, dx
	mov	cl, 5		; shift day bits out of register
	shr	ax, cl
	and	ax, 0Fh		; Clear year bits out of register

	pop	cx
	popf
	ret
getMonth ENDP


main PROC
	mov	ax, @data	; Setup the data segment
	mov	ds, ax

	;; Start of DOS program...

	mov	dx, 23 * 512 + 12 * 32 + 7
	
	mov	al, 4
	call	setMonth

	call	getMonth

	mov	dx, ax
	call	WriteInt
	call	NewLine
	mov	ax, DOSEXIT	; Signal DOS that we are done
	int	DOS
main ENDP
END main
