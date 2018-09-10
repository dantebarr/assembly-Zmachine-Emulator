.global asm_main
.global decode_instructions_loop
.global hex_ascii_converter16
.global hex_ascii_converter1
.global zerozreg
.global upload

.align 4
Zmemory: .space 2000000 ;@set local Zregisters
.align 4
Zstack: .space 1000000
.align 4
Zregisters: .space 1000000
.align 4
Zoperands: .space 256
.align 4
personal: .space 2000000
.align 4

;@Switches 0x41220000
;@UART transmitter and reciever 0xE0001030 - location to write
;@UART transmitter and reciever FIFO 0xE000102C
;@do we ever need to go back to upload mode from run mode
;@CALLS - set of Zregisters you are given?(local or global)
;@why is 0xffff less than 0x0000


asm_main:
	LDR R9, =personal ;@set R9 to location of personal memory
	LDR R7, =Zregisters
	STR R7, [R9, #10]
	LDR R7, =Zstack
	STR R7, [R9, #20] ;@save location of Zstack
	LDR R7, =Zoperands
	STR R7, [R9, #25] ;@save location of variable operand space
	LDR R7, =Zmemory ;@places Zmemory location in R7
	LDR R0, =0x20 ;@sets up the UART for incoming transmission
	LDR R1, =0xE0001004
	STR R0, [R1]
	LDR R0, =62
	LDR R1, =0xE0001018
	STR R0, [R1]
	LDR R0, =6
	LDR R1, =0xE0001034
	STR R0, [R1]
	LDR R0, =0x117
	LDR R1, =0xE0001000
	STR R0, [R1]

upload:
	BL zerozmem
	BL zerozstack
	BL zerozreg
	MOV R8, #0 ;@reset upload pointer
	LDR R0, =0xE0001030 ;@load write location of transmitter reciever
	LDR R1, =0x41220000 ;@load location of switches
	LDR R10, =0xE000102C ;@load location of FIFO
	LDRB R2, [R1] ;@load switch value to r2
	STRB R2, [R9] ;@initialize switch compare value
upload_loop:
	LDRB R2, [R1] ;@get current value of switches
	LDRB R3, [R9] ;@loads old switch value
	CMP R2, R3 ;@if switches changed
	BLNE bounce ;@bounce back loop
	STRB R2, [R9] ;@set current switch value to old in personal memory
	TST R3, #0b10000000 ;@if switch 7 is up
	BEQ run ;@change to run mode
	LDR R3, [R10] ;@load data at location of FIFO
	TST R3, #0b00000010 ;@check if reciever FIFO is empty
	BNE upload_loop ;@if empty branch back to top of loop
	LDRB R2, [R0] ;@load current reciever data byte
	STRB R2, [R7, R8] ;@Store Zinstruction in Zmem
	ADD R8, #1 ;@increment Zmemory pointer
	B upload_loop

run:
	LDR R1, =0x41220000 ;@load location of switches
	LDRB R2, [R1] ;@load switch value to r2
	TST R2, #0b01000000 ;@check if 6th switch is up
	BLEQ headermode
	BLNE noheadermode
	MOV R5, #0 ;@initialize Z-stack pointer to 0
	MOV R6, #0 ;@initialize nesting depth to 0
decode_instructions_loop:
	LDR R1, =0x41220000 ;@load location of switches
	LDRB R2, [R1] ;@load switch value to r2
	TST R2, #0b10000000 ;@check if 7th switch is up
	BNE upload
	LDRB R8, [R7,R4] ;@fetch Zcode instruction from Zmem at ZPC
	TST R2, #0b00100000 ;@check if 5th switch is up
	BLNE debug_mode
	STR R4, [R9, #15] ;@store ZPC value at initial instruction fetch
	ADD R4, #1 ;@increment ZPC
	AND R10, R8, #0b11000000
	CMP R10, #0b10000000
	BEQ typeA
	CMP R10, #0b11000000
	BEQ typeC
	BNE typeB

typeA:
	AND R12, R8, #0b00001111 ;@extract instruction indicator - bits 3-0
	PUSH {R12}
	AND R10, R8, #0b00110000 ;@extract operand count indicator - bits 5-4
	CMP R10, #0b00110000 ;@check operands
	POP {R12}
	BEQ noOperand ;@if no operands
	BNE oneOperand ;@if one operand fetch
typeB:
	AND R12, R8, #0b00011111 ;@extract instruction indicator - bits 4-0
	PUSH {R12}
	AND R10, R8, #0b01100000 ;@extract operand count indicator - bit 6-5
	PUSH {R10}
	TST R10, #0b01000000 ;@test 6th bit
	BLNE regfetch ;@if 6th bit is set
	BLEQ bytefetch ;@if 6th bit is not set
	MOV R0, R11
	POP {R10}
	TST R10, #0b00100000 ;@test 5th bit
	BLNE regfetch ;@if 5th bit is set
	BLEQ bytefetch ;@if 5th bit is not set
	MOV R1, R11
	POP {R12}
	B twoOperand
typeC:
	AND R12, R8, #0b00011111 ;@extract instruction indicator - bits 4-0
	PUSH {R12}
	AND R10, R8, #0b00100000 ;@extract operand count indicator - bit 5
	CMP R10, #0b00100000 ;@check operands
	LDRB R10, [R7, R4]
	ADD R4, #1
	BEQ varOperandCount
	AND R11, R10, #0b11000000 ;@extract bits 6-7 for comparison
	CMP R11, #0b10000000
	PUSHEQ {R10,R11}
	BLEQ regfetch
	MOVEQ R0, R11
	POPEQ {R11}
	CMP R11, #0b01000000
	PUSHEQ {R11}
	BLEQ bytefetch
	MOVEQ R0, R11
	POPEQ {R11}
	CMP R11, #0b00000000
	PUSHEQ {R11}
	BLEQ halfwordfetch
	MOVEQ R0, R11
	POPEQ {R10,R11}
	
	AND R11, R10, #0b00110000 ;@extract bit 4-5 for comparison
	CMP R11, #0b00100000
	PUSHEQ {R10,R11}
	BLEQ regfetch
	MOVEQ R1, R11
	POPEQ {R11}
	CMP R11, #0b00010000
	PUSHEQ {R11}
	BLEQ bytefetch
	MOVEQ R1, R11
	POPEQ {R11}
	CMP R11, #0b00000000
	PUSHEQ {R11}
	BLEQ halfwordfetch
	MOVEQ R1, R11
	POPEQ {R10,R11}
	B twoOperand

bounce:
	LDR R11, =150000 ;@number of bounce loops
	LDR R12, =0 ;@counter
bb_loop:
	ADD R12, #1 ;@increment
	CMP R12, R11 ;@if target value reached
	MOVEQ R15, R14 ;@exit function
	B bb_loop

zerozmem:
	MOV R0, #0
	MOV R1, #0 ;@counter
memsetloop:
	LDR R2, =2000000 ;@exit condition
	STRB R0, [R7,R1]
	ADD R1, #1 ;@increment counter
	CMP R1, R2
	MOVEQ R15, R14
	B memsetloop

zerozstack:
	MOV R0, #0
	MOV R1, #0 ;@counter
	PUSH {R12}
	LDR R12, =Zstack
stacksetloop:
	LDR R2, =1000000 ;@exit condition
	STRB R0, [R12,R1]
	ADD R1, #1
	TST R1, R2
	POPEQ {R12}
	MOVEQ R15, R14
	B stacksetloop

zerozreg:
	MOV R0, #0
	MOV R1, #0 ;@counter
	PUSH {R12}
	LDR R12, [R9, #10]
	LDR R2, =1000000 ;@exit condition
regsetloop:
	STRB R0, [R12,R1]
	ADD R1, #1
	CMP R1, R2
	POPEQ {R12}
	MOVEQ R15, R14
	B regsetloop

debug_mode:

	LDR R10, =0xE0001030
	MOV R11, #10 ;@newline
	STR R11, [R10]
	MOV R11, #13
	STR R11, [R10] ;@newline
	MOV R11, #10 ;@newline
	STR R11, [R10]
	MOV R11, #13
	STR R11, [R10] ;@newline
	MOV R11, #68
	STR R11, [R10]
	MOV R11, #69
	STR R11, [R10]
	MOV R11, #66
	STR R11, [R10]
	MOV R11, #85
	STR R11, [R10]
	MOV R11, #71
	STR R11, [R10]
	MOV R11, #58
	STR R11, [R10]
	MOV R11, #32
	STR R11, [R10]
	MOV R12, #48 ;@ascii value for 0
	STR R12, [R10]
	MOV R12, #120 ;@ascii value for x
	STR R12, [R10]
	MOV R0, R8
	PUSH {R0} ;@push instruction byte
	LSR R0, #4  ;@convert bits 7-4
	AND R0, #0b1111
	PUSH {R14}
	BL hex_ascii_converter
	POP {R14}
	STR R0, [R10]
	POP {R0} ;@pop instruction byte
	AND R0, #0b1111 ;@convert bits 3-0
	PUSH {R14}
	BL hex_ascii_converter
	POP {R14}
	STR R0, [R10]
	MOV R11, #10
	STR R11, [R10]
	MOV R11, #13
	STR R11, [R10] ;@newline
	MOV R15, R14




