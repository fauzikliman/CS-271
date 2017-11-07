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

MIN_ARRAY_SIZE = 10
MAX_ARRAY_SIZE = 200

MIN_ARRAY_NUM = 100
MAX_ARRAY_NUM = 999

.data

introMsg			BYTE	"Sorting Random Integer", 9, 9, 9, "Programmed by Road Runner", 10, 13,
							"This program generates random numbers in the range [100 .. 999],", 10, 13,
							"displays the original list, sorts the list, and calculates the", 10, 13,
							"median value. Finally, it displays the list sorted in descending order.", 10, 13, 10, 13, 0
arraySizePrompt		BYTE	"How many numbers should be generated? [10 .. 200]: ", 0
invalidInputMsg		BYTE	"Invalid input", 10, 13, 0
periodChar			BYTE	".", 0
unsortedArrayMsg	BYTE	"The unsorted random numbers:", 10, 13, 0
sortedArrayMsg		BYTE	"The sorted list:", 10, 13, 0
medianMsg			BYTE	"The median is ", 0

arraySize			DWORD	0

.code

main PROC

	; Introduce the program and program info to user
	push	OFFSET arraySize
	call	Introduction

	; Get the amount numbers to sort from the user
	call	GetData

	; Generate amount of numbers specified by user randomly
	call	FillArray

	; Display the unsorted array to the user
	call	DisplayList

	; Sort the array
	call	SortList

	; Display the median of the array
	call	DisplayMedian

	; Display the sorted array to the user
	call	DisplayList

	exit	; exit to operating system
main ENDP

; Procedure to display the program name and various information about it
; Recieves: introMsg is a global variable
; Returns: none
; Preconditions: none
; Registers changed: none
Introduction PROC
	mov		edx, OFFSET introMsg
	call	WriteString
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

; Generates an array with the amount of numbers the user entered.
FillArray PROC
	ret
FillArray ENDP

; Sorts the array
SortList PROC
	ret
SortList ENDP

; Displays the median of the array
DisplayMedian PROC
	mov		edx, OFFSET medianMsg
	call	WriteString
	ret
DisplayMedian ENDP

; Displays the array
DisplayList PROC
	ret
DisplayList ENDP

END main
