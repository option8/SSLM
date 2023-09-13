	DSK LOADER.BIN#060300

**************************************************
* PRELOADER at $2000 loads this and RWTS, jumps 
* here. This loads the main SSLM and all the data
* into various memory nooks and crannies. Then
* JMP to $800, where SSLM lies in wait.
**************************************************
* Variables
**************************************************

;from ProRWTS2
;subdirectory support
bloklo			EQU		$46
blokhi			EQU		$47

;to detect file not found
status			EQU		$50

;file read support
sizelo			EQU		$52
sizehi			EQU		$53
ldrlo			EQU		$55
ldrhi			EQU		$56

;file open support
namlo			EQU		$57
namhi			EQU		$58

;rewind support
blkidx			EQU		$5e
bleftlo			EQU		$60
blefthi			EQU		$61

;API
hddopendir		EQU		$BD03
hddrdwrpart		EQU		$BD00
hddblockhi		EQU		$BD06
hddblocklo		EQU		$BD04


TOKENHI			EQU $EF
TOKENLO			EQU $EE

WORDHI			EQU $FE
WORDLO			EQU $FD

SCRATCHHI		EQU $07
SCRATCHLO		EQU $06

INDEXHI			EQU $1E
INDEXLO			EQU $1D

SEARCHMODE		EQU $CF			; last level of successful match. 
								; 00 looking for a pair, 
								; 01 found pair, looking for triple. 
								; 80 found triple.
SKIPMATCH		EQU $CE
DIDSKIP			EQU	$FE			; did the last search skip over a match?

TOKENMAX		EQU $ED			; words 	$A00 - $2100
								; pairs		$2100- $7E00
								; triples	$7E00- $BE00 
TEXTCOL			EQU $24
TEXTROW			EQU $25
WORDCOUNT		EQU $E3			; running EOR?
JITTER			EQU $EC

SCREENCOUNT		EQU $D7

COUT      		EQU	$FDF0       ; CALLS THE OUTPUT ROUTINE
NEWLINE			EQU $FD8E		; OUTPUTS NEW LINE/ CARRIAGE RETURN
PRHEX			EQU $FDDA		; PRINTS BYTE IN ACCUMULATOR AS HEX
CLRSCR			EQU $FC58
KEY				EQU	$C000


; uncompressed word indexes				
WORD0 			EQU $0300
WORD1 			EQU $0302
WORD2 			EQU $0304
PAIR0			EQU $0306		; three bytes

WORDSTART		EQU #$0A
PAIRSTART		EQU #$1D	
PAIRSEND		EQU #$81

TRIPLESTART		EQU #$D0
TRIPLESEND		EQU #$00

QUADSEND		EQU #$AB		
QUADSTART		EQU #$81
	

STROUT  		EQU $DB3D         ;Print String at [(A,Y)={Low,High}]

**************************************************
* START 
**************************************************

						ORG $0300						; PROGRAM DATA STARTS AT $300

**************************************************
*	Load "SSLM" into memory at $0800
**************************************************

						LDA #>MAIN
						STA namhi
						LDA #<MAIN
						STA namlo
		
						LDA #$02						; file size $200
						STA sizehi
						LDA #$00
						STA sizelo					
		
						JSR hddopendir					; open "SSLM"
		
		
						LDA #>WORDS
						STA namhi
						LDA #<WORDS
						STA namlo
						LDA #$12
						STA sizehi						
						LDA #$67
						STA sizelo						
						JSR hddopendir					; open WORDS
		
						LDA #>PAIRS
						STA namhi
						LDA #<PAIRS
						STA namlo
						LDA #$64
						STA sizehi						
						LDA #$00
						STA sizelo						
						JSR hddopendir					; open "pairs"
		
		
						LDA #>QUADS
						STA namhi
						LDA #<QUADS
						STA namlo
						LDA #$2A
						STA sizehi						
						LDA #$40
						STA sizelo						
						JSR hddopendir					; open "quads"
		
						LDA $C089						; ROM read, alt RAM write only
						LDA $C089						; writes to $D000 bank 1
		
						LDA #>TRIPLES
						STA namhi
						LDA #<TRIPLES
						STA namlo
						LDA #$2f
						STA sizehi						
						LDA #$ff
						STA sizelo						
						JSR hddopendir					; open "triples"
		
						JSR CLRSCR						; clear the screen
		
;;; Ask user to type the title of a poem?
;;; get checksum of characters typed, AND with 03ff -> "prompt" word.
;;; timer generates "random" seed for SKIPMATCH

						LDA #>INSTRUCTIONS
						LDY #<INSTRUCTIONS
		
						
						STA $5F
						STY $5E
						LDA INSTREND-INSTRUCTIONS
		
						JSR $DB40
						JSR NEWLINE


KEYLOOP					DEC WORDLO						; entropy. we needs it.
						INC JITTER
						LDA WORDCOUNT
						ADC WORDLO
						STA WORDCOUNT
			;			LDA WORDLO
						EOR WORDHI
						AND #$03
						STA WORDHI

						LDA KEY
						BPL KEYLOOP						; otherwise

						CMP #$8D						; enter
						BNE TYPEWRITER
						JSR CLRSCR						; clear the screen
						JMP $800
						
TYPEWRITER				
						JSR COUT
						STA $C010
						BCC KEYLOOP

INSTRUCTIONS			ASC "Press enter to begin. "
INSTREND						DB 00




										; and we're off...

		
MAIN					DB	ENDMAIN-MAINNAME 			;Length of name
MAINNAME				ASC	'SSLM' 						;followed by the name
ENDMAIN 				EQU	*
		
WORDS					DB	ENDWORDS-WORDSNAME 			;Length of name
WORDSNAME				ASC	'WORDS' 					;followed by the name
ENDWORDS				EQU	*
		
PAIRS					DB	ENDPAIRS-PAIRSNAME 			;Length of name
PAIRSNAME				ASC	'PAIRS' 					;followed by the name
ENDPAIRS				EQU	*
		
TRIPLES					DB	ENDTRIPLES-TRIPLESNAME 		;Length of name
TRIPLESNAME				ASC	'TRIPLES' 					;followed by the name
ENDTRIPLES				EQU	*
		
QUADS					DB	ENDQUADS-QUADSNAME 			;Length of name
QUADSNAME				ASC	'QUADS' 					;followed by the name
ENDQUADS				EQU	*
		