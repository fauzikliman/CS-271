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

	; Data for extra credit related
	ec1Display			BYTE	"**EC: Program repeats until user chooses to quit.", 0
	ec2Display			BYTE	"**EC: Program verifies second number less than first.", 0
	ec3Display			BYTE	"**EC: Program calculates and displays the quotient as floating-point number rounded to nearest .001.", 0
	num1LessDisplay		BYTE	"The second number must be less than the first!", 0
	quitPrompt			BYTE	"Enter 1 to quit: ", 0
	quotientPadding		BYTE	"0", 0
	decimal				BYTE	".", 0
	numToQuit			DWORD	1
	divPrecision		DWORD	1000
	fractional			DWORD	?
	fractionalRemainder	DWORD	?

.code
main PROC

; Introduce programmer, program title, extra credit options, and instructions for user
	mov		edx, OFFSET intro
	call	WriteString
	call	CrLf
	mov		edx, OFFSET programInfo
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec1Display
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec2Display
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec3Display
	call	WriteString
	call	CrLf

; Prompt user for two numbers
numberPrompt:
	mov		edx, OFFSET numberPrompt1
	call	WriteString
	call	ReadInt
	mov		num1, eax
	mov		edx, OFFSET numberPrompt2
	call	WriteString
	call	ReadInt
	mov		num2, eax

; Verify second number is less than the first one
	mov		eax, num1
	cmp		eax, num2
	jge		num2Less
	mov		edx, OFFSET num1LessDisplay
	call	WriteString
	call	CrLf
	jmp		goodbye

; Calculate the sum, differece, product, quotient, and remainder
num2Less:
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

	; Quotient as floating-point number
	;	To get a fractional number I mulitply the remainder by 1000 since we
	;	want the precision to the thousandths place and divide that number
	;	by the divisor, in this case num2. The quotient of that division
	;	will then be the fractional part. To handle rounding, increment
	;	the fractional by 1 if the remainder of the fractional 
	;	is greater than or equal to half the divisor, if the divisor is
	;	an odd number then we need to compare with half the divisor + 1
	;
	;	Example with precision to tenths place for cleaner numbers
	;		num1=555, num2=100
	;		quotient = 555 / 100 = 5
	;		remainder = 9 % 8 = 55
	;		fractional = (55 * 10) / 100 = 55
	;		fractionalRemainder = (55 * 10) % 100 = 50
	;		halfDivisor = 100 / 2 = 50
	;		
	;		divisor (100) odd?
	;		No, so do NOT add one to halfDivisor
	;
	;		fractionalRemainder >= halfDivisor?
	;		Yes so add 1 to fractional
	;
	;		fractional = 56
	mov		eax, remainder
	mul		divPrecision
	cdq
	div		num2
	mov		fractional, eax
	mov		fractionalRemainder, edx
	mov		eax, num2
	mov		ebx, 2
	cdq
	div		ebx
	cmp		edx, 0
	je		afterDivisor
	inc		eax
afterDivisor:
	cmp		fractionalRemainder, eax
	jl		afterRounding
	inc		fractional
afterRounding:

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

	; Fractional
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
	mov		edx, OFFSET decimal
	call	WriteString

	; Add padded 0s
	mov		eax, divPrecision
	mov		ebx, 10
beginPadding:
	cdq
	div		ebx
	cmp		eax, fractional
	jle		endPadding
	mov		edx, OFFSET quotientPadding
	call	WriteString
	jmp		beginPadding
endPadding:
	mov		eax, fractional
	call	WriteDec
	call	CrLf
	
; Ask user if they want to quit
	mov		edx, OFFSET	quitPrompt
	call	WriteString
	call	ReadInt
	cmp		eax, numToQuit
	jne		numberPrompt


; Say goodbye
goodbye:
	mov		edx, OFFSET outro
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP

END main
