.global oneOperand

oneOperand:
	CMP R10, #0b00100000 ;@check if bits are 10 for register operand
	BLEQ regfetch
	MOVEQ R0, R11
	CMP R10, #0b00010000 ;@check if bits are 01 for 8bit constant
	BLEQ bytefetch
	MOVEQ R0, R11
	CMP R10, #0 ;@check if bits are 00 for 16bit constant
	BLEQ halfwordfetch
	MOVEQ R0, R11
	PUSH {R12}
	MOV R12, #1
	STRB R12, [R9, #30] ;@store operand count
	MOV R12, R8
	CMP R12, #0x0
	BEQ JZ
	CMP R12, #0x1
	BEQ GET_SIBLING
	CMP R12, #0x2
	BEQ GET_CHILD
	CMP R12, #0x3
	BEQ GET_PARENT
	CMP R12, #0x4
	BEQ GET_PROP_LEN
	CMP R12, #0x5
	BEQ INC
	CMP R12, #0x6
	BEQ DEC
	CMP R12, #0x7
	BEQ PRINT_ADDR
	CMP R12, #0x8
	BEQ CALL_IS
	CMP R12, #0x9
	BEQ REMOVE_OBJ
	CMP R12, #0xA
	BEQ PRINT_OBJ
	CMP R12, #0xB
	BEQ RET
	CMP R12, #0xC
	BEQ JUMP
	CMP R12, #0xD
	BEQ PRINT_PADDR
	CMP R12, #0xE
	BEQ crash
	CMP R12, #0xF
	BEQ CALL_IN

JZ:
	B crash

GET_SIBLING:
	B crash

GET_CHILD:
	B crash

GET_PARENT:
	B crash

GET_PROP_LEN:
	B crash

INC:
	B crash

DEC:
	B crash

PRINT_ADDR:
	B crash

CALL_IS:
	B crash

REMOVE_OBJ:
	B crash

PRINT_OBJ:
	B crash

RET:
	STRB R0, [R9, #46]
	LSR R0, #8
	STRB R0, [R9, #45]
	BL Zreturn
	B decode_instructions_loop

JUMP:
	B crash

PRINT_PADDR:
	B crash


CALL_IN:
	B crash




