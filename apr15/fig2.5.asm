.this has no space
COPY:   START   0                       COPY FILE FROM INPUT TO OUTPUT
FIRST:  STL     RETADR                  SAVE RETURN ADDRESS
        LDB     #LENGTH                 ESTABLISH BASE REGISTER
        BASE    LENGTH                  
CLOOP:  JSUB    RDREC                   READ INPUT RECORD
        LDA     LENGTH                  TEST FOR EOF (LENGTH = 0)
        COMP    #0                      
        JEQ     ENDFIL                  EXIT IF EOF FOUND
        +JSUB   WRREC                   WRITE OUTPUT RECORD
        J       CLOOP                   LOOP
ENDFIL: LDA     EOF                     INSERT END OF FILE MARKER
        STA     BUFFER                  
        LDA     #3                      SET LENGTH = 3
        STA     LENGTH                  
        +JSUB   WRREC                   WRITE EOF
        J       @RETADR                 RETURN TO CALLER
EOF:    BYTE    C'EOF'                  
RETADR: RESW    1                       
LENGTH: RESW    1                       LENGTH OF RECORD
BUFFER: RESB    4096                    4096-BYTE BUFFER AREA
        .                               
        .       SUBROUTINE TO READ RECORD INTO BUFFER
        .                               
RDREC:  CLEAR   X                       CLEAR LOOP COUNTER
        CLEAR   A                       CLEAR A TO ZERO
        CLEAR   S                       CLEAR S TO ZERO
        +LDT    #4096                   
RLOOP:  TD      INPUT                   TEST INPUT DEVICE
        JEQ     RLOOP                   LOOP UNTIL READY
        RD      INPUT                   REACH CHARACTER INTO REGISTER A
        COMPR   A,X                     TEST FOR END OF RECORD (X'00')
        JEQ     EXIT                    EXIT LOOP IF EOR
        STCH    BUFFER,X                STORE CHARACTER IN BUFFER
        TIXR    T                       LOOP UNLESS MAX LENGTH
        JLT     RLOOP                     HAS BEEN REACHED
EXIT:   STX     LENGTH                  SAVE RECORD LENGTH
        RSUB                            RETURN TO CALLER
INPUT:  BYTE    X'F1'                   CODE FOR INPUT DEVICE
        .                               
        .       SUBROUTINE TO WRITE RECORD FROM BUFFER
        .                               
WRREC:  CLEAR   X                       CLEAR LOOP COUNTER
        LDT     LENGTH                  
WLOOP:  TD      OUTPUT                  TEST OUTPUT DEVICE
        JEQ     WLOOP                   LOOP UNTIL READY
        LDCH    BUFFER, X               GET CHARACTER FROM BUFFER
        WD      OUTPUT                  WRITE CHARACTER
        TIXR    T                       LOOP UNTIL ALL CHARACTERS
        JLT     WLOOP                     HAVE BEEN WRITTEN
        RSUB                            RETURN TO CALLER
 OUTPUT: BYTE    X'05'                   CODE FOR OUTPUT DEVICE
        END     FIRST                   
