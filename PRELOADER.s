	DSK ALOADER.SYSTEM#FF2000

**************************************************
* Boot into stub at $2000 to BLOAD another loader
* at $300, and ProRWTS, then JMP $300
*
* That loader packs as much of the 64K with data 
* as I was able to manage. 
**************************************************
* Variables
**************************************************

BELL   		EQU	$FF3A     				; Monitor BELL routine
CROUT  		EQU	$FD8E     				; Monitor CROUT routine
PRBYTE 		EQU	$FDDA     				; Monitor PRBYTE routine
MLI    		EQU	$BF00     				; ProDOS system call
OPENCMD		EQU	$C8						; OPEN command index
READCMD		EQU	$CA						; READ command index
CLOSECMD	EQU	$CC						; CLOSE command index


**************************************************
* START 
**************************************************

				ORG $2000						; PROGRAM DATA STARTS AT $2000

				JSR BLOAD
       			
       			JMP $300					;Otherwise done. Stage 2 commences...

						
**************************************************
*	Loads PRORWTS at $800
*	PRORWTS loads "LOADER" into memory at $0300
*	Frees up $2000 for data.
*	MLI buffers to B000

* 	Then JMP LOADER, which reads SSLM, words, etc 
**************************************************

BLOAD   		JSR	OPEN    				; MLI calls to load PRORWTS
       			JSR READ
       			JSR ERROR					
				JSR CLOSE
       			JSR ERROR					

; proRWTS in $800. Init moves its magic to replace MLI
				JSR $800
       			
				

				LDA #$03					; loader to $0300
				STA WRITETO+1
				LDA #>FILENAME2
				STA OPENLIST+2
				LDA #<FILENAME2
				STA OPENLIST+1
				JSR	OPEN    				;open "LOADER.BIN"

       			JSR READ
       			JSR ERROR					
				JSR CLOSE
       			JSR ERROR					
				
				RTS

      			
				
OPEN 			JSR	MLI       				;Perform call
       			DB	OPENCMD    				;CREATE command number
       			DW	OPENLIST   				;Pointer to parameter list
       			JSR	ERROR     				;If error, display it
       			LDA REFERENCE
       			STA READLIST+1
       			STA CLOSELIST+1
       			RTS				

READ			JSR MLI
				DB	READCMD
				DW	READLIST
				RTS

CLOSE			JSR MLI
				DB	CLOSECMD
				DW	CLOSELIST
				RTS
				
ERROR  			JSR	PRBYTE    				;Print error code
       			JSR	BELL      				;Ring the bell
       			JSR	CROUT     				;Print a carriage return
       			RTS				

OPENLIST		DB	$03						; parameter list for OPEN command
				DW	FILENAME1
				DA	$B000					; buffer
REFERENCE		DB	$00						; reference to opened file
			
READLIST		DB	$04
				DB	$00						; REFERENCE written here after OPEN
WRITETO			DB	$00,$08					; write to $0800
				DB	$FF,$FF					; read as much as $FFFF - should error out with EOF before that.
TRANSFERRED		DB	$00,$00				

CLOSELIST		DB	$01
				DB	$00
		
		
				
FILENAME1		DB	ENDNAME1-NAME1 				;Length of name
NAME1    		ASC	'PRORWTS2.BIN'				;followed by the name
ENDNAME1 		EQU	*


FILENAME2		DB	ENDMAIN-MAINNAME 			;Length of name
MAINNAME		ASC	'LOADER.BIN'				;followed by the name
ENDMAIN 		EQU	*
