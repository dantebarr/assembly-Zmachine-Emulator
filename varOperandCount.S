.global varOperandCount
.global print_num

varOperandCount:
	PUSH {R14}
	CMP R12, #0x1A
	BLEQ twobyteop
	CMP R12, #0xC
	BLEQ twobyteop
	POP {R14}
	MOV R12, #0 ;@reset var operand count
	;@store first operand
	AND R11, R10, #0b11000000 ;@extract bits 6-7 for comparison
	CMP R11, #0b11000000
	BEQ find_varfunc
	CMP R11, #0b10000000
	PUSHEQ {R11}
	PUSHEQ {R10}
	BLEQ regfetch
	POPEQ {R10}
	MOVEQ R0, R11
	POPEQ {R11}
	CMP R11, #0b01000000
	PUSHEQ {R11}
	BLEQ bytefetch
	MOVEQ R0, R11
	POPEQ {R11}
	CMP R11, #0b00000000
	BLEQ halfwordfetch
	MOVEQ R0, R11
	POPEQ {R11}
	ADD R12, #1 ;@increment var operand count
	;@store second operand
	AND R11, R10, #0b00110000 ;@extract bit 4-5 for comparison
	CMP R11, #0b00110000
	BEQ find_varfunc
	CMP R11, #0b00100000
	PUSHEQ {R11}
	PUSHEQ {R10}
	BLEQ regfetch
	POPEQ {R10}
	MOVEQ R1, R11
	POPEQ {R11}
	CMP R11, #0b00010000
	PUSHEQ {R11}
	BLEQ bytefetch
	MOVEQ R1, R11
	POPEQ {R11}
	CMP R11, #0b00000000
	BLEQ halfwordfetch
	MOVEQ R1, R11
	POPEQ {R11}
	ADD R12, #1 ;@increment var operand count
	;@store third operand
	AND R11, R10, #0b00001100 ;@extract bit 2-3 for comparison
	CMP R11, #0b00001100
	BEQ find_varfunc
	CMP R11, #0b00001000
	PUSHEQ {R10,R11}
	BLEQ regfetch
	BLEQ storeop3
	POPEQ {R11}
	CMP R11, #0b00000100
	PUSHEQ {R11}
	BLEQ bytefetch
	BLEQ storeop3
	POPEQ {R11}
	CMP R11, #0b00000000
	BLEQ halfwordfetch
	BLEQ storeop3
	POPEQ {R10,R11}
	ADD R12, #1 ;@increment var operand count
	;@store fourth operand
	AND R11, R10, #0b00000011 ;@extract bit 0-1 for comparison
	CMP R11, #0b00000011
	BLEQ find_varfunc
	CMP R11, #0b00000010
	PUSHEQ {R11}
	PUSHEQ {R10}
	BLEQ regfetch
	POPEQ {R10}
	BLEQ storeop4
	POPEQ {R11}
	CMP R11, #0b00000001
	PUSHEQ {R11}
	BLEQ bytefetch
	BLEQ storeop4
	POPEQ {R11}
	CMP R11, #0b00000000
	BLEQ halfwordfetch
	BLEQ storeop4
	POPEQ {R11}
	ADD R12, #1 ;@increment var operand count
	;@check if there are more operands
	POP {R11} ;@pop value of R12(instruction byte) into R11-----------------------------
	PUSH {R11} ;@push R11 to be popped as R12 later
	CMP R11, #0x1A
	BNE find_varfunc
	CMP R11, #0xC
	BNE find_varfunc
	LDRB R10, [R9, #35]
	;@store fifth operand
	AND R11, R10, #0b11000000 ;@extract bit 0-1 for comparison
	CMP R11, #0b11000000
	BEQ find_varfunc
	CMP R11, #0b10000000
	PUSHEQ {R11}
	PUSHEQ {R10}
	BLEQ regfetch
	POPEQ {R10}
	BLEQ storeop4
	POPEQ {R11}
	CMP R11, #0b01000000
	PUSHEQ {R11}
	BLEQ bytefetch
	BLEQ storeop4
	POPEQ {R11}
	CMP R11, #0b00000000
	BLEQ halfwordfetch
	BLEQ storeop5
	POPEQ {R11}
	ADD R12, #1 ;@increment var operand count
	;@store sixth operand
	AND R11, R10, #0b00110000 ;@extract bit 0-1 for comparison
	CMP R11, #0b00110000
	BEQ find_varfunc
	CMP R11, #0b00100000
	PUSHEQ {R11}
	PUSHEQ {R10}
	BLEQ regfetch
	POPEQ {R10}
	BLEQ storeop4
	POPEQ {R11}
	CMP R11, #0b00010000
	PUSHEQ {R11}
	BLEQ bytefetch
	BLEQ storeop4
	POPEQ {R11}
	CMP R11, #0b00000000
	BLEQ halfwordfetch
	BLEQ storeop6
	POPEQ {R11}
	ADD R12, #1 ;@increment var operand count
	;@store seventh operand
	AND R11, R10, #0b00001100 ;@extract bit 0-1 for comparison
	CMP R11, #0b00001100
	BEQ find_varfunc
	CMP R11, #0b00001000
	PUSHEQ {R11}
	PUSHEQ {R10}
	BLEQ regfetch
	POPEQ {R10}
	BLEQ storeop4
	POPEQ {R11}
	CMP R11, #0b00000100
	PUSHEQ {R11}
	BLEQ bytefetch
	BLEQ storeop4
	POPEQ {R11}
	CMP R11, #0b00000000
	BLEQ halfwordfetch
	BLEQ storeop7
	POPEQ {R11}
	ADD R12, #1 ;@increment var operand count
	;@store eighth operand
	AND R11, R10, #0b00000011 ;@extract bit 0-1 for comparison
	CMP R11, #0b00000011
	BEQ find_varfunc
	CMP R11, #0b00000010
	PUSHEQ {R11}
	PUSHEQ {R10}
	BLEQ regfetch
	POPEQ {R10}
	BLEQ storeop4
	POPEQ {R11}
	CMP R11, #0b00000001
	PUSHEQ {R11}
	BLEQ bytefetch
	BLEQ storeop4
	POPEQ {R11}
	CMP R11, #0b00000000
	BLEQ halfwordfetch
	BLEQ storeop8
	POPEQ {R11}
	ADD R12, #1 ;@increment var operand count
find_varfunc:
	STRB R12, [R9, #30] ;@store var operand count for later
	AND R12, R8, #0b00011111
	CMP R12, #0x0
	BEQ CALL_VS
	CMP R12, #0x1
	BEQ STOREW
	CMP R12, #0x2
	BEQ STOREB
	CMP R12, #0x3
	BEQ PUT_PROP
	CMP R12, #0x4
	BEQ READ
	CMP R12, #0x5
	BEQ PRINT_CHAR
	CMP R12, #0x6
	BEQ PRINT_NUM
	CMP R12, #0x7
	BEQ RANDOM
	CMP R12, #0x8
	BEQ PUSH
	CMP R12, #0x9
	BEQ PULL
	CMP R12, #0xA
	BEQ SPLIT_WINDOW
	CMP R12, #0xB
	BEQ SET_WINDOW
	CMP R12, #0xC
	BEQ CALL_VS2
	CMP R12, #0xD
	BEQ ERASE_WINDOW
	CMP R12, #0xE
	BEQ ERASE_LINE
	CMP R12, #0xF
	BEQ SET_CURSOR
	CMP R12, #0x10
	BEQ GET_CURSOR
	CMP R12, #0x11
	BEQ SET_TEXT_STYLE
	CMP R12, #0x12
	BEQ BUFFER_MODE
	CMP R12, #0x13
	BEQ OUTPUT_STREAM
	CMP R12, #0x14
	BEQ INPUT_STREAM
	CMP R12, #0x15
	BEQ SOUND_EFFECT
	CMP R12, #0x16
	BEQ READ_CHAR
	CMP R12, #0x17
	BEQ SCAN_TABLE
	CMP R12, #0x18
	BEQ NOT
	CMP R12, #0x19
	BEQ CALL_VN
	CMP R12, #0x1A
	BEQ CALL_VN2
	CMP R12, #0x1B
	BEQ TOKENIZE
	CMP R12, #0x1C
	BEQ ENCODE_TEXT
	CMP R12, #0x1D
	BEQ COPY_TABLE
	CMP R12, #0x1E
	BEQ PRINT_TABLE
	CMP R12, #0x1F
	BEQ CHECK_ARG_COUNT
	
CALL_VS:
	B crash

STOREW:
	B crash

STOREB:
	B crash

PUT_PROP:
	B crash

READ:
	B crash

PRINT_CHAR:
	LDR R10, =0xE000102C ;@set R10 to value of transmission FIFO
	LDR R11, [R10] ;@load value of FIFO
	TST R11, #0b00001000 ;@test bit 3
	BEQ PRINT_CHAR ;@if bit is not set then delay
	LDR R10, =0xE0001030
	STR R0, [R10]
	B decode_instructions_loop
	
PRINT_NUM:
	LDR R8, =0x8000
	TST R0, R8
	LDR R8, =0xffff
	LSL R8, #16
	ORRNE R0, R8
	BL print_num
	MOV R8, #0
	LDR R10, =0xE0001030 ;@load UART write location
	LDRB R1, [R0, R8]
	ADD R8, #1
print_num_loop:
	LDRB R11, [R0, R8] ;@load in value of first ascii character
	STRB R11, [R10] ;@store ascii character to UART
	PUSH {R10} ;@push R10
delay:
	LDR R10, =0xE000102C ;@set R10 to value of transmission FIFO
	LDR R11, [R10] ;@load value of FIFO
	TST R11, #0b00001000 ;@test bit 3
	BEQ delay ;@if bit is not set then delay
	POP {R10} ;@pop location of UART write location again
	CMP R8, R1 ;@check if last character was printed
	ADDNE R8, #1 ;@increment counter
	BNE print_num_loop
	BEQ decode_instructions_loop

RANDOM:
	B crash

PUSH:
	MOV R11, R0
	BL stackstore
	B decode_instructions_loop

PULL:
	BL stackfetch
	MOV R10, R11
	MOV R11, R0
	MOV R12, R10
	BL regstore
	B decode_instructions_loop

SPLIT_WINDOW:
	B crash

SET_WINDOW:
	B crash

CALL_VS2:
	B crash

ERASE_WINDOW:
	B crash

ERASE_LINE: ;@Func should not occur
	B crash

SET_CURSOR:
	B crash

GET_CURSOR: ;@Func should not occur
	B crash

SET_TEXT_STYLE:
	B crash

BUFFER_MODE: ;@Func should not occur
	B crash

OUTPUT_STREAM:
	B crash

INPUT_STREAM:
	B crash

SOUND_EFFECT: ;@Func should not occur
	B crash

READ_CHAR:
	B crash

SCAN_TABLE:
	B crash

NOT:
	B crash

CALL_VN:
	B crash

CALL_VN2:
	B crash

TOKENIZE:
	B crash

ENCODE_TEXT: ;@Func should not occur
	B crash
	
COPY_TABLE: ;@Func should not occur
	B crash

PRINT_TABLE: ;@Func should not occur
	B crash

CHECK_ARG_COUNT:
	B crash
	
storeop3:
	PUSH {R12} ;@store operand in variable operand space
	LDR R12, [R9, #25]
	PUSH {R11}
	LSR R11, #8
	STRB R11, [R12]
	POP {R11}
	STRB R11, [R12, #1]
	POP {R12}
	MOV R15, R14
storeop4:
	PUSH {R12} ;@store operand in variable operand space
	LDR R12, [R9, #25]
	PUSH {R11}
	LSR R11, #8
	STRB R11, [R12, #2]
	POP {R11}
	STRB R11, [R12, #3]
	POP {R12}
	MOV R15, R14
storeop5:
	PUSH {R12} ;@store operand in variable operand space
	LDR R12, [R9, #25]
	PUSH {R11}
	LSR R11, #8
	STRB R11, [R12, #4]
	POP {R11}
	STRB R11, [R12, #5]
	POP {R12}
	MOV R15, R14
storeop6:
	PUSH {R12} ;@store operand in variable operand space
	LDR R12, [R9, #25]
	PUSH {R11}
	LSR R11, #8
	STRB R11, [R12, #6]
	POP {R11}
	STRB R11, [R12, #7]
	POP {R12}
	MOV R15, R14
storeop7:
	PUSH {R12} ;@store operand in variable operand space
	LDR R12, [R9, #25]
	PUSH {R11}
	LSR R11, #8
	STRB R11, [R12, #8]
	POP {R11}
	STRB R11, [R12, #9]
	POP {R12}
	MOV R15, R14
storeop8:
	PUSH {R12} ;@store operand in variable operand space
	LDR R12, [R9, #25]
	PUSH {R11}
	LSR R11, #8
	STRB R11, [R12, #10]
	POP {R11}
	STRB R11, [R12, #11]
	POP {R12}
	MOV R15, R14

twobyteop:
	PUSH {R12}
	LDRB R12, [R7, R4] ;@get next operand indicator byte
	ADD R4, #1
	STRB R12, [R9, #40] ;@save operand indicator byte in personal memory
	POP {R12}
	MOV R15, R14






