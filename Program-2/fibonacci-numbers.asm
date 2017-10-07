TITLE Fibonacci Numbers     (fibonacci-numbers.asm)

; Author: Fauzi Kliman
; OSU Email: klimanf@oregonstate.edu
; Class number and section: CS271-001
; Assignment Number: 2
; Assignment Due Date: 10/08/17 11:59pm

; Course / Project ID : Fibonacci Numbers                 Date: 10/3/17
; Description: This program will introduce the programmer and program, 
;	get the users name greet the user, ask for a number between 
;	1 and 46 and calculate the fibonacci number to the amount of terms 
;	specified by the user

INCLUDE Irvine32.inc

MIN_FIB_TERMS			= 1
MAX_FIB_TERMS			= 46
TERMS_PER_LINE			= 5
COLUMN_WIDTH			= 15 ; Amount of characters a term should take up in console
USERS_NAME_MAX_LENGTH	= 40

.data
	programNameMsg			BYTE	"Fibonacci Numbers", 0
	programmedByMsg			BYTE	"Programmed by Fauzi Kliman", 0
	outroMsg				BYTE	"Results certified by Fauzi Kliman", 0
	goodByeMsg				BYTE	"Goodbye, ", 0
	usersNamePrompt			BYTE	"What's your name? ", 0
	usersGreetingMsg		BYTE	"Hello, ", 0
	usersName				BYTE	USERS_NAME_MAX_LENGTH DUP(0)
	fibTermsMsg				BYTE	"Enter the number of Fibonacci terms to be displayed", 0
	fibTermsLimitMsg		BYTE	"Give the number as an integer in the range [1 .. 46].", 0
	fibTermsErrorMsg		BYTE	"Out of range.  Enter a number in [1 .. 46]", 0
	fibTermsAmountPrompt	BYTE	"How many Fibonacci terms do you want? ", 0
	spaceChar				BYTE	" ", 0
	; termA is initialized to 0 and termB is initialized to 1 because termB 
	; will get the value of termA and termA will get the sum of termA + termB,
	; thus handling the case where the amount of fibonacci numbers wanted 
	; is 1 or 2 because fibonacci number 1 and 2 are both 1
	termA					DWORD	0
	termB					DWORD	1
	termCount				DWORD	0
	termLength				DWORD	0
	loopCounter				DWORD	0

	; Variables for extra credit
	ecAlignedColumnsMsg		BYTE	"**EC: Prints the fibonacci numbers in aligned colums", 0

.code
main PROC

; Introduction
	mov		edx, OFFSET programNameMsg
	call	WriteString
	call	CrLf
	mov		edx, OFFSET	programmedByMsg
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ecAlignedColumnsMsg
	call	WriteString
	call	CrLf

; Get user name
	call	CrLf
	mov		edx, OFFSET usersNamePrompt
	call	WriteString
	mov		edx, OFFSET	usersName
	mov		ecx, SIZEOF usersName
	call	ReadString

; Display users name
	mov		edx, OFFSET usersGreetingMsg
	call	WriteString
	mov		edx, OFFSET usersName
	call	WriteString
	call	CrLf

; User instructions
	mov		edx, OFFSET fibTermsMsg
	call	WriteString
	call	CrLf
	mov		edx, OFFSET	fibTermsLimitMsg
	call	WriteString
	call	CrLf
	call	CrLf

; Get user data
promptTermsLimit:
	mov		edx, OFFSET fibTermsAmountPrompt
	call	WriteString
	call	ReadInt
	; Valid user input for amount of fib terms is within bounds
	cmp		eax, MIN_FIB_TERMS
	jl		invalidTermsAmount
	cmp		eax, MAX_FIB_TERMS
	jg		invalidTermsAmount
	jmp		validTermsAmount
invalidTermsAmount:
	mov		edx, OFFSET fibTermsErrorMsg
	call	WriteString
	call	CrLf
	jmp		promptTermsLimit

; Display fibonacci numbers
validTermsAmount:
	call	CrLf
	; Set the loop counter the amount terms the user wants
	mov		ecx, eax
begFibLoop:
	mov		eax, termA
	add		eax, termB
	call	WriteDec

	; Set termB to termA, set termA to the term sum
	mov		ebx, termA
	mov		termB, ebx
	mov		termA, eax

	; Find out how many digits are in the sum
	; The amount of digits in a number is the amount of times you can
	; recursively divide that number by 10 till a quotient of 0 is reached
	; For example
	; 123 / 10 = 12.3
	; 12.3 / 10 = 1.23
	; 1.23 / 10 = 0, took 3 times to get quotient of 0, thus has 3 digits
	mov		loopCounter, ecx
	mov		ebx, 10
	mov		ecx, 0
begDigitLoop:
	cdq		
	div		ebx
	inc		ecx
	cmp		eax, 0
	jne		begDigitLoop
endDigitLoop:
	mov		termLength, ecx
	mov		ecx, loopCounter

	; Print out empty spaces until the amount of digits in the term sum and 
	; empty spaces are COLUMN_WIDTH in length
	mov		eax, COLUMN_WIDTH
	sub		eax, termLength
begSpaceLoop:
	cmp		eax, 0
	jle		endSpaceLoop
	dec		eax
	mov		edx, OFFSET spaceChar
	call	WriteString
	jmp		begSpaceLoop
endSpaceLoop:

	; Print a new line after TERMS_PER_LINE terms have been printed
	mov		ebx, termCount
	inc		ebx
	cmp		ebx, TERMS_PER_LINE
	jl		endFibLoop
	call	CrLf
	mov		ebx, 0
endFibLoop:
	mov		termCount, ebx
	loop	fibTmpLoop

	; Print newline if a full line of terms was not printed when
	; reaching the number of fib numbers the user wanted. This can be 
	; determined by checking the value of ebx (value of termCount), 0
	; means a full line of terms was printed with a newline
	cmp		ebx, 0
	je		goodBye
	call	CrLf

; Farewell
goodBye:
	call	CrLf
	mov		edx, OFFSET outroMsg
	call	WriteString
	call	CrLf
	mov		edx, OFFSET goodByeMsg
	call	WriteString
	mov		edx, OFFSET usersName
	call	WriteString
	call	CrLf

	exit	; exit to operating system

; Temporary loop jmp since loop can only jump 127 bytes ahead
; or 128 bytes behind
fibTmpLoop:
	jmp		begFibLoop

main ENDP

END main
