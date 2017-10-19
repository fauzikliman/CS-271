TITLE Integer Accumulator     (integer-accumulator.asm)

; Author: Fauzi Kliman
; OSU Email: klimanf@oregonstate.edu
; Class number and section: CS271-001
; Assignment Number: 3
; Assignment Due Date: 10/22/17 11:59pm

; Course / Project ID : Integer Accumulator                Date: 10/19/17
; Description: This program will introduce the programmer and program,
;	get the users name, greet the user, loop asking for negative numbers
;	until a positive number is given, calculate the number of valid numbers,
;	sum of negative numbers, and the average of the negative numbers.

INCLUDE Irvine32.inc
; (insert constant definitions here)
	MIN_INPUT_NUM = -100
	MAX_INPUT_NUM = -1
	USERNAME_MAX_LENGTH = 40

.data
; (insert variable definitions here)
	programNameMsg			BYTE	"Welcome to the Integer Accumulator by Fauzi Kliman", 0
	userGreetMsg			BYTE	"Hello, ", 0
	inputInstructionsMsg	BYTE	"Please enter numbers in [-100, -1].", 0
	exitInstructionsMsg		BYTE	"Enter a non-negative number when you are finished to see the results.", 0
	validNumbersBegMsg		BYTE	"You entered ", 0
	validNumbersEndMsg		BYTE	" valid numbers.", 0
	validNumbersSumMsg		BYTE	"The sum of your valid numbers is ", 0
	validNumbersAvgMsg		BYTE	"The rounded average is ", 0
	outroMsg				BYTE	"Thank you for playing Integer Accumulator! It's been a pleasure to meet you, ", 0
	periodMsg				BYTE	".", 0
	
	usernamePrompt			BYTE	"What is your name? ", 0
	numberPrompt			BYTE	"Enter number: ", 0
	
	username				BYTE	USERNAME_MAX_LENGTH DUP(0)
	validNumbersTotal		DWORD	0
	validNumbersSum			DWORD	0
	validNumbersAvg			DWORD	0	; This needs to be a float rounded to 0.001 place

.code

; Displays program info
DisplayProgramInfo PROC
	mov		edx, OFFSET programNameMsg
	call	WriteString
	call	CrLf
	ret
DisplayProgramInfo ENDP

; Gets the username
GetUsername PROC
	mov		edx, OFFSET usernamePrompt
	call	WriteString
	mov		ecx, USERNAME_MAX_LENGTH
	mov		edx, OFFSET username
	call	ReadString
	ret
GetUsername ENDP

; Display username
DisplayUsername PROC
	mov		edx, OFFSET userGreetMsg
	call	WriteString
	mov		edx, OFFSET username
	call	WriteString
	call	CrLf
	call	CrLF
	ret
DisplayUsername ENDP

; Display program instructions
DisplayProgramInstructions PROC
	mov		edx, OFFSET inputInstructionsMsg
	call	WriteString
	call	CrLf
	mov		edx, OFFSET exitInstructionsMsg
	call	WriteString
	call	CrLf
	ret
DisplayProgramInstructions ENDP

; Get user data
GetUserData PROC
	getNumber:
		mov		edx, OFFSET numberPrompt
		call	WriteString
		call	ReadInt
		jns		endGetNumber
		mov		ebx, validNumbersTotal
		add		ebx, eax
		mov		validNumbersTotal, ebx
		jmp		getNumber
	endGetNumber:
		mov		eax, validNumbersTotal
		call	WriteInt
		call	CrLf
		ret
GetUserData ENDP

main PROC
; (insert executable instructions here)
	; Display program info
	call	DisplayProgramInfo

	; Get username
	call	GetUsername

	; Display username
	call	DisplayUsername

	; Display program instructions
	call	DisplayProgramInstructions

	; Get user data
	call	GetUserData

	; Process user data

	; Display user data results

	; Display outro

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
