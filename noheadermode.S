.global noheadermode

noheadermode:
	LDR R0, =0x1000
	LDRB R1, [R7, R0] ;@load value of object table in no header mode
	ADD R0, #1
	STRB R1, [R9] ;@store value of object table in personal memory
	LDRB R1, [R7, R0]
	STRB R1, [R9, #1]
	LDR R0, =0x2000
	LDRB R1, [R7, R0] ;@load value of dictionary in no header mode
	ADD R0, #1
	STRB R1, [R9, #2] ;@store value of dictionary in personal memory
	LDRB R1, [R7, R0] ;@load value of dictionary in no header mode
	STRB R1, [R9, #3] ;@store value of dictionary in personal memory
	LDR R0, =0x4000
	LDRB R1, [R7, R0] ;@load value of Zregisters in no header mode
	ADD R0, #1
	STRB R1, [R9, #4] ;@store value of global Zregisters in personal memory
	LDRB R1, [R7, R0] ;@load value of Zregisters in no header mode
	STRB R1, [R9, #5] ;@store value of global Zregisters in personal memory
	PUSH {R2}
	LDRB R1, [R7, #0] ;@load value of ZPC in no header mode
	LSL R1, #8
	LDRB R2, [R7, #1]
	ADD R1, R2
	POP {R2}
	MOV R4, #0 ;@set ZPC to found value--------------set back to R1 when done testing
	MOV R15, R14 ;@exit function
