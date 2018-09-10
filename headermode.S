.global headermode

headermode:
	LDR R0, =0x0A
	LDRB R1, [R7, R0] ;@load value of object table in no header mode
	ADD R0, #1
	STRB R1, [R9] ;@store value of object table in personal memory
	LDRB R1, [R7, R0]
	STRB R1, [R9, #1]
	LDR R0, =0x08
	LDRB R1, [R7, R0] ;@load value of dictionary in no header mode
	ADD R0, #1
	STRB R1, [R9, #2] ;@store value of dictionary in personal memory
	LDRB R1, [R7, R0] ;@load value of dictionary in no header mode
	STRB R1, [R9, #3] ;@store value of dictionary in personal memory
	LDR R0, =0x0C
	LDRB R1, [R7, R0] ;@load value of Zregisters in no header mode
	ADD R0, #1
	STRB R1, [R9, #4] ;@store value of global Zregisters in personal memory
	LDRB R1, [R7, R0] ;@load value of Zregisters in no header mode
	STRB R1, [R9, #5] ;@store value of global Zregisters in personal memory
	PUSH {R2}
	LDRB R1, [R7, #6] ;@load value of ZPC in no header mode
	STRB R1, [R9, #6]
	LSL R1, #8
	LDRB R2, [R7, #7]
	STRB R2, [R9, #7]
	ADD R1, R2
	POP {R2}
	MOV R4, R1 ;@set ZPC to found value
	MOV R15, R14 ;@exit function
