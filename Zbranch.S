.global Zbranch

Zbranch: ;@branch byte comes in at R10 and condition comes in at R11
	PUSH {R10}
	AND R10, #0b10000000
	CMP R10, R11 ;@check if we should branch based on condition and 7th bit of branch byte
	POP {R10}
	MOVNE R15, R14 ;@exit if no branch
	TST R10, #0b01000000 ;@check if short branch or long branch
	AND R10, #0b00111111
	BNE Zshortbranch
	BEQ Zlongbranch
Zshortbranch:
	CMP R10, #0
	MOVEQ R10, #0
	PUSH {R14}
	BLEQ storereturn
	POP {R14}
	BEQ Zreturn
	CMP R10, #1
	MOVEQ R10, #1
	PUSH {R14}
	BLEQ storereturn
	POP {R14}
	BEQ Zreturn
	ADD R4, R10 ;@calculate new ZPC
	SUB R4, #2
	MOV R15, R14 ;@exit function
Zlongbranch:
	LDRB R11, [R7, R4] ;@load second branch byte
	ADD R4, #1 ;@inc ZPC
	LSL R10, #8 ;@multiply first branch byte by 256
	ADD R10, R11 ;@add bytes together
	MOV R12, #0b00100000
	LSL R12, #8
	TST R10, R12 ;@TST with 0b00100000 00000000 to do sign extension
	MOVNE R12, #0b11000000 ;@sign extend if signed
	LSLNE R12, #8
	ORRNE R10, R12
	MOVEQ R12, #00111111 ;@sign extend if unsigned
	LSLEQ R12, #8
	ANDEQ R10, R12
	MOV R12, #0b00100000
	LSL R12, #8
	TST R10, R12
	BNE signed
	ADD R4, R10
	ADD R4, #2
	MOV R15, R14 ;@exit Zbranch function
signed:
	MOV R12, #0b11111111
	LSL R12, #8
	ADD R12, #0b11111111
	EOR R10, R12
	ADD R10, #1
	SUB R4, R10
	SUB R4, #2
	MOV R15, R14 ;@exit Zbranch function

storereturn:
	STRB R10, [R9, #46] ;@store 0 as return value
	LSR R10, #8
	STRB R10, [R9, #45]
	MOV R15, R14
