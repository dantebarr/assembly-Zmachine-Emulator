.global noOperand

noOperand:
	CMP R12, #0x0
	BEQ RTRUE
	CMP R12, #0x1
	BEQ RFALSE
	CMP R12, #0x2
	BEQ PRINT
	CMP R12, #0x3
	BEQ PRINT_RET
	CMP R12, #0x4
	BEQ crash
	CMP R12, #0x5
	BEQ crash
	CMP R12, #0x6
	BEQ crash
	CMP R12, #0x7
	BEQ crash
	CMP R12, #0x8
	BEQ RET_POPPED
	CMP R12, #0x9
	BEQ crash
	CMP R12, #0xA
	BEQ crash
	CMP R12, #0xB
	BEQ NEW_LINE
	CMP R12, #0xC
	BEQ crash
	CMP R12, #0xD
	BEQ VERIFY
	CMP R12, #0xE
	;@extended opcode--not sure what to do
	CMP R12, #0xF
	BEQ crash
	
RTRUE:
	B crash
RFALSE:
	B crash
PRINT:
	LDR R10, =0xE000102C ;@set R10 to value of transmission FIFO
	LDR R11, [R10] ;@load value of FIFO
	TST R11, #0b00001000 ;@test bit 3
	BEQ PRINT ;@if bit is not set then delay
	LDR R12, =0xE0001030
	PUSH {R11}
	LDRB R10, [R7, R4] ;@load in first byte
	ADD R4, #1
	LSL R10, #8 ;@Find eight most significant
	LDRB R11, [R7, R4] ;@load in second byte
	ADD R4, #1
	ADD R10, R11 ;@Add most significant 8 bits and least significant 8 bits together
	POP {R11}
	LSR R11, R10, #10 ;@shift right by 10
	AND R11, #0b11111 ;@get rid of stop bit
	CMP R11, #0 ;@check if space char
	MOVEQ R11, #32 ;@ascii for space
	STREQ R11, [R12]
	BEQ char2 ;@skip other compares go to next char
	CMP R11, #1 ;@check if new line char
	MOVEQ R11, #10
	STREQ R11, [R12]
	MOVEQ R11, #13
	STREQ R11, [R12]
	BEQ char2
	CMP R11, #6 ;@check if less than 6
	MOVMI R11, #63 ;@ascii for ?
	STRMI R11, [R12]
	BEQ char2
	CMP R11, #32 ;@check if greater than 31
	MOVPL R11, #63 
	STRPL R11, [R12]
	BEQ char2
	ADD R11, #91 ;@R11 is in range 6-31, add 91 to convert to ascii
	STR R11, [R12]
char2:
	LSR R11, R10, #5
	AND R11, #0b11111
	CMP R11, #0
	MOVEQ R11, #32
	STREQ R11, [R12]
	BEQ char3
	CMP R11, #1
	MOVEQ R11, #10
	STREQ R11, [R12]
	MOVEQ R11, #13
	STREQ R11, [R12]
	BEQ char3
	CMP R11, #6
	MOVMI R11, #63
	STRMI R11, [R12]
	BEQ char3
	CMP R11, #32
	MOVPL R11, #63
	STRPL R11, [R12]
	BEQ char3
	ADD R11, #91
	STR R11, [R12]
char3:
	MOV R11, R10
	AND R11, #0b11111
	CMP R11, #0
	MOVEQ R11, #32
	STREQ R11, [R12]
	BEQ check_stop
	CMP R11, #1
	MOVEQ R11, #10
	STREQ R11, [R12]
	MOVEQ R11, #13
	STREQ R11, [R12]
	BEQ check_stop
	CMP R11, #6
	MOVMI R11, #63
	STRMI R11, [R12]
	BEQ check_stop
	CMP R11, #32
	MOVPL R11, #63
	STRPL R11, [R12]
	BEQ check_stop
	ADD R11, #91
	STR R11, [R12]
check_stop:
	LSR R10, #15
	TST R10, #1
	BNE decode_instructions_loop
	BEQ PRINT
PRINT_RET:
	B crash
RET_POPPED:
	BL stackfetch
	STRB R11, [R9, #46]
	LSR R11, #8
	STRB R11, [R9, #45]
	BL Zreturn
	B decode_instructions_loop
NEW_LINE:
	B crash
VERIFY:
	MOV R10, #0x40 ;@set R10 to end of header
	LDR R11, =1999999 ;@size of Zmemory
	LDRB R12, [R7, #28] ;@verify halfword from header
	LDRB R8, [R7, #29]
	LSL R12, #8
	ADD R12, R8
	MOV R8, #0
	CMP R11, R10
	PUSH {R11}
	BLNE add_bytes
	CMP R8, R12
	LDRB R10, [R7, R4]
	ADD R4, #1
	MOVEQ R11, #0b10000000 ;@if condition is met
	MOVNE R11, #0 ;@if condition is not met
	BL Zbranch ;@branch
	B decode_instructions_loop
add_bytes:
	LDRB R11, [R7, R10]
	ADD R10, #1
	ADD R8, R11
	POP {R11}
	CMP R11, R10
	PUSH {R11}
	POPEQ {R11}
	BNE add_bytes
	MOV R15, R14




	








