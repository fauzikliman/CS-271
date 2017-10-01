TITLE Elementary Arithmetic     (elementary-arithmetic.asm)

; Author: Fauzi Kliman
; OSU Email: klimanf@oregonstate.edu
; Class number and section: CS271-001
; Assignment Number: 1
; Assignment Due Date: 10/01/17 11:59pm

; Course / Project ID : Elementary Arithmetic                 Date: 9/24/17
; Description: This program will introduce the programmer, get two numbers
;	from the user, and calculate the sum, difference, product, quotient 
;	and remainder of the numbers, and report the result

INCLUDE Irvine32.inc

.data
	num1				SDWORD	?
	num2				SDWORD	?
	sum					SDWORD	?
	difference			SDWORD	?
	product				SDWORD	?
	quotient			SDWORD	?
	remainder			SDWORD	?

	intro				BYTE	"Hello, my name is Fauzi Kliman and this is the Elementary Arithmetic program!", 0
	outro				BYTE	"Neato! Cya later!", 0
	programInfo			BYTE	"This program will ask for two numbers to calculate their sum, difference, product, quotient, and remainder!", 0
	numberPrompt1		BYTE	"Enter the first number: ", 0
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
	ec4Display			BYTE	"**EC: Program handles negative inputs/results.", 0
	num1LessDisplay		BYTE	"The second number must be less than the first!", 0
	divideByZeroDisplay	BYTE	"You can't divide by 0!", 0
	quitPrompt			BYTE	"Enter 1 to quit: ", 0
	quotientPadding		BYTE	"0", 0
	decimal				BYTE	".", 0
	numToQuit			DWORD	1
	divPrecision		DWORD	1000
	fractional			SDWORD	?

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
	mov		edx, OFFSET ec4Display
	call	WriteString
	call	CrLf

; Prompt user for two numbers
numberPrompt:
	call	CrLf
	mov		edx, OFFSET numberPrompt1
	call	WriteString
	call	ReadInt
	mov		num1, eax
	mov		edx, OFFSET numberPrompt2
	call	WriteString
	call	ReadInt
	mov		num2, eax

; Make sure we don't try to divide by 0
	cmp		eax, 0
	jne		checkNum2Smaller
	call	CrLf
	mov		edx, OFFSET divideByZeroDisplay
	call	WriteString
	call	CrLf
	jmp		numberPrompt

; Verify second number is less than the first one
checkNum2Smaller:
	mov		eax, num1
	cmp		eax, num2
	jg		num2Smaller
	call	CrLf
	mov		edx, OFFSET num1LessDisplay
	call	WriteString
	call	CrLf
	jmp		numberPrompt

; Calculate the sum, differece, product, quotient, and remainder
num2Smaller:
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
	idiv		num2
	mov		quotient, eax
	mov		remainder, edx

	; Quotient as floating-point number
	;	To get a fractional number I mulitply the remainder by 1000 since we
	;	want the precision to the thousandths place and divide that number
	;	by the divisor, in this case num2. The quotient of that division
	;	will then be the fractional part. To handle rounding, multiply
	;	the remainder from the previous division by 10 and divide that
	;	by the divisor (num2), if the result is >= 5 then increment the
	;	fractional by 1
	;
	;	Example with precision to tenths place for cleaner numbers
	;		num1=555, num2=100
	;		quotient = 555 / 100 = 5
	;		remainder = 9 % 8 = 55
	;		fractional = (55 * 10) / 100 = 55
	;		fractionalRemainder = (55 * 10) % 100 = 50
	;		
	;		(50 * 10) / 100 = 5, which is >= 5 thus add 1 to fractional
	;
	;		fractional = 56
	mov		eax, remainder
	cmp		eax, 0
	jge		afterRemainderNeg
	neg		eax
afterRemainderNeg:
	mov		ecx, num2
	cmp		ecx, 0
	jge		afterNum2Neg
	neg		ecx
afterNum2Neg:
	mul		divPrecision
	cdq
	div		ecx
	mov		fractional, eax
	; Multiply the remainder of the fractional by 10 and divide it by the
	; divisor (num2) to check if its less than 5, otherwise round fractional by
	; adding 1
	mov		eax, edx
	mov		ebx, 10
	mul		ebx
	cdq
	div		ecx
	cmp		eax, 5 ; eax is (((remainder * divPrecision) % num2) * 10) / num2
	jl		afterRounding
	inc		fractional
afterRounding:

; Display the results
	call	CrLf

	; Sum
	mov		eax, num1
	call	WriteInt
	mov		edx, OFFSET sumDisplay
	call	WriteString
	mov		eax, num2
	call	WriteInt
	mov		edx, OFFSET equalsDisplay
	call	WriteString
	mov		eax, sum
	call	WriteInt
	call	CrLf

	; Difference
	mov		eax, num1
	call	WriteInt
	mov		edx, OFFSET differenceDisplay
	call	WriteString
	mov		eax, num2
	call	WriteInt
	mov		edx, OFFSET equalsDisplay
	call	WriteString
	mov		eax, difference
	call	WriteInt
	call	CrLf

	; Product
	mov		eax, num1
	call	WriteInt
	mov		edx, OFFSET productDisplay
	call	WriteString
	mov		eax, num2
	call	WriteInt
	mov		edx, OFFSET equalsDisplay
	call	WriteString
	mov		eax, product
	call	WriteInt
	call	CrLf

	; Quotient
	mov		eax, num1
	call	WriteInt
	mov		edx, OFFSET quotientDisplay
	call	WriteString
	mov		eax, num2
	call	WriteInt
	mov		edx, OFFSET equalsDisplay
	call	WriteString
	mov		eax, quotient
	call	WriteInt

	; Remainder
	mov		edx, OFFSET remainderDisplay
	call	WriteString
	mov		eax, remainder
	call	WriteInt
	call	CrLf

	; Fractional
	; Quotient
	mov		eax, num1
	call	WriteInt
	mov		edx, OFFSET quotientDisplay
	call	WriteString
	mov		eax, num2
	call	WriteInt
	mov		edx, OFFSET equalsDisplay
	call	WriteString
	mov		eax, quotient
	call	WriteInt
	mov		edx, OFFSET decimal
	call	WriteString

	; Add padded 0s
	; The idea behind the padded 0s is to first divide the divPrecision by 10
	; and if the fractional is less than that then to print a 0 and repeat
	; until divPrecision / 10 is equal to 1 or the fractional is greater
	; than or equal to divPrecision / 10
	;
	; For example, with a fractional value of 10 we want to print ".010"
	;	divPrecision / 10 = 100
	;	fractional < 100?
	;	print "0"
	;	(divPrecision / 10) / 10 = 10
	;	fractional < 10?
	;	print fractional
	mov		eax, divPrecision
	mov		ebx, 10
beginPadding:
	cdq
	div		ebx
	cmp		eax, fractional
	jle		endPadding
	cmp		eax, 1
	je		endPadding
	mov		edx, OFFSET quotientPadding
	call	WriteString
	jmp		beginPadding
endPadding:
	mov		eax, fractional
	call	WriteDec
	call	CrLf

; Ask user if they want to quit
	call	CrLf
	mov		edx, OFFSET	quitPrompt
	call	WriteString
	call	ReadInt
	cmp		eax, numToQuit
	jne		numberPrompt


; Say goodbye
	call	CrLf
	mov		edx, OFFSET outro
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP

END main
