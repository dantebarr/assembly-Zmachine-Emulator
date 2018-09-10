.global bytefetch
.global halfwordfetch
.global regfetch
.global regstore
.global stackfetch
.global stackstore

bytefetch:
	LDRB R11, [R7,R4]
	ADD R4, #1
	MOV R15, R14

halfwordfetch:
	LDRB R12, [R7,R4]
	ADD R4, #1
	LSL R12, #8
	LDRB R11, [R7,R4]
	ADD R4, #1
	ADD R11, R12
	MOV R15, R14

regfetch:
	LDRB R11, [R7, R4] ;@fetch source byte
	ADD R4, #1 ;@inc ZPC
	CMP R11, #0x00 ;@Zstack condition
	BEQ stackfetch
	CMP R11, #0x10 ;@if less than 16
	BMI localZregf
	BPL globalZregf
localZregf:
	SUB R11, #1
	LSL R11, #1
	MOV R10, R6, LSL #6
	ADD R11, R10
	LDR R10, [R9, #10]
	LDRB R12, [R10, R11]
	ADD R11, #1
	LSL R12, #8
	LDRB R11, [R10, R11]
	ADD R11, R12
	MOV R15, R14
globalZregf:
	SUB R11, #16 ;@subtract 16 from byte
	LSL R11, #1 ;@multiply by 2
	LDR R10, =0x41220000 ;@load location of switches
	LDR R10, [R10] ;@load switch value
	CMP R10, #64 ;@check if only switch 6 is up
	BEQ headerfetch ;@if up is in header mode 
	CMP R10, #96 ;@check if switches 6 and 5 are up
	BEQ headerfetch ;@if up is in header mode
	LDR R10, =0x4000 ;@ not in header mode location of global Zregs
	ADD R11, R10 ;@calculate Zmem offset
	PUSH {R12}
	LDRB R12, [R7, R11] ;@load first byte from destination
	ADD R11, #1
	LSL R12, #8
	LDRB R11, [R7, R11] ;@load second byte from destination
	ADD R11, R12
	POP {R12}
	MOV R15, R14
headerfetch:
	PUSH {R11}
	LDRB R10, [R9, #4] ;@load location of Zregisters in memory
	LSL R10, #8
	LDRB R11, [R9, #5]
	ADD R10, R11
	POP {R11}
	ADD R11, R10 ;@calculate Zmem offset
	PUSH {R10}
	LDRB R10, [R7, R11] ;@load first byte from destination
	ADD R11, #1
	LSL R10, #8
	LDRB R11, [R7, R11] ;@load second byte from destination
	ADD R11, R10
	POP {R10}
	MOV R15, R14
stackfetch:
	LDR R10, [R9, #10] ;@get location of local Zregisters
	MOV R12, R6
	LSL R12, #6
	ADD R12, #38 ;@offset of 38 as each register is 2 bytes long
	LDRB R11, [R10, R12] ;@load value of 20th local Zreg
	LSL R11, #8
	ADD R12, #1
	PUSH {R10} ;@push r10 so we can use it to get second half of byte
	LDRB R10, [R10, R12]
	ADD R11, R10
	POP {R10}
	SUB R11, #1 ;@decrement 20 local Zregister---------by 1 or 2???
	PUSH {R11}
	LSR R11, #8
	SUB R12, #1 ;@set offset back to highbyte
	STRB R11, [R10, R12] ;@after decrementing restore in local R20
	POP {R11}
	ADD R12, #1
	STRB R11, [R10, R12] ;@store 20th local Zregister again
	LDR R10, [R9, #20] ;@load location of the Zstack
	SUB R5, #1 ;@decremement ZSP
	LDRB R12, [R10, R5] ;@pop low byte top value of the Zstack
	SUB R5, #1 ;@decremement ZSP
	LDRB R11, [R10, R5] ;@pop high byte value of the Zstack
	LSL R11, #8 ;@shift high byte
	ADD R11, R12 ;@compile popped value
	MOV R15, R14
	
	

regstore: ;@this will store the value stored in R12 to the byte value in R11 location byte
	PUSH {R12}
	CMP R11, #0x00 ;@Zstack condition
	BEQ stackstore
	CMP R11, #0x10 ;@if less than 16
	BMI localZregs
	BPL globalZregs
localZregs:
	SUB R11, #1
	LSL R11, #1
	MOV R10, R6, LSL #6
	ADD R11, R10
	LDR R10, [R9, #10]
	POP {R12}
	PUSH {R12}
	LSR R12, #8
	STRB R12, [R10, R11]
	ADD R11, #1
	POP {R12}
	STRB R12, [R10, R11]
	MOV R15, R14
globalZregs:
	SUB R11, #16 ;@subtract 16 from byte
	LSL R11, #1 ;@multiply by 2
	LDR R10, =0x41220000 ;@load location of switches
	LDR R10, [R10] ;@load switch value
	CMP R10, #64 ;@check if only switch 6 is up
	BEQ headerstore ;@if up is in header mode
	CMP R10, #96 ;@check if switches 6 and 5 are up
	BEQ headerstore ;@if up is in header mode
	LDR R10, =0x4000 ;@ not in header mode location of global Zregs
	ADD R11, R10 ;@calculate Zmem offset
	POP {R12}
	PUSH {R12}
	LSR R12, #8
	STRB R12, [R7, R11] ;@load first byte from destination
	ADD R11, #1
	POP {R12}
	STRB R12, [R7, R11] ;@load second byte from destination
	MOV R15, R14
headerstore:
	PUSH {R11}
	LDRB R10, [R9, #4] ;@load location of Zregisters in memory
	LSL R10, #8
	LDRB R11, [R9, #5]
	ADD R10, R11
	POP {R11}
	ADD R11, R10 ;@calculate Zmem offset
	POP {R12}
	PUSH {R12}
	LSR R12, #8
	STRB R12, [R7, R11] ;@load first byte from destination
	ADD R11, #1
	POP {R12}
	LDRB R12, [R7, R11] ;@load second byte from destination
	MOV R15, R14	
stackstore:
	LDR R10, [R9, #10] ;@get location of local Zregisters
	MOV R12, R6
	LSL R12, #6
	ADD R12, #38
	LDRB R11, [R10, R12] ;@offset of 38 as each register is 2 bytes long ---------------------------------
	ADD R12, #1
	LSL R11, #8
	PUSH {R10} ;@push r10 so we can use it to get second half of byte
	LDRB R10, [R10, R12]
	ADD R11, R10
	POP {R10}
	ADD R11, #1 ;@increment 20 local Zregister
	PUSH {R11}
	LSR R11, #8
	SUB R12, #1
	STRB R11, [R10, R12] ;@store 20th local Zregister again
	ADD R12, #1
	POP {R11}
	STRB R11, [R10, R12] ;@store 20th local Zregister again
	LDR R10, [R9, #20] ;@load location of the Zstack
	POP {R12}
	PUSH {R12}
	LSR R12, #8
	STRB R12, [R10, R5] ;@push top value of the Zstack
	ADD R5, #1 ;@increment ZSP
	POP {R12}
	LDRB R12, [R10, R5]
	ADD R5, #1 ;@increment ZSP
	MOV R15, R14
	
	
	
	
	
	
	
	
	
	
	
