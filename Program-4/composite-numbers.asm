TITLE Composite Numbers     (composite-numbers.asm)

; Author: Fauzi Kliman
; OSU Email: klimanf@oregonstate.edu
; Class number and section: CS271-001
; Assignment Number: 4
; Assignment Due Date: 10/29/17 11:59pm

; Course / Project ID : Composite Numbers               Date: 10/29/17
; Description:

INCLUDE Irvine32.inc

; (insert constant definitions here)

MIN_COMPOSITES = 1		; Minimum number of composite numbers
MAX_COMPOSITES = 1000	; Maximum number of composite numbers
MAX_NUMBERS_PER_LINE = 10	; Numbers per row to be displayed
MAX_LINES_PER_PAGE = 10		; Lines of numbers per page to be displayed
MAX_COMPOSITE_NUMBER_WIDTH = 8	; The amount of characters a composite number can take up in the output
PRIMES_BEFORE_MAX_COMPOSITE = 197	; Number of prime numbers before the max number of composite numbers

.data

; (insert variable definitions here)

	introMsg					BYTE	"Composite Numbers", 9, "Programmed by Fauzi Kliman", 0
	outroMsg					BYTE	"Results certified by Fauzi Kliman. Goodbye.", 0
	instructionsMsg				BYTE	"Enter the number of composite numbers you would like to see.", 0
	maxCompositesMsg			BYTE	"I'll accept orders for up to 1000 composites.", 0
	numberOfCompositesPrompt	BYTE	"Enter the number of composites to display [1 .. 1000]: ", 0
	numberOfCompositesErrorMsg	BYTE	"Out of range. Try again.", 0
	spaceChar					BYTE	" ", 0
	ec1Msg						BYTE	"**EC: Output columns are aligned.", 0
	ec2Msg						BYTE	"**EC: More composite with paged output. 10 numbers per line, 10 lines per page", 0
	ec3Msg						BYTE	"**EC: Enhanced efficiency using array of primes.", 0

	userInputValid				BYTE	0	; Holds 1 for valid user input, 0 for invalid input
	numberOfComposites			DWORD	0	; Number of composites the user wants to be displayed
	testNumberIsComposite		BYTE	0	; Holds 1 if the testNumber is composite, 0 for prime
	testNumber					DWORD	0	; Number for checking if its composite
	numbersCountLine			DWORD	0	; Number of numbers on a line of output
	linesCountPage				DWORD	0	; Lines of numbers of ouput
	pageCount					DWORD	0	; Pages of numbers of output
	totalNumbersDisplayed		DWORD	0	; Total number of composite numbers displayed
	compositeNumber				DWORD	0	; Composite number for checking how many digits it has
	compositeNumberLength		DWORD	0	; The number of digits a composite number has
	startingCompositeNumber		DWORD	4	; First number for checking if its composite or not
	primesArrayLength			DWORD	2	; Length of primes array
	primesArray					DWORD	2, 3, PRIMES_BEFORE_MAX_COMPOSITE DUP(0)	; Array of prime numbers
	compositesArrayLength		DWORD	0	; Length of composites array
	compositesArray				DWORD	MAX_COMPOSITES DUP(0)	; Array of composite numbers


.code
main PROC

; (insert executable instructions here)

	; Introduces the program, programmer, and how to use the program
	call	Introduction

	; Gets how many composite numbers the user wants displayed, does user validation as well
	call	GetUserData

	; Calculates the number of composite numbers the user wanted
	call	CalculateComposites

	; Displays all the composite numbers in a page format
	call	ShowComposites

	; Says goodbye to the user
	call	Farewell

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

; Procedure to display the program name and various information about it
; Recieves: introMsg, ec1Msg, ec2Msg, ec3Msg, instructionMsg, and maxCompositeMsg are global variables
; Returns: none
; Preconditions: none
; Registers changed: none
Introduction PROC
	pushad

	; Display the intro message
	mov		edx, OFFSET introMsg
	call	WriteString
	call	CrLf
	call	CrLf

	; Display extra credit 1 message
	mov		edx, OFFSET ec1Msg
	call	WriteString
	call	CrLf

	; Display extra credit 2 message
	mov		edx, OFFSET ec2Msg
	call	WriteString
	call	CrLf

	; Display extra credit 3 message
	mov		edx, OFFSET ec3Msg
	call	WriteString
	call	CrLf
	call	CrLf

	; Display the instructions for the program message
	mov		edx, OFFSET instructionsMsg
	call	WriteString
	call	CrLf
	
	; Display the max composites allowed message
	mov		edx, OFFSET maxCompositesMsg
	call	WriteString
	call	CrLf
	call	CrLf

	popad
	ret
Introduction ENDP

; Procedure to ask the user for the number of composite numbers they want shown
; Recieves: numberOfCompositesPrompt, numberOfComposites,  numberOfCompositesErrorMsg are global variables
; Returns: global numberOfComposites = valid user input
; Preconditions: none
; Registers changed: none
GetUserData PROC
	pushad
begUserInput:
	; Display prompt asking for number of composites to show
	mov		edx, OFFSET numberOfCompositesPrompt
	call	WriteString

	; Read the number of composite numbers the user wants
	call	ReadInt
	mov		numberOfComposites, eax

	; Validate the number of composites to see if its within 
	; the min/max bounds
	call	Validate

	; Result of validate procedure is in userInputValid, 1 for valid, 0 for invalid
	cmp		userInputValid, 1
	je		endUserInput

	; Display error message and jmp to ask for user input again
	mov		edx, OFFSET numberOfCompositesErrorMsg
	call	WriteString
	call	CrLf
	jmp		begUserInput
endUserInput:
	popad
	ret
GetUserData ENDP

; Procedure to validate that the amount of composite numbers the user wants
;	is within the limits
; Recieves: numberOfComposites, userInputValid are global variables
; Returns: global userInputValid = 1 if valid, 0 otherwise
; Preconditions: none
; Registers changed: none
Validate PROC
	pushad
	; Check if the number of composites is greater than the minimum
	cmp		numberOfComposites, MIN_COMPOSITES
	jl		inputInvalid

	; Check if the number of composites is less than the maximum
	cmp		numberOfComposites, MAX_COMPOSITES
	jg		inputInvalid

	; Mark input as valid by moving true (1) into eax
	mov		userInputValid, 1
	jmp		endValidate

	; Mark input as invalid by move false (0) into eax
inputInvalid:
	mov		userInputValid, 0
endValidate:
	popad
	ret
Validate ENDP

; Procedure to calculate the composite number
; Recieves: numberOfComposites, startingCompositeNumber, testNumber, testNumberIsComposite, primesArrayLength
;	primesArray, compositesArrayLength, compositesArray are global variables
; Returns: primersArray is an array of prime numbers, compositesArray is an array of composite numbers
; Preconditions: numberOfComposites is within MIN_COMPOSITES and MAX_COMPOSITES
; Registers changed: none
CalculateComposites PROC
	pushad

	; Initialize variables
	mov		ecx, numberOfComposites
	mov		ebx, startingCompositeNumber
begLoop:
	; Move starting composite number into variable for IsComposite function
	; and call IsComposite function
	mov		testNumber, ebx
	call	IsComposite

	; Check if the number is composite or not
	cmp		testNumberIsComposite, 1
	je		numberIsComposite

	; Save number into primes array if its prime
	mov		eax, TYPE primesArray
	mul		primesArrayLength
	add		eax, OFFSET primesArray
	mov		[eax], ebx
	inc		ebx
	inc		primesArrayLength
	jmp		begLoop

	; Save number into composite array if its composite
numberIsComposite:
	mov		eax, TYPE compositesArray
	mul		compositesArrayLength
	add		eax, OFFSET compositesArray
	mov		[eax], ebx
	inc		ebx
	inc		compositesArrayLength
	loop	begLoop

	popad
	ret
CalculateComposites ENDP

; Procedure to show the composites in a page format
; Recieves: linesCountPage, pageCount, compositesArrayLength, compositesArray, compositeNumber, totalNumbersDisplayed, 
;	numbersCountLine, compositeNumberLength, are global variables
; Returns: global primersArray is an array of prime numbers, compositesArray is an array of composite numbers
; Preconditions: none
; Registers changed: none
ShowComposites PROC
	pushad

; Loop display lines of composite numbers
begPageLoop:
	; Add number of numbers on current line
	mov		ecx, numbersCountLine

	; Add numbers whole lines
	mov		eax, MAX_NUMBERS_PER_LINE
	mul		linesCountPage
	add		ecx, eax

	; Add numbers from whole pages
	mov		eax, MAX_NUMBERS_PER_LINE
	mov		ebx, MAX_LINES_PER_PAGE
	mul		ebx
	mul		pageCount
	add		ecx, eax

	; Multiply number of numbers by 4
	mov		eax, ecx
	mov		ebx, TYPE compositesArray
	mul		ebx
	mov		ecx, eax

	; Add offset of composite array
	add		ecx, OFFSET compositesArray
	mov		esi, ecx

; Loop displaying composite numbers on a line
begLineLoop:	
	; Calculate how many digits are in the composite number and display the composite number
	mov		eax, [esi]
	mov		compositeNumber, eax
	call	CalculateCompositeNumberLength
	mov		eax, compositeNumber
	call	WriteDec
	
	; Increment variable for how many numbers have been displayed overall
	mov		eax, totalNumbersDisplayed
	inc		eax
	mov		totalNumbersDisplayed, eax

	; Exit loop if we've displayed all the composited numbers
	cmp		eax, compositesArrayLength
	jge		allCompositeNumbersDisplayed

	; Increment variable for how many numbers have been dislayed on this line
	mov		eax, numbersCountLine
	inc		eax
	mov		numbersCountLine, eax

	; Display empty spaces after the composite number if its not the last number on the line
	mov		eax, numbersCountLine
	cmp		eax, MAX_NUMBERS_PER_LINE
	jl		begEmptySpaces
	call	CrLf
	jmp		endLineLoop

; Setup for printing empty spaces after composite number on a line
begEmptySpaces:
	mov		eax, MAX_COMPOSITE_NUMBER_WIDTH
	sub		eax, compositeNumberLength
	mov		edx, OFFSET spaceChar
; Loop displaying empty spaces
begEmptySpacesLoop:
	cmp		eax, 0
	jle		endEmptySpacesLoop
	call	WriteString
	dec		eax
	jmp		begEmptySpacesLoop
endEmptySpacesLoop:
	add		esi, TYPE compositesArray
	jmp		begLineLoop
endLineLoop:
	; Increment how many lines of numbers has been displayed
	mov		eax, linesCountPage
	inc		eax
	mov		linesCountPage, eax

	; Reset how many numbers has been displayed on this line
	mov		eax, 0
	mov		numbersCountLine, eax

	; Only display a certain number of lines per page
	mov		eax, linesCountPage
	cmp		eax, MAX_LINES_PER_PAGE
	jge		endPageLoop
	jmp		begPageLoop
endPageLoop:
	; Wait for user input before displaying another page of numbers
	call	WaitMsg
	call	CrLf

	; Incremenet variable for how many pages has been displayed
	mov		eax, pageCount
	inc		eax
	mov		pageCount, eax

	; Reset how many pages has been displayed
	mov		eax, 0
	mov		linesCountPage, eax

	jmp		begPageLoop
allCompositeNumbersDisplayed:
	call	CrLf
	popad
	ret
ShowComposites ENDP

; Procedure to check if a number is composite
; Recieves: testNumberIsComposite, testNumber, testNumber, primesArray, numberIsComposite are global variables
; Returns: global testNumberIsComposite is 1 if testNumber is composite, 0 otherwise
; Preconditions: none
; Registers changed: none
IsComposite PROC
	pushad
	; Move address of first element in primes array to esi
	mov		esi, 0
	; Set number is composite to false (0)
	mov		testNumberIsComposite, 0

; Check if a test number is composite by dividing it by all primes starting at 2, 
; stopping once the prime number is greater than half the test number. If it is divisible
; by one of the prime numbers then it is composite, otherwise it is prime
begLoop:
	; Divide the test number by the prime number in the current address of esi
	mov		eax, testNumber
	cdq
	div		primesArray[esi]

	; If the remainder is 0, then it is a composite number
	cmp		edx, 0
	je		numberIsComposite

	; If the prime number is 2, then we need to set the max prime number
	; the test number could be divisible by to be composite
	cmp		primesArray[esi], 2
	jne		endSetMaxPrimeNumber

	; Sets the max prime number the test number could be divisible by to be
	; a composite number to be the quotient when the divisor was 2
	mov		ebx, eax
endSetMaxPrimeNumber:

	; Set the address in esi to the next element in the prime array
	add		esi, TYPE primesArray

	; If the next prime number is greater than half of the test number
	; then the test number is not a composite number
	cmp		primesArray[esi], ebx
	jg		endIsComposite
	cmp		primesArray[esi], 0
	je		endIsComposite
	jmp		begLoop

; Sets the numberIsComposite variable to true (1)
numberIsComposite:
	mov		testNumberIsComposite, 1
endIsComposite:
	popad
	ret
IsComposite ENDP

; Procedure to calculate the amount digits in the composite number
; Recieves: compositeNumber, compositeNumberLength are global variables
; Returns: global compositeNumberLength = number of digits in compositeNumber
; Preconditions: none
; Registers changed: none
CalculateCompositeNumberLength PROC
	pushad

	; Divide the composite number by 10, incrementing the amount of digits
	; it has until the quotient is 0
	mov		eax, compositeNumber
	mov		ebx, 10
	mov		ecx, 1

	; Divide the composite number repeatedly until the quotient is 0,
	; incrementing the amount of digits it has each iteration
begLoop:
	cdq
	div		ebx
	; Stop dividing if the quoteint is 0
	cmp		eax, 0
	je		endLoop
	; Increment the amount of digits the composite number has
	inc		ecx
	jmp		begLoop
endLoop:
	; Update the compositeNumberLength variable
	mov		compositeNumberLength, ecx
	popad
	ret
CalculateCompositeNumberLength ENDP

; Procedure to display the farewell message
; Recieves: outroMsg are global variables
; Returns: none
; Preconditions: none
; Registers changed: none
Farewell PROC
	pushad
	call	CrLf
	mov		edx, OFFSET outroMsg
	call	WriteString
	call	CrLf
	popad
	ret
Farewell ENDP

END main
