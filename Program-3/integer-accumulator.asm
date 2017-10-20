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
	noValidNumbersMsg		BYTE	"No valid numbers were entered!", 0
	outroMsg				BYTE	"Thank you for playing Integer Accumulator! It's been a pleasure to meet you, ", 0
	periodMsg				BYTE	".", 0
	inputNumberErrorMsg		BYTE	"Number must be in [-100, -1].", 0
	
	usernamePrompt			BYTE	". What is your name? ", 0
	numberPrompt			BYTE	". Enter number: ", 0
	
	username				BYTE	USERNAME_MAX_LENGTH DUP(0)
	validNumbersCount		DWORD	0
	validNumbersSum			SDWORD	0
	validNumbersAvg			REAL4	?

	; Extra credit related
	ecInputCountingMsg		BYTE	"EC: Numbers the lines during user input.", 0
	ecRoundingMsg			BYTE	"EC: Displays the average as a floating-point number rounded to the nearest .001.", 0
	avgRoundingPoint		DWORD	1000 ; Rounding the average to the thousandths place
	userInputCount			DWORD	0
.code

; Displays program info
DisplayProgramInfo PROC
	mov		edx, OFFSET programNameMsg
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ecInputCountingMsg
	call	WriteString
	call	CrLf
	mov		edx, OFFSET	ecRoundingMsg
	call	WriteString
	call	CrLf
	ret
DisplayProgramInfo ENDP

; Gets the username
GetUsername PROC
	mov		eax, userInputCount
	inc		eax
	mov		userInputCount, eax
	call	WriteDec
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
	mov		ecx, userInputCount	; Number of times asked for number input
getNumber:
	; Inc and display the user input count
	inc		ecx
	mov		eax, ecx
	call	WriteDec
	; Prompt for valid number
	mov		edx, OFFSET numberPrompt
	call	WriteString
	call	ReadInt
	; End loop if number is NOT negative
	jns		endGetNumber
	; Validate number is within bounds
	cmp		eax, MIN_INPUT_NUM
	jl		invalidNum
	; Add valid number to sum
	mov		ebx, validNumbersSum
	add		ebx, eax
	mov		validNumbersSum, ebx
	; Inc valid numbers count
	mov		ebx, validNumbersCount
	inc		ebx
	mov		validNumbersCount, ebx
	jmp		getNumber
invalidNum:
	mov		edx, OFFSET inputNumberErrorMsg
	call	WriteString
	call	CrLf
	jmp		getNumber
endGetNumber:
	mov		userInputCount, ecx
	ret
GetUserData ENDP

; Calculate avg
ProcessData PROC
	finit
	fild	validNumbersSum
	fidiv	validNumbersCount
	fimul	avgRoundingPoint
	frndint
	fidiv	avgRoundingPoint
	fst		validNumbersAvg
	ret
ProcessData ENDP

; Display the results
DisplayResults PROC
	; Number of valid numbers
	mov		edx, OFFSET validNumbersBegMsg
	call	WriteString
	mov		eax, validNumbersCount
	call	WriteDec
	mov		edx, OFFSET validNUmbersEndMsg
	call	WriteString
	call	CrLf
	; Sum of valid numbers
	mov		edx, OFFSET validNumbersSumMsg
	call	WriteString
	mov		eax, validNumbersSum
	call	WriteInt
	call	CrLf
	; Average of valid numbers
	mov		edx, OFFSET validNumbersAvgMsg
	call	WriteString
	fld		validNumbersAvg
	call	WriteFloat
	call	CrLf
	ret
DisplayResults ENDP

; Display outro msg
DisplayOutro PROC
	mov		edx, OFFSET outroMsg
	call	WriteString
	mov		edx, OFFSET username
	call	WriteString
	mov		edx, OFFSET periodMsg
	call	WriteString
	call	CrLf
	ret
DisplayOutro ENDP

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

	; Display special msg and go to outro if no valid numbers were entered
	mov		eax, validNumbersCount
	cmp		eax, 0
	jne		validNumbersEntered
	mov		edx, OFFSET noValidNumbersMsg
	call	WriteString
	call	CrLf
	jmp		DisplayOutroL

validNumbersEntered:
	; Process user data
	call	ProcessData

	; Display user data results
	call	DisplayResults

DisplayOutroL:
	; Display outro
	call	DisplayOutro

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
