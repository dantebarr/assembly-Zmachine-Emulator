.global twoOperand
.global divide
.global multiply
.global modulus

twoOperand:
	PUSH {R12}
	MOV R12, #2
	STRB R12, [R9, #30] ;@store operand count
	POP {R12}
	CMP R12, #0x0
	BEQ ILLEGAL_INSTRUCTION
	CMP R12, #0x1
	BEQ JE
	CMP R12, #0x2
	BEQ JL
	CMP R12, #0x3
	BEQ JG
	CMP R12, #0x4
	BEQ DEC_CHK
	CMP R12, #0x5
	BEQ INC_CHK
	CMP R12, #0x6
	BEQ JIN
	CMP R12, #0x7
	BEQ TEST
	CMP R12, #0x8
	BEQ OR
	CMP R12, #0x9
	BEQ AND
	CMP R12, #0xA
	BEQ TEST_ATTR
	CMP R12, #0xB
	BEQ SET_ATTR
	CMP R12, #0xC
	BEQ CLEAR_ATTR
	CMP R12, #0xD
	BEQ STORE
	CMP R12, #0xE
	BEQ INSERT_OBJ
	CMP R12, #0xF
	BEQ LOADW
	CMP R12, #0x10
	BEQ LOADB
	CMP R12, #0x11
	BEQ GET_PROP
	CMP R12, #0x12
	BEQ GET_PROP_ADDR
	CMP R12, #0x13
	BEQ GET_NEXT_PROP
	CMP R12, #0x14
	BEQ ADD
	CMP R12, #0x15
	BEQ SUB
	CMP R12, #0x16
	BEQ MUL
	CMP R12, #0x17
	BEQ DIV
	CMP R12, #0x18
	BEQ MOD
	CMP R12, #0x19
	BEQ CALL_2S
	CMP R12, #0x1A
	BEQ CALL_2N
	CMP R12, #0x1B
	BEQ SET_COLOUR
	CMP R12, #0x1C
	BEQ THROW
	CMP R12, #0xD
	BEQ ILLEGAL_INSTRUCTION
	CMP R12, #0xE
	BEQ ILLEGAL_INSTRUCTION
	CMP R12, #0xF
	BEQ ILLEGAL_INSTRUCTION
	
ILLEGAL_INSTRUCTION: ;@Func should not occur
	B crash

JE:
	LDRB R10, [R7, R4] ;@load branch byte
	ADD R4, #1 ;@inc ZPC
	CMP R0, R1 ;@condition statement
	MOVEQ R11, #0b10000000 ;@if condition is met
	MOVNE R11, #0 ;@if condition is not met
	BL Zbranch
	B decode_instructions_loop
JL:
	LDRB R10, [R7, R4] ;@load branch byte
	ADD R4, #1 ;@inc ZPC
	CMP R0, R1 ;@condition statement
	MOVMI R11, #0b10000000 ;@if condition is met
	MOVPL R11, #0 ;@if condition is not met
	BL Zbranch
	B decode_instructions_loop
JG:
	LDRB R10, [R7, R4] ;@load branch byte
	ADD R4, #1 ;@inc ZPC
	CMP R1, R0 ;@condition statement
	MOVMI R11, #0b10000000 ;@if condition is met
	MOVPL R11, #0 ;@if condition is not met
	BL Zbranch
	B decode_instructions_loop

DEC_CHK: ;@Func should not occur
	B crash 

INC_CHK: ;@Func should not occur
	B crash 

JIN:
	B crash

TEST: ;@Func should not occur
	B crash

OR:
	LDRB R11, [R7, R4] ;@get location of destination Zregister
	ADD R4, #1 ;@ inc ZPC
	ORR R12, R0, R1 ;@OR operands
	BL regstore
	B decode_instructions_loop

AND:
	LDRB R11, [R7, R4] ;@get location of destination Zregister
	ADD R4, #1 ;@ inc ZPC
	AND R12, R0, R1 ;@AND operands
	BL regstore
	B decode_instructions_loop

TEST_ATTR:
	PUSH {R0}
	LSL R10, R0, #4 ;@Multiply by 14
	POP {R0}
	LSL R0, #2
	SUB R0, R10, R0 ;@Multiplied by 14 here
	LSR R11, R1, #3 ;@ divide by 8 to see which flag byte we need
	ADD R0, R11 ;@add to offset to get appropriate byte
	LSL R11, #3 ;@multiply by 8 to discard low bits
	SUB R1, R11 ;@this will perform modulus on our bit form R1 so it is now the bit in our byte
	MOV R10, #0 ;@0 out R10 counter
	MOV R11, #0b10000000 ;@start number at far left bit
	CMP R1, #0 ;@if 0 then far left bit
	BLNE powloop

	LDR R10, [R9, #0]
	LDRB R10, [R10, R0]
	TST R10, R11 ;@condition statement
	MOVNE R11, #0b10000000 ;@if condition has been met
	MOVEQ R11, #0
	LDRB R10, [R7, R4] ;@load branch byte
	ADD R4, #1 ;@inc ZPC
	BL Zbranch


SET_ATTR:
	PUSH {R0}
	LSL R10, R0, #4 ;@Multiply by 14
	POP {R0}
	LSL R0, #2
	SUB R0, R10, R0 ;@Multiplied by 14 here
	LSR R11, R1, #3 ;@ divide by 8 to see which flag byte we need
	ADD R0, R11 ;@add to offset to get appropriate byte
	LSL R11, #3 ;@multiply by 8 to discard low bits
	SUB R1, R11 ;@this will perform modulus on our bit form R1 so it is now the bit in our byte
	MOV R10, #0 ;@0 out R10 counter
	MOV R11, #0b10000000 ;@start number at far left bit
	CMP R1, #0 ;@if 0 then far left bit
	BLNE powloop
	LDR R10, [R9, #0]
	LDRB R12, [R10, R0]
	ORR R12, R11
	STRB R12, [R10, R0]
	B decode_instructions_loop

CLEAR_ATTR:
	PUSH {R0}
	LSL R10, R0, #4 ;@Multiply by 14
	POP {R0}
	LSL R0, #2
	SUB R0, R10, R0 ;@Multiplied by 14 here
	LSR R11, R1, #3 ;@ divide by 8 to see which flag byte we need
	ADD R0, R11 ;@add to offset to get appropriate byte
	LSL R11, #3 ;@multiply by 8 to discard low bits
	SUB R1, R11 ;@this will perform modulus on our bit form R1 so it is now the bit in our byte
	MOV R10, #0 ;@0 out R10 counter
	MOV R11, #0b10000000 ;@start number at far left bit
	CMP R1, #0 ;@if 0 then far left bit
	BLNE powloop
	LDR R10, [R9, #0]
	LDRB R12, [R10, R0]
	EOR R11, #0b11111111
	AND R12, R11
	STRB R12, [R10, R0]
	B decode_instructions_loop

STORE:
	MOV R11, R0
	MOV R12, R1
	BL regstore ;@store value of R12 in designated register by R11
	B decode_instructions_loop

INSERT_OBJ:
	B crash

LOADW:
	B crash

LOADB:
	B crash

GET_PROP:
	B crash

GET_PROP_ADDR:
	B crash

GET_NEXT_PROP:
	B crash

ADD:
	LDRB R11, [R7, R4] ;@get register designator byte
	ADD R4, #1 ;@ inc ZPC
	ADD R12, R0, R1 ;@add operands
	BL regstore
	B decode_instructions_loop
SUB:
	LDRB R11, [R7, R4] ;@get register designator byte
	ADD R4, #1 ;@ inc ZPC
	SUB R12, R0, R1 ;@subtract operands
	BL regstore
	B decode_instructions_loop
MUL:
	LDRB R11, [R7, R4] ;@get register designator byte
	ADD R4, #1 ;@ inc ZPC
	BL multiply ;@multiply operands
	MOV R12, R0
	BL regstore
	B decode_instructions_loop
DIV:
	LDRB R11, [R7, R4] ;@get register designator byte
	ADD R4, #1 ;@ inc ZPC
	BL divide ;@divide operands
	MOV R12, R0
	BL regstore
	B decode_instructions_loop

MOD:
	LDRB R11, [R7, R4] ;@get register designator byte
	ADD R4, #1 ;@ inc ZPC
	BL modulus ;@divide operands
	MOV R12, R0
	BL regstore
	B decode_instructions_loop

CALL_2S:
	LDRB R8, [R7, R4]
	ADD R4, #1
	STRB R8, [R9, #36]
	MOV R8, #0
	STRB R8, [R9, #35]
	B Zcall
	B decode_instructions_loop

CALL_2N:
	LDR R8, =0xffff
	PUSH {R8}
	LSR R8, #8
	STRB R8, [R9, #35]
	POP {R8}
	STRB R8, [R9, #36]
	B Zcall
	B decode_instructions_loop

SET_COLOUR:
	B crash

THROW: ;@Func should not occur
	B crash
	

powloop:
	LSR R11, #1
	ADD R10, #1
	CMP R10, R1
	MOVMI R15, R14
	BPL powloop




	
