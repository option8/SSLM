	DSK LOADER.BIN#060300

**************************************************
* PRELOADER at $2000 loads this and RWTS, jumps 
* here. This loads the main SSLM and all the data
* into various memory nooks and crannies. Then
* JMP to $800, where SSLM lies in wait.
**************************************************
* Variables
**************************************************
CLRSCR			EQU $FC58

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
				LDA #$63
				STA sizehi						
				LDA #$FF
				STA sizelo						
				JSR hddopendir					; open "pairs"


				LDA #>QUADS
				STA namhi
				LDA #<QUADS
				STA namlo
				LDA #$2A
				STA sizehi						
				LDA #$36
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
				JMP $800						; and we're off...


MAIN			DB	ENDMAIN-MAINNAME 			;Length of name
MAINNAME		ASC	'SSLM' 						;followed by the name
ENDMAIN 		EQU	*

WORDS			DB	ENDWORDS-WORDSNAME 			;Length of name
WORDSNAME		ASC	'WORDS' 					;followed by the name
ENDWORDS		EQU	*

PAIRS			DB	ENDPAIRS-PAIRSNAME 			;Length of name
PAIRSNAME		ASC	'PAIRS' 					;followed by the name
ENDPAIRS		EQU	*

TRIPLES			DB	ENDTRIPLES-TRIPLESNAME 		;Length of name
TRIPLESNAME		ASC	'TRIPLES' 					;followed by the name
ENDTRIPLES		EQU	*

QUADS			DB	ENDQUADS-QUADSNAME 			;Length of name
QUADSNAME		ASC	'QUADS' 					;followed by the name
ENDQUADS		EQU	*