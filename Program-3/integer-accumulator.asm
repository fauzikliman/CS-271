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

	; Extra credit related
	ecInputCountingMsg		BYTE	"EC: Numbers the lines during user input.", 0
	ecRoundingMsg			BYTE	"EC: Displays the average as a floating-point number rounded to the nearest .001.", 0
	zeroMsg					BYTE	"0", 0
	avgRoundingPoint		DWORD	1000 ; Rounding the average to the thousandths place
	avgIntegerPart			SDWORD	0
	avgFractionalPart		DWORD	0
	userInputCount			DWORD	0
.code

; Displays program info
DisplayProgramInfo PROC
	; Program name msg
	mov		edx, OFFSET programNameMsg
	call	WriteString
	call	CrLf
	; Counting user input lines extra credit msg
	mov		edx, OFFSET ecInputCountingMsg
	call	WriteString
	call	CrLf
	; Rounding the avg extra credit msg
	mov		edx, OFFSET	ecRoundingMsg
	call	WriteString
	call	CrLf
	ret
DisplayProgramInfo ENDP

; Gets the username
GetUsername PROC
	; Display how many times we've asked for input and inc it
	mov		eax, userInputCount
	inc		eax
	mov		userInputCount, eax
	call	WriteDec
	; Ask for users name
	mov		edx, OFFSET usernamePrompt
	call	WriteString
	mov		ecx, USERNAME_MAX_LENGTH
	mov		edx, OFFSET username
	call	ReadString
	ret
GetUsername ENDP

; Display username
DisplayUsername PROC
	; Display the greet msg with the users name we got from before
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
	; Display instructions for using the program
	mov		edx, OFFSET inputInstructionsMsg
	call	WriteString
	call	CrLf
	; Display instructions on how to quit the program
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
	; Invalid number if overflow occurs
	jo		invalidNum
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
	; Keep asking for user input
	jmp		getNumber
invalidNum:
	; Display error msg if input is negative but out of bounds
	mov		edx, OFFSET inputNumberErrorMsg
	call	WriteString
	call	CrLf
	; Ask for user input again
	jmp		getNumber
endGetNumber:
	; Save the amount times we asked for input to variable
	mov		userInputCount, ecx
	ret
GetUserData ENDP

; Calculate avg
ProcessData PROC
	; Use the FPU to calculate the avg of the sum
	finit
	fild	validNumbersSum
	fidiv	validNumbersCount
	; Multiply the avg by the accurace of the rounding
	; and use the FPU to round it 
	fimul	avgRoundingPoint
	frndint
	; Truncate the result to only keep the precision we wanted and 
	; move it into a variable
	fisttp	avgIntegerPart
	; Split the avg into integer/fractional parts 
	; by dividing the avg in the FPU by the wanted rounding
	; and store the quotient into the integer part and remainder
	; into the fractional part
	mov		eax, avgIntegerPart
	cdq
	mov		ecx, avgRoundingPoint
	idiv	ecx
	mov		avgIntegerPart, eax
	neg		edx
	mov		avgFractionalPart, edx
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
	; Display the integer part of the avg
	mov		eax, avgIntegerPart
	call	WriteInt
	; Display the decimal point
	mov		edx, OFFSET periodMsg
	call	WriteString
	; Display the fractional part by first displaying
	; 0's depending on the fractional part values, ex
	; 1, 10, 100
	; Divide the wanted precision for the rounding by 10,
	; subtract 1 from it, if the fractional part is
	; bigger than that then we can display the fractional
	; part, otherwise display an 0 and repeat the process
	mov		eax, avgRoundingPoint
	mov		ebx, 10
begDisplayZero:
	cdq
	div		ebx
	dec		eax
	cmp		avgFractionalPart, eax
	jg		endDisplayZero
	mov		edx, OFFSET zeroMsg
	call	WriteString
	jmp		begDisplayZero
endDisplayZero:
	mov		eax, avgFractionalPart
	call	WriteDec
	call	CrLf
	ret
DisplayResults ENDP

; Display outro msg
DisplayOutro PROC
	; Display outro msg
	mov		edx, OFFSET outroMsg
	call	WriteString
	; Display the users name
	mov		edx, OFFSET username
	call	WriteString
	; Display the period
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
