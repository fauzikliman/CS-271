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

MIN_ARRAY_SIZE = 10		; Minimum size of the array
MAX_ARRAY_SIZE = 200	; Maximum size of the array

MIN_ARRAY_NUM = 100		; Minimum value of element in array
MAX_ARRAY_NUM = 999		; Maximum value of element in array

NUM_PER_LINE = 10		; Amount of numbers to be displayed per row

.data

introMsg			BYTE	"Sorting Random Integers", 9, 9, 9, "Programmed by Fauzi Kliman", 10, 13,
							"This program generates random numbers in the range [100 .. 999],", 10, 13,
							"displays the original list, sorts the list, and calculates the", 10, 13,
							"median value. Finally, it displays the list sorted in descending order.", 10, 13, 10, 13, 0
extraCreditMsg		BYTE	"**EC: Numbers are displayed ordered by column", 10, 13,
							"**EC: Quick Sort is used to sort the list", 10, 13,
							"**EC: FPU is used for calculating and rounding the median", 10, 13,
							"**EC: Numbers are generated into a file and then read from to fill the list", 10, 13, 10, 13, 0
arraySizePrompt		BYTE	"How many numbers should be generated? [10 .. 200]: ", 0
invalidInputMsg		BYTE	"Invalid input", 10, 13, 0
periodChar			BYTE	".", 0
numberPaddingMsg	BYTE	9, 0
unsortedArrayMsg	BYTE	"The unsorted random numbers:", 10, 13, 0
sortedArrayMsg		BYTE	"The sorted list:", 10, 13, 0
medianMsg			BYTE	"The median is ", 0
numbersFilename		BYTE	"random-numbers.txt", 0
arraySize			DWORD	0
array				DWORD	MAX_ARRAY_SIZE DUP(0)

.code

main PROC

	; Seed RandomRange procedure
	call	Randomize

	; Introduce the program and program info to user
	call	Introduction

	; Get the amount numbers to sort from the user
	push	OFFSET arraySize
	call	GetData

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
	push	OFFSET array
	push	arraySize
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
; Recieves: introMsg and extraCreditMsg are global variable
; Returns: none
; Preconditions: none
; Registers changed: none
Introduction PROC

	; Save all the registers
	pushad

	; Display the intro message
	mov		edx, OFFSET introMsg
	call	WriteString

	; Display the extra credit message
	mov		edx, OFFSET extraCreditMsg
	call	WriteString

	; Restore all the registers
	popad
	ret
Introduction ENDP

; Procedure to get the amount of numbers the user wants to be sorted
; Recieves: address of variable to hold user input, invalidInputMsg is a global variable
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
	call	CrLf

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
	
	; Push the size of the array and generate random numbers to the numbers file
	push	ecx
	call	GenerateNumbersToFile

	; Push the address of the array and the size of the array and read
	; numbers from the numbers file
	push	edi
	push	ecx
	call	ReadNumbersFromFileToArray

	; Clean up the stack frame and restore all the registers
	popad
	pop		ebp
	ret		8
FillArray ENDP

; Procedure to generate random numbers to the numbers file
; Recieves: array size
; Returns: none
; Preconditions: none
; Registers changed: none
GenerateNumbersToFile PROC

	; Setup local variables and save all the registers
	LOCAL	randomNumber:DWORD
	LOCAL	fileHandle:HANDLE
	pushad

	; Calculate the random range for the RandomRange procedure to be (MAX - MIN + 1)
	mov		ebx, MAX_ARRAY_NUM
	sub		ebx, MIN_ARRAY_NUM
	inc		ebx

	; Create new text file to store the random numbers, CreateOutputFile
	; modifies the ecx register
	mov		edx, OFFSET numbersFilename
	call	CreateOutputFile
	mov		fileHandle, eax

	; Move the value of the array size parameter to ecx for looping later
	mov		ecx, [ebp + 8]

	; Begin writing random numbers to the file
begWritingToFile:
	
	; Generate a random number
	mov		eax, ebx
	call	RandomRange
	add		eax, MIN_ARRAY_NUM
	mov		randomNumber, eax

	; Prepare writing to file
	push	ebx
	push	ecx

	; Move address of the local variable thats going to contain
	; the data to be written to the file to ebx
	mov		ebx, ebp
	sub		ebx, 4

	; Write to file
	mov		eax, fileHandle
	mov		edx, ebx
	mov		ecx, 4
	call	WriteToFile

	; Restore the loop counter and random range
	pop		ecx
	pop		ebx

	; Loop for as many as array size and close the file once done
	loop	begWritingToFile
	mov		eax, fileHandle
	call	CloseFile

	; Clean up the stack frame and restore all the registers
	popad
	ret		4
GenerateNumbersToFile ENDP

; Procedure to read numbers from the numbers file to the array thats passed in
; Recieves: address of DWORD array to fill, array size
; Returns: array is filled with numbers from the numbers file
; Preconditions: none
; Registers changed: none
ReadNumbersFromFileToArray PROC

	; Setup local variables and save all the registers
	LOCAL	number:DWORD
	LOCAL	fileHandle:HANDLE
	pushad

	; Put address of array to edi
	mov		edi, [ebp + 12]

	; Create an input file handle to use for reading the file
	mov		edx, OFFSET numbersFilename
	call	OpenInputFile
	mov		fileHandle, eax

	; Move the value of the array size parameter to ecx for looping later
	mov		ecx, [ebp + 8]

	; Begin reading numbers from the file
begReadingFromFile:

	; Prepare writing to the file by pushing ecx since ReadFromFile modifies it
	push	ecx

	; Move the address of the local variable thats going to
	; contain the number from the file to ebp
	mov		ebx, ebp
	sub		ebx, 4

	; Read a number from the file
	mov		eax, fileHandle
	mov		edx, ebx
	mov		ecx, 4
	call	ReadFromFile

	; Move the number from the file to the array, and increment the array
	; address to the next element
	mov		eax, [ebx]
	mov		[edi], eax
	add		edi, 4

	; Restore the loop counter
	pop		ecx

	; Loop reading the file and close the file when done
	loop	begReadingFromFile
	mov		eax, fileHandle
	call	CloseFile

	; Clean up the stack and restore all the registers
	popad
	ret	8
ReadNumbersFromFileToArray ENDP

; Procedure to sort the array recursively using quickSort
; Recieves: address of DWORD array to fill, array size
; Returns: none
; Preconditions: none
; Registers changed: none
SortList PROC

	; Setup the stack frame and save all registers
	push	ebp
	mov		ebp, esp
	pushad

	; Call the QuickSort procedure with the address of the array and the
	; start index, and end index. Start/End index are 0 based, thus why we're
	; subtracting 1 from the array size
	mov		eax, [ebp + 8]
	dec		eax

	push	[ebp + 12]
	push	0
	push	eax
	call	QuickSort

	; Clean up the stack frame and restore all the registers
	popad
	pop		ebp
	ret		8
SortList ENDP

; Procedure to swap two elements in a DWORD array
; Recieves: address of DWORD array to fill, index A, index B
; Returns: the elements in the array are swapped
; Preconditions: start/end index are within the bounds of the array
; Registers changed: none
SwapArrayElements PROC
	
	; Setup the stack frame and save all the registers
	push	ebp
	mov		ebp, esp
	pushad

	; Set the address of the array to edi
	mov		edi, [ebp + 16]
	
	; Move the index parameters to registers for indexing the array
	mov		ecx, [ebp + 12]
	mov		edx, [ebp + 8]

	; Move the values of the array into registers
	mov		eax, [edi + ecx * 4]
	mov		ebx, [edi + edx * 4]

	; Swap the elements of the array
	mov		[edi + ecx * 4], ebx
	mov		[edi + edx * 4], eax

	; Clean up the stack frame and restore all the registers
	popad
	pop		ebp
	ret		12
SwapArrayElements ENDP

; Procedure to put the pivot point, the last element, in the correct position
;	relative to the other elements, i.e. all elements greater
;	than or equal to the pivot are placed to the left of it and all
;	elements less than the pivot are placed to the right of it
; Recieves: address of DWORD array to fill, start index, end index, address of variable to
;	contain the index of the pivot
; Returns: the index of the pivot
; Preconditions: start/end index are within bounds of the array
; Registers changed: none
Partition PROC
	
	; Setup local variables and save all the registers
	LOCAL	pivot:DWORD
	LOCAL	pivotIndex:DWORD
	pushad

	; Store the address of the array to be sorted into esi
	mov		esi, [ebp + 20]

	; Use the ecx as the index counter, set it to starting index parameter
	mov		ecx, [ebp + 16]

	; Use edx as the end index
	mov		edx, [ebp + 12]

	; Set the pivot to first element in array, pivot index to start index
	mov		eax, [esi + edx * 4]
	mov		pivot, eax
	mov		pivotIndex, ecx

	; Loop over each element, for elements greater than or equal to the pivot
	; swap the element and the pivot index, increment the pivot index
begLoop:
	; Check if the current element is greater than or equal to the pivot
	; if so, swap the elements
	mov		eax, [esi + ecx * 4]
	cmp		eax, pivot
	jl		endSwap

	; Swap the pivot index and current elem
	push	esi			; address of the array
	push	ecx			; current index
	push	pivotIndex	; pivot index
	call	SwapArrayElements
	
	inc		pivotIndex
endSwap:
	inc		ecx
	cmp		ecx, edx
	jl		begLoop

	; Swap the pivot with the pivot index
	push	esi
	push	pivotIndex
	push	edx
	call	SwapArrayElements

	; Set the pivot index to the address of variable passed in
	mov		edi, [ebp + 8]
	mov		eax, pivotIndex
	mov		[edi], eax
	
	; Clean up the stack frame and restore all the registers
	popad
	ret		16
Partition ENDP

; Procedure to sort the array recursively using quickSort
; Recieves: address of DWORD array to fill, start index, end index
; Returns: array is sorted in descending order
; Preconditions: none
; Registers changed: none
QuickSort PROC

	; Setup local variables and save all the registers
	LOCAL	arrayAddress:DWORD
	LOCAL	lo:DWORD
	LOCAL	hi:DWORD
	LOCAL	pi:DWORD
	pushad

	; Initialize the local variables to passed in parameters
	mov		eax, [ebp + 16]
	mov		arrayAddress, eax

	mov		eax, [ebp + 12]
	mov		lo, eax

	mov		eax, [ebp + 8]
	mov		hi, eax

	; Only recursively call quickSort if lo < hi
	mov		eax, lo
	cmp		eax, hi
	jge		endSort

	; Get the address of the pi local variable
	mov		eax, ebp
	sub		eax, 16

	; Get the index of the pivot in the array
	push	arrayAddress
	push	lo
	push	hi
	push	eax
	call	Partition

	; Call quickSort with lo and pi - 1
	mov		eax, pi
	dec		eax

	push	arrayAddress
	push	lo
	push	eax
	call	QuickSort

	; Call quickSort with pi + 1 and hi
	mov		eax, pi
	inc		eax

	push	arrayAddress
	push	eax
	push	hi
	call	QuickSort

endSort:
	; Clean up the stack frame and restore all the registers
	popad
	ret		12
QuickSort ENDP

; Procedure to calculate and display the median of the array
; Recieves: address of DWORD array to fill, array size, medianMsg is a global variable
; Returns: none
; Preconditions: the array is sorted in descending order
; Registers changed: none
DisplayMedian PROC

	; Setup local variables and save all the registers
	LOCAL	median:DWORD
	LOCAL	divisor:REAL4
	pushad

	; Move the address of the array to esi
	mov		esi, [ebp + 12]

	; Display the median message
	mov		edx, OFFSET medianMsg
	call	WriteString

	; Move 2 into divisor so we can use it to divide the FPU
	mov		divisor, 2

	; Calculate the middle index of the array where the median will be
	mov		eax, [ebp + 8]		; Move array size to eax for division
	mov		ebx, 2
	cdq
	div		ebx
	mov		ecx, eax			; Move median index to ecx

	; Initialize the FPU and push value in array to the FPU stack
	FINIT
	FILD	DWORD PTR [esi + ecx * 4]

	; If there is a remainder of 0, it means that the array has an even number of
	; elements, so we need to add the 2 middle elements and average them, rounded to nearest
	; integer to get the median
	cmp		edx, 0
	jne		showMedian

	; Descrement ecx to the previous index in the array and push the value to the FPU stack
	dec		ecx
	FILD	DWORD PTR [esi + ecx * 4]

	; Add the two values in the FPU stack together and divide them by 2 to get the average
	FADD
	FILD	divisor
	FDIV

	; Display the median
showMedian:
	; Round the median in the FPU stack to nearest integer and store it into median
	FIST	median

	; Display the median
	mov		eax, median
	call	WriteDec
	mov		edx, OFFSET periodChar
	call	WriteString
	call	CrLf
	call	CrLf

	; Clean up the stack frame and restore all the registers
	popad
	ret		8
DisplayMedian ENDP

; Procedure to display a message and an array
; Recieves: address of DWORD array to display, array size, address of message to display, numPaddingMsg is a global variable
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
	call	CrLf

	; Restore all the registers
	popad
	ret		12
DisplayList ENDP

END main
