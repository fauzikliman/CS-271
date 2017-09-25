TITLE Elementary Arithmetic     (elementary-arithmetic.asm)

; Author: Fauzi Kliman
; Course / Project ID : Elementary Arithmetic                 Date: 9/24/17
; Description: This program will introduce the programmer, get two numbers
;	from the user, and calculate the sum, difference, product, quotient 
;	and remainder of the numbers, and report the result

INCLUDE Irvine32.inc

.data
	num1				DWORD	?
	num2				DWORD	?
	sum					DWORD	?
	difference			DWORD	?
	product				DWORD	?
	quotient			DWORD	?
	remainder			DWORD	?

	intro				BYTE	"Hello, my name is Fauzi Kliman and this is the Elementary Arithmetic program!", 0
	outro				BYTE	"Neato! Cya later!", 0
	programInfo			BYTE	"This program will ask for two numbers to calculate their sum, difference, product, quotient, and remainder!", 0
	numberPrompt1		Byte	"Enter the first number: ", 0
	numberPrompt2		BYTE	"Enter the second number: ", 0
	sumDisplay			BYTE	" + ", 0
	differenceDisplay	BYTE	" - ", 0
	productDisplay		BYTE	" * ", 0
	quotientDisplay		BYTE	" / ", 0
	equalsDisplay		BYTE	" = ", 0
	remainderDisplay	BYTE	" remainder ", 0

.code
main PROC

; Introduce programmer, program title, and instructions for user
	mov		edx, OFFSET intro
	call	WriteString
	call	CrLf
	mov		edx, OFFSET programInfo
	call	WriteString
	call	CrLf

; Prompt user for two numbers
	mov		edx, OFFSET numberPrompt1
	call	WriteString
	call	ReadInt
	mov		num1, eax
	mov		edx, OFFSET numberPrompt2
	call	WriteString
	call	ReadInt
	mov		num2, eax

; Calculate the sum, differece, product, quotient, and remainder
	; Addition
	mov		eax, num1
	add		eax, num2
	mov		sum, eax
	
	; Subtraction
	mov		eax, num1
	sub		eax, num2
	mov		difference, eax

	; Multiplication
	mov		eax, num1
	mul		num2
	mov		product, eax

	; Quotient/Remainder
	mov		eax, num1
	cdq
	div		num2
	mov		quotient, eax
	mov		remainder, edx

; Display the results
	; Sum
	mov		eax, num1
	call	WriteDec
	mov		edx, OFFSET sumDisplay
	call	WriteString
	mov		eax, num2
	call	WriteDec
	mov		edx, OFFSET equalsDisplay
	call	WriteString
	mov		eax, sum
	call	WriteDec
	call	CrLf

	; Difference
	mov		eax, num1
	call	WriteDec
	mov		edx, OFFSET differenceDisplay
	call	WriteString
	mov		eax, num2
	call	WriteDec
	mov		edx, OFFSET equalsDisplay
	call	WriteString
	mov		eax, difference
	call	WriteDec
	call	CrLf

	; Product
	mov		eax, num1
	call	WriteDec
	mov		edx, OFFSET productDisplay
	call	WriteString
	mov		eax, num2
	call	WriteDec
	mov		edx, OFFSET equalsDisplay
	call	WriteString
	mov		eax, product
	call	WriteDec
	call	CrLf

	; Quotient
	mov		eax, num1
	call	WriteDec
	mov		edx, OFFSET quotientDisplay
	call	WriteString
	mov		eax, num2
	call	WriteDec
	mov		edx, OFFSET equalsDisplay
	call	WriteString
	mov		eax, quotient
	call	WriteDec

	; Remainder
	mov		edx, OFFSET remainderDisplay
	call	WriteString
	mov		eax, remainder
	call	WriteDec
	call	CrLf

; Say goodbye
	mov		edx, OFFSET outro
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP

END main
