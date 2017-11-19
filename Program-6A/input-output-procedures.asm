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

; Displays the string at the buffer address to the user
mDisplayString MACRO bufferAddr
	; Save edx register
	push	edx

	; Display the string at the buffer
	mov		edx, bufferAddr
	call	WriteString

	; Restore edx register
	pop		edx
ENDM

; Displays a prompt and gets a string input from the user and stores it in the buffer
mGetString MACRO promptAddr, bufferAddr, bufferSize
	; Display prompt
	mDisplayString promptAddr

	; Save ecx and edx register
	push	ecx
	push	edx

	; Read input from user into buffer
	mov		edx, bufferAddr
	mov		ecx, bufferSize
	call	ReadString

	; Restore ecx and edx register
	pop		edx
	pop		ecx
ENDM

.data

introMsg				BYTE	"PROGRAMMING ASSIGNMENT 6A: Designing low-level I/O procedures", 10, 13, 10, 13,
								"Written by: Fauzi Kliman", 10, 13,
								"Please provide 10 unsigned decimal integers.", 10, 13,
								"Each number needs to be small enough to fit inside a 32 bit register.", 10, 13,
								"After you have finished inputting the raw numbers I will display a list", 10, 13,
								"of the integers, their sum, and their average.", 10, 13, 10, 13, 0
numberPrompt			BYTE	"Please enter an unsigned number: ", 0
invalidNumberMsg		BYTE	"ERROR: You did not enter an usigned number or your number was too big.", 10, 13, 0
invalidNumberPrompt		BYTE	"Please try again: ", 0
currentNumber			DWORD	0

.code
main PROC
	; Display intro message
	push	OFFSET introMsg
	call	DisplayIntro

	; Get 10 numbers from the user
	mov		ecx, MAX_NUMBERS

	push	OFFSET numberPrompt
	push	OFFSET invalidNumberPrompt
	push	OFFSET invalidNumberMsg
	push	OFFSET currentNumber
	call	ReadVal

	mov		eax, currentNumber
	call	WriteDec
	call	CrLf

	exit	; exit to operating system
main ENDP

; Procedure to introduce the program and programmer, and how to use the program
; Recieves: address of intro message
; Returns: none
; Preconditions: none
; Registers changed: none
DisplayIntro PROC
	; Setup stack
	push	ebp
	mov		ebp, esp

	; Display the intro message
	mDisplayString [ebp + 8]

	; Cleanup stack
	pop		ebp
	ret		4
DisplayIntro ENDP

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

	; Move address of tmp buffer to edi, address of number prompt to edx
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

; Procedure write the number in the address given
; Recieves: address of variable that contains the number to be displayed to the user
; Returns: none
; Preconditions: variable contains a number
; Registers changed: none
WriteVal PROC
	; Setup stack and save all registers
	push	ebp
	mov		ebp, esp
	pushad

	; Cleanup stack and restore all registers
	popad
	pop		ebp
	ret		4
WriteVal ENDP

END main
