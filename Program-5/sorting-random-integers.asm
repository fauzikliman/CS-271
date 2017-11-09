TITLE Sorting Random Integers     (sorting-random-integers.asm)

; Author: Fauzi Kliman
; OSU Email: klimanf@oregonstate.edu
; Class number and section: CS271-001
; Assignment Number: 5
; Assignment Due Date: 11/12/17 11:59pm

; Course / Project ID : Sorting Random Integers                Date: 11/12/17
; Description: This program will introduce the program and programmer to the user.
;	The program will then ask the user for the amount numbers the user wants to
;	be sorted. An array of numbers specified by the user will be randomly generated
;	within the values of 100 and 999. The program will then display the array before
;	sorted, the median, and after its sorted.

INCLUDE Irvine32.inc

MIN_ARRAY_SIZE = 5
MAX_ARRAY_SIZE = 200

MIN_ARRAY_NUM = 100
MAX_ARRAY_NUM = 999

NUM_PER_LINE = 10

.data

introMsg			BYTE	"Sorting Random Integer", 9, 9, 9, "Programmed by Fauzi Kliman", 10, 13,
							"This program generates random numbers in the range [100 .. 999],", 10, 13,
							"displays the original list, sorts the list, and calculates the", 10, 13,
							"median value. Finally, it displays the list sorted in descending order.", 10, 13, 10, 13, 0
arraySizePrompt		BYTE	"How many numbers should be generated? [10 .. 200]: ", 0
invalidInputMsg		BYTE	"Invalid input", 10, 13, 0
periodChar			BYTE	".", 0
numberPaddingMsg	BYTE	9, 0
unsortedArrayMsg	BYTE	"The unsorted random numbers:", 10, 13, 0
sortedArrayMsg		BYTE	"The sorted list:", 10, 13, 0
medianMsg			BYTE	"The median is ", 0

arraySize			DWORD	0
array				DWORD	MAX_ARRAY_SIZE DUP(100)

.code

main PROC

	; Seed RandomRange procedure
	call	Randomize

	; Introduce the program and program info to user
	call	Introduction

	; Get the amount numbers to sort from the user
	push	OFFSET arraySize
	call	GetData

	; For debugging
	mov		eax, arraySize
	call	WriteDec
	call	CrLf

	; Generate amount of numbers specified by user randomly
	push	OFFSET array
	push	arraySize
	call	FillArray

	; Display the unsorted array to the user
	push	OFFSET array
	push	arraySize
	push	OFFSET unsortedArrayMsg
	call	DisplayList

	; Sort the array
	call	SortList

	; Display the median of the array
	push	OFFSET array
	push	arraySize
	call	DisplayMedian

	; Display the sorted array to the user
	push	OFFSET array
	push	arraySize
	push	OFFSET sortedArrayMsg
	call	DisplayList

	exit	; exit to operating system
main ENDP

; Procedure to display the program name and various information about it
; Recieves: introMsg is a global variable
; Returns: none
; Preconditions: none
; Registers changed: none
Introduction PROC
	pushad
	mov		edx, OFFSET introMsg
	call	WriteString
	popad
	ret
Introduction ENDP

; Procedure to get the amount of numbers the user wants to be sorted
; Recieves: address of variable to hold user input
; Returns: variable passed in contains a valid array size
; Preconditions: none
; Registers changed: none
GetData PROC

	; Setup the stack frame and save all the registers
	push	ebp
	mov		ebp, esp
	pushad

	; Move the address of the array size parameter into edi
	mov		edi, [ebp + 8]

	; Prompt the user for the amount of numbers to sort
begUserInput:
	mov		edx, OFFSET arraySizePrompt
	call	WriteString
	call	ReadInt

	; Check that the input from the user is within the MIN and MAX for array size
	cmp		eax, MIN_ARRAY_SIZE
	jl		invalidInput
	cmp		eax, MAX_ARRAY_SIZE
	jg		invalidInput
	jmp		endUserInput

	; Display user input invalid message and go to asking for user input again
invalidInput:
	mov		edx, OFFSET invalidInputMsg
	call	WriteString
	jmp		begUserInput

	; Valid input was given by th user, update the value in the parameter
endUserInput:
	mov		[edi], eax

	; Clean up the stack frame restore all the registers
	popad
	pop		ebp
	ret		4
GetData ENDP

; Procedure to generate an array with the amount of numbers the user entered
; Recieves: address of DWORD array to fill, array size
; Returns: array of length size filled with random numbers
; Preconditions: none
; Registers changed: none
FillArray PROC
	
	; Setup the stack frame and save all the registers
	push	ebp
	mov		ebp, esp
	pushad

	; Move the address of the array parameter to edi
	mov		edi, [ebp + 12]
	
	; Move the value of the array size parameter to ecx for looping later
	mov		ecx, [ebp + 8]
	
	; Calculate the random range for the RandomRange procedure to be (MAX - MIN + 1)
	mov		ebx, MAX_ARRAY_NUM
	sub		ebx, MIN_ARRAY_NUM
	inc		ebx

	; Fill the array with random numbers
begFill:
	; Set eax to the random range and generate random number into eax
	mov		eax, ebx
	call	RandomRange
	add		eax, MIN_ARRAY_NUM

	; Set current element in array to the random number
	mov		[edi], ecx	; Should be eax, but ecx for now for debugging

	; Move to next element in the array and repeat
	add		edi, 4
	loop	begFill

	; Clean the stack frame and restore all the registers
	popad
	pop		ebp
	ret		8
FillArray ENDP

; Sorts the array
SortList PROC
	ret
SortList ENDP

; Procedure to display the median of the array
; Recieves: address of DWORD array to fill, array size
; Returns: none
; Preconditions: the array is sorted in descending order
; Registers changed: none
DisplayMedian PROC

	; Setup local variables and save all the registers
	LOCAL	median:DWORD
	pushad

	; Move the address of the array to esi
	mov		esi, [ebp + 12]

	; Display the median message
	mov		edx, OFFSET medianMsg
	call	WriteString

	; Calculate the middle index of the array where the median will be
	mov		eax, [ebp + 8]		; Move array size to eax for division
	mov		ebx, 2
	cdq
	div		ebx
	mov		ecx, eax			; Move median index to ecx

	; Move value in array to median variable
	mov		eax, [esi + ecx * 4]
	mov		median, eax

	; If there is a remainder of 0, it means that the array has an even number of
	; elements, so we need to add the 2 middle elements and average them, rounded to nearest
	; integer to get the median
	cmp		edx, 0
	jne		showMedian
	dec		ecx						; Descrement ecx to the previous index in the array
	mov		eax, median
	add		eax, [esi + ecx * 4]	; Add the 2 middle elements together
	cdq
	div		ebx						; Divide by 2 get average, ebx still contains 2 from previous division
	
	; Move the avg of the middle elements of median
	mov		median, eax

	; If there is a remainder from the avg division we need to round the median up
	cmp		edx, 1
	jne		showMedian
	inc		median

	; Display the median
showMedian:
	mov		eax, median
	call	WriteDec
	call	CrLf

	; Clean the stack frame and restore all the registers
	popad
	ret		8
DisplayMedian ENDP

; Displays the array
; Procedure to display a message and an array
; Recieves: address of DWORD array to display, array size, address of message to display
; Returns: none
; Preconditions: none
; Registers changed: none
DisplayList PROC

	; The idea behind printing the list in column order is to split the output
	; window into two sections. The first section will be N cols x M rows where N is the remainder
	; of the array size divided by the max numbers displayed per line. M is the quotient of
	; the array size divided by the max numbers displayed per line + 1. The second section will
	; be K cols x J rows where k is the max numbers displayed per line - N and J is the  quotient
	; of the array size. This so that within each section there is always a full row of data

	;	10	6	3
	;	9	5	2
	;	8	4	1
	;	7
	;
	;	Given following example,
	;	N = 1	Section 1 cols
	;	M = 4	Section 1 rows
	;	K = 2	Section 2 cols
	;	J = 3	Section 2 rows

	; Setup the local variables and save all the registers
	LOCAL	sec1Cols:DWORD				; N cols
	LOCAL	sec1Rows:DWORD				; M rows
	LOCAL	sec1ElemCount:DWORD			; Amount of elements in section 1
	LOCAL	sec2Rows:DWORD				; J rows
	LOCAL	rowNum:DWORD
	LOCAL	colNum:DWORD
	LOCAL	bytesPerElem:DWORD
	LOCAL	arrayAddress:DWORD
	pushad

	; Bytes each element of DWORD array takes up
	mov		bytesPerElem, 4

	; Move the address of the array paremeter to arrayAddress
	mov		esi, [ebp + 16]
	mov		arrayAddress, esi

	; Move the value of the array size paremeter to ecx for looping
	mov		ecx, [ebp + 12]

	; Display the message that was passed in
	mov		edx, [ebp + 8]
	call	WriteString

	; Calculate the amount rows of numbers that'll be printed for section 1 and 2
	mov		ebx, NUM_PER_LINE
	mov		eax, ecx			; ecx contains the size of the array
	cdq
	div		ebx
	mov		sec2Rows, eax

	; Section 1 only exists if all the elements could not be displayed in full rows of
	; NUM_PER_LINE
	cmp		edx, 0
	jne		setupSec1Data
	
	; Set sec1 data to 0 since all elements could be displayed in full rows of NUM_PER_LINE
	mov		sec1ElemCount, 0
	mov		sec1Cols, 0
	mov		sec1Rows, 0
	jmp		endSecDataCalc

setupSec1Data:
	; Set sec1Rows to sec2Rows + 1, and sec1Cols to the remainder of array size divided by NUM_PER_LINE
	mov		eax, sec2Rows
	inc		eax
	mov		sec1Rows, eax
	mov		sec1Cols, edx

	; Set the amount of elements in section 1
	mov		eax, sec1Cols
	mul		sec1Rows
	mul		bytesPerElem
	mov		sec1ElemCount, eax

endSecDataCalc:
	; Prepare printing the array by column
	mov		rowNum, 0				; will contain the row number we're on starting at 0
	mov		colNum, 0				; will contain the col number we're on starting at 0

begDisplayList:
	; Print newline if we've displayed the maximum amount of numbers per row
	cmp		colNum, NUM_PER_LINE
	jl		endDisplayNewline
	call	CrLf
	inc		rowNum					; increment row number
	mov		colNum, 0				; reset col number

endDisplayNewline:
	mov		eax, colNum
	cmp		eax, sec1Cols
	mov		esi, arrayAddress
	jge		sec2Area

	; We're displaying values to the section 1 area of the output
	; To display in section 1 we multiply the current col num by the 
	; amount of rows in section 1 and add the row num as the offset
	mov		eax, colNum
	mul		sec1Rows
	add		eax, rowNum
	mul		bytesPerElem
	add		esi, eax
	jmp		displayArrayValue

sec2Area:
	; We're displaying values to the section 2 area of the output
	; To display in section 2 we get difference between the current col num
	; and the amount of cols in section 1, multipy that by the amount of rows
	; in section 2 and add the row num as the offset, then add the amount elems
	; that exist in section 1 before section 2
	mov		eax, colNum
	sub		eax, sec1Cols
	mul		sec2Rows
	add		eax, rowNum
	mul		bytesPerElem
	add		eax, sec1ElemCount
	add		esi, eax

displayArrayValue:
	; Display the value in the array
	mov		eax, [esi]
	call	WriteDec
	
	; Display spaces after each number=
	mov		edx, OFFSET numberPaddingMsg
	call	WriteString

	; Increment col number and number of numbers we've displayed
	inc		colNum

	; Loop printing the array values
	loop	begDisplayList
	call	CrLf

	; Restore all the registers
	popad
	ret		12
DisplayList ENDP

END main
