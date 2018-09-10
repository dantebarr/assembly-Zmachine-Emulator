.global Zcall
.global Zreturn

Zcall:
	ADD R6, #1 ;@ Inc Nesting Depth by 1
	PUSH {R14}
	BL zerolocZreg ;@Clear local ZRegisters
	POP {R14}
	;@may want to push R8(current Zinstruction byte) here
	LDR R8, [R9, #10] ;@load location of local Zregisters
	LSL R10, R6, #6 ;@calculate set of Zregisters based on nesting depth
	LDRB R11, [R9, #30] ;@Load VarOperand count
	SUBS R11, #1 ;@decrement operand count
	PUSH {R11}
	PUSH {R14}
	BLNE storeOperands ;@if operand count is more than 0
	POP {R14}
	POP {R11} ;@get value of decremented operand count
	LSL R10, R6, #6 ;@calculate nesting depth
	ADD R10, #42 ;@add offset for 22nd reg
	STRB R11, [R8, R10] ;@store number of inputs
	LSL R10, R6, #6 ;@calculate nesting depth
	ADD R10, #46 ;@add offset for 24th reg
	PUSH {R4}
	LSR R4, #8
	STRB R4, [R8, R10] ;@store high byte for ZPC
	ADD R10, #1 ;@increment local zreg offset
	POP {R4} ;@restore ZPC
	STRB R4, [R8, R10] ;@store low byte for ZPC
	LSL R10, R6, #6 ;@calculate nesting depth
	ADD R10, #54 ;@add offset for 28th reg
	LDRB R11, [R9, #35] ;@load high byte destination register from personal memory
	STRB R11, [R8, R10] ;@store high byte destination register into local registers
	ADD R10, #1 ;@increment local register offset
	LDRB R11, [R9, #36] ;@load low byte destination register from personal memory
	STRB R11, [R8, R10] ;@store low byte destination register into local registers
	LSL R0, #2 ;@multiply operand by 4
	ADD R0, #1 ;@add one
	MOV R4, R0 ;@set R0 as new ZPC
	B decode_instructions_loop
storeOperands:
	PUSH {R1} ;@store second operand
	LSR R1, #8
	STRB R1, [R8, R10]
	ADD R10, #1 ;@increment local register offset
	POP {R1}
	STRB R1, [R8, R10]
	ADD R10, #1 ;@increment local register offset
	CMP R11, #1
	MOVEQ R15, R14 ;@exit function if no more operands
	SUBS R11, #1 ;@subtract 1 again as we have now input an operand
	MOVEQ R15, R14 ;@exit if there was only one operand to store
	LSL R11, #1 ;@multiply it by two since we will compare with counter that doubles as byte offset and operands are 2 bytes long
	PUSH {R12}
	MOV R12, #0 ;@set counter and var operand space offset
varOploop:
	PUSH {R11}
	LDR R11, [R9, #25] ;@get memory location of variable operand space
	LDRB R11, [R11, R12] ;@get high byte of operand
	ADD R12, #1 ;@increment counter/operand offset
	STRB R11, [R8, R10] ;@store highbyte into local zregisters with offset R10
	ADD R10, #1 ;@increment local register offset
	LDR R11, [R9, #25] ;@get memory location of variable operand space
	LDRB R11, [R11, R12] ;@get low byte of operand
	ADD R12, #1 ;@increment counter/operand offset
	STRB R11, [R8, R10] ;@store low byte into local zregisters with offset R10
	ADD R10, #1 ;@increment local register offset
	POP {R11}
	CMP R12, R11 ;@if counter is equal to operand count then exit otherwise loop
	POPEQ {R12}
	MOVEQ R15, R14
	BNE varOploop


Zreturn: ;@return with value stored in memory before function
	;@get return value and save to memory outside of return
	MOV R11, R6
	LSL R11, #6
	ADD R11, #38
	LDR R12, [R9, #10]
	PUSH {R12}
	LDRB R10, [R12, R11]
	ADD R11, #1
	LSL R10, #8
	LDRB R12, [R12, R11]
	ADD R12, R10 ;@compile value from 20th Zregister
	MOV R10, #0 ;@set counter
	CMP R10, R12
	PUSH {R14}
	BLNE Zstack_pop_loop
	POP {R14}
	MOV R11, R6
	LSL R11, #6
	ADD R11, #46
	LDR R12, [R9, #10]
	PUSH {R12}
	LDRB R10, [R12, R11]
	ADD R11, #1
	LSL R10, #8
	LDRB R12, [R12, R11]
	ADD R12, R10 ;@compile value from 24th Zregister
	MOV R4, R12 ;@set ZPC to value found in 24th register
	MOV R11, R6
	LSL R11, #6
	ADD R11, #46
	LDR R12, [R9, #10]
	LDRB R10, [R12, R11]
	ADD R11, #1
	LSL R10, #8
	LDRB R12, [R12, R11]
	ADD R12, R10 ;@compile value from 28th Zregister
	SUB R6, #1
	PUSH {R8}
	LDR R8, =0xffff
	CMP R12, R8 ;@check if there is write back
	POP {R8}
	MOVEQ R15, R14

	LDRB R8, [R9, #45] ;@load stored return value from personal memory
	LSL R8, #8
	LDRB R11, [R9, #46]
	ADD R11, R8
	MOV R8, R11
	MOV R11, R12
	MOV R12, R8 ;@switch R11 and R12 for function
	PUSH {R14}
	BL regstore
	POP {R14}
	MOV R15, R14 ;@exit return function




Zstack_pop_loop:
	PUSH {R14}
	BL stackfetch
	POP {R14}
	ADD R10, #1
	CMP R10, R12
	BNE Zstack_pop_loop
	MOVEQ R15, R14


zerolocZreg:
	MOV R8, #0
	MOV R10, R6 ;@counter and offset
	LSL R10, #6
	LDR R11, [R9, #10] ;@Zregister memory loc
	MOV R12, R10 ;@exit condition
	ADD R12, #64 ;@exit condition
regsetloop:
	STRB R8, [R11,R10]
	ADD R10, #1
	CMP R10, R12
	MOVEQ R15, R14
	B regsetloop













