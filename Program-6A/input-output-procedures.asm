TITLE I/O Procedures     (input-output-procedures.asm)

; Author: Fauzi Kliman
; OSU Email: klimanf@oregonstate.edu
; Class number and section: CS271-001
; Assignment Number: 6A
; Assignment Due Date: 12/3/17 11:59pm

; Course / Project ID : I/O Procedures              Date: 12/3/17
; Description: This program will use our custom ReadVal/WriteVal procedures
;	for integers with custom getString/displayString macros for user input.
;	The program will then introduce the program and the programmer, ask for 
;	10 numbers, display the 10 numbers, and display the sum and average.

INCLUDE Irvine32.inc

; Const definitions
MAX_NUMBERS = 10

; Macro definitions

; Macro to display the string at the buffer address to the user
; Recieves: address of buffer
; Returns: none
; Preconditions: buffer is null terminated
; Registers changed: none
mDisplayString MACRO bufferAddr
	; Save edx register
	push	edx

	; Display the string at the buffer
	mov		edx, bufferAddr
	call	WriteString

	; Restore edx register
	pop		edx
ENDM

; Macro to display a prompt and gets a string input from the user and stores it in the buffer
; Recieves: address of prompt buffer, address of buffer, size of buffer
; Returns: prompt buffer will be displayed, buffer will contain null terminated user input
; Preconditions: prompt buffer is null terminated
; Registers changed: none
mGetString MACRO promptAddr, bufferAddr, bufferSize
	; Display prompt
	mDisplayString promptAddr

	; Save eax, ecx, and edx registers
	push	eax
	push	ecx
	push	edx

	; Read input from user into buffer
	mov		edx, bufferAddr
	mov		ecx, bufferSize
	call	ReadString

	; Restore eax, ecx, and edx registers
	pop		edx
	pop		ecx
	pop		eax
ENDM

.data

introMsg				BYTE	"PROGRAMMING ASSIGNMENT 6A: Designing low-level I/O procedures", 10, 13, 10, 13,
								"Written by: Fauzi Kliman", 10, 13,
								"Please provide 10 unsigned decimal integers.", 10, 13,
								"Each number needs to be small enough to fit inside a 32 bit register.", 10, 13,
								"After you have finished inputting the raw numbers I will display a list", 10, 13,
								"of the integers, their sum, and their average.", 10, 13, 10, 13, 0
outroMsg				BYTE	"Thanks for playing!", 10, 13, 0
numberPrompt			BYTE	"Please enter an unsigned number: ", 0
invalidNumberMsg		BYTE	"ERROR: You did not enter an usigned number or your number was too big.", 10, 13, 0
invalidNumberPrompt		BYTE	"Please try again: ", 0
displayNumberMsg		BYTE	"You entered the following numbers:", 10, 13, 0
numberSumMsg			BYTE	"The sum of these numbers is: ", 0
numberAvgMsg			BYTE	"The average is: ", 0
commaSpaceMsg			BYTE	", ", 0
currentNumber			DWORD	0
numberSum				DWORD	0
numbers					DWORD	MAX_NUMBERS DUP(0)

.code
main PROC
	; Display intro message
	mDisplayString OFFSET introMsg

	; Move address of numbers array to edi and set ecx to MAX_NUMBERS
	mov		edi, OFFSET numbers
	mov		ecx, MAX_NUMBERS

_begNumberPrompt:
	; Get a valid number from the user
	push	OFFSET numberPrompt
	push	OFFSET invalidNumberPrompt
	push	OFFSET invalidNumberMsg
	push	OFFSET currentNumber
	call	ReadVal

	; Add the number to the sum
	mov		eax, currentNumber
	add		numberSum, eax

	; Put the number in the numbers array and move to the next element
	mov		eax, currentNumber
	mov		[edi], eax
	add		edi, 4

	loop	_begNumberPrompt
	call	CrLf

	; Move address of numbers array to esi set ecx to MAX_NUMBERS
	mov		esi, OFFSET numbers
	mov		ecx, MAX_NUMBERS

	; Display message about the numbers entered
	mDisplayString OFFSET displayNumberMsg

_begDisplayNumbers:
	; Display the number and move to next element
	push	[esi]
	call	WriteVal
	add		esi, 4

	; Display the comma and a space if its not the last number
	cmp		ecx, 1
	jle		_endDisplayCommaSpace
	mDisplayString OFFSET commaSpaceMsg

_endDisplayCommaSpace:
	loop	_begDisplayNumbers
	call	CrLf

	; Display the sum
	mDisplayString OFFSET numberSumMsg
	push	numberSum
	call	WriteVal
	call	CrLf

	; Calculate the average
	mov		eax, numberSum
	mov		ebx, MAX_NUMBERS
	cdq
	div		ebx

	; Display avg
	mDisplayString OFFSET numberAvgMsg
	push	eax
	call	WriteVal
	call	CrLf
	call	CrLf

	; Display outro
	mDisplayString OFFSET outroMsg

	exit	; exit to operating system
main ENDP

; Procedure to display a prompt for user input and gets a number from the user
; Recieves: address of number prompt, address of invalid number prompt, address of invalid number message,
;	address of variable to contain a valid number
; Returns: variable passed in contains a valid number from the user
; Preconditions: none
; Registers changed: none
ReadVal PROC
	; Setup local variables and save all registers
	LOCAL	tmpBufferSize:DWORD
	LOCAL	tmpBuffer[80]:BYTE
	LOCAL	parsedNumber:DWORD
	LOCAL	parsedNumberFactor:DWORD
	LOCAL	currentChar:DWORD
	pushad

	; Init local variables
	mov		tmpBufferSize, 80
	mov		tmpBuffer[79], 0
	mov		parsedNumberFactor, 10

	; Move address of tmp buffer to edi
	lea		edi, tmpBuffer

	; Set direction flag to forward for when we're parsing the string
	cld

_promptNumber:
	; Get user input, pass in number prompt, address of tmp buffer, size of tmp buffer
	mGetString [ebp + 20], edi, tmpBufferSize
	jmp		_parseNumber

_invalidPromptNumber:
	; Display invalid number error, pass in invalid number message
	mDisplayString [ebp + 12]

	; Get user input, pass in invalid number prompt, address of tmp buffer, size of tmp buffer
	mGetString [ebp + 16], edi, tmpBufferSize

_parseNumber:
	; Init parsed number to 0
	mov		parsedNumber, 0

	; Init number of digits processed to 0
	mov		ecx, 0

	; Move address of tmp buffer to esi
	mov		esi, edi

_begParseLoop:
	; Get current character byte in tmp buffer to al and move it currentChar
	lodsb
	mov		BYTE PTR currentChar, al

	; Check if current character is 0, if so it means we're done
	cmp		currentChar, 0
	je		_endParseNumber

	; Check if current character is a valid digit, 48 = 0, 57 = 9, if not its invalid then
	cmp		currentChar, 48
	jl		_invalidPromptNumber
	cmp		currentChar, 57
	jg		_invalidPromptNUmber

	; Else its a valid digit, multiply the current parsed number by 10 and add the current character
	; as a digit by subtractin 48 (0) from it
	mov		eax, parsedNumber
	mul		parsedNumberFactor

	; If the parsed number is too big, its invalid
	jc		_invalidPromptNumber

	; Convert current character to digit by subtracting 48 (0) from it
	mov		ebx, currentChar
	sub		ebx, 48

	; Add the current digit to the parsed number
	add		eax, ebx

	; If the parsed number is too big, its invalid
	jc		_invalidPromptNumber

	; Update the parsed number variable and the amount of digits we've processed
	mov		parsedNumber, eax
	inc		ecx

	; Loop again to the next character
	jmp		_begParseLoop

_endParseNumber:
	; If we didn't parse any digits, that means the user just pressed enter
	cmp		ecx, 0
	je		_invalidPromptNumber

	; Move the parsed number into the address of the passed in variable to contain it
	mov		eax, parsedNumber
	mov		edi, [ebp + 8]
	mov		[edi], eax

	; Cleanup stack and restore all registers
	popad
	ret		16
ReadVal ENDP

; Procedure to write the number passed in to the user
; Recieves: number value to be displayed to the user
; Returns: none
; Preconditions: variable contains a number
; Registers changed: none
WriteVal PROC
	; Setup local variables and save all registers
	LOCAL	numStrSize:DWORD
	LOCAL	numStr[40]:BYTE
	LOCAL	numDivisor:DWORD
	pushad

	; Init numStrSize and numDivisor
	mov		numStrSize, 40
	mov		numDivisor, 10

	; Move value of variable to eax
	mov		eax, [ebp + 8]

	; Move the address of the numStr to edi
	lea		edi, numStr

	; Set ecx to numStrSize - 1 for looping, numStrSize - 1 because the last element will
	; be the null terminating character
	mov		ecx, numStrSize
	dec		ecx

	; Repeatedly divide the number by 10 to get each digit in the number,
	; convert that digit to ascii to get the text representation, and store 
	; it in the numStr byte array
_begAsciiConversion:
	; Divide the number by 10, the remainder will be the right most digit
	cdq
	div		numDivisor

	; Move remainder to ebx to convert to ascii by adding 48 (0) to it
	mov		ebx, edx
	add		ebx, 48

	; Move the ascii number (ebx) to numStr and set edi to the next element
	mov		[edi], ebx
	inc		edi

	; If the quotient is 0, that means we're done looping for digits
	cmp		eax, 0
	je		_endAsciiConversion

	loop	_begAsciiConversion

_endAsciiConversion:
	; Set the last element to 0 for null character
	mov		eax, 0
	mov		[edi], eax

	; Move the address of the first element to esi and decrement edi
	; to get the last digit element
	lea		esi, numStr
	dec		edi

	; The order of the digits in the numStr is reversed because of
	; how we got the digits, so we need to reverse it normal
_begSwapElements:
	; Swap the beg and end elements and move inwards
	mov		al, [esi]
	mov		bl, [edi]
	mov		[esi], bl
	mov		[edi], al

	; Increment esi and decrement edi
	inc		esi
	dec		edi

	; If esi is greater than or equal to edi then we don't need swap anymore
	cmp		esi, edi
	jge		_endSwapElements
	jmp		_begSwapElements

_endSwapElements:
	; Display the number to the user
	lea		esi, numStr
	mDisplayString esi

	; Cleanup stack and restore all registers
	popad
	ret		4
WriteVal ENDP

END main
