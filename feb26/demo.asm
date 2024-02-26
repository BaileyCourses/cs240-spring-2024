;;; Professor Bailey
;;; Spring 2024

include cs240.inc
	
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

	mov	ax, DOSEXIT	; Signal DOS that we are done
	int	DOS
main ENDP
END main
