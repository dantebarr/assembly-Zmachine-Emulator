.global crash

crash:
	LDR R10, =0xE0001030
	MOV R11, #10
	STR R11, [R10]
	MOV R11, #13
	STR R11, [R10]
	MOV R11, #67 ;@C
	STR R11, [R10]
	MOV R11, #82 ;@R
	STR R11, [R10]
	MOV R11, #65 ;@A
	STR R11, [R10]
	MOV R11, #83 ;@S
	STR R11, [R10]
	MOV R11, #72 ;@H
	STR R11, [R10]
	MOV R11, #33 ;@!
	STR R11, [R10]
	MOV R11, #10
	STR R11, [R10]
	MOV R11, #13
	STR R11, [R10]
	MOV R11, #73 ;@INSTRUCTION:
	STR R11, [R10]
	MOV R11, #78
	STR R11, [R10]
	MOV R11, #83
	STR R11, [R10]
	MOV R11, #84
	STR R11, [R10]
	MOV R11, #82
	STR R11, [R10]
	MOV R11, #85
	STR R11, [R10]
	MOV R11, #67
	STR R11, [R10]
	MOV R11, #84
	STR R11, [R10]
	MOV R11, #73
	STR R11, [R10]
	MOV R11, #79
	STR R11, [R10]
	MOV R11, #78
	STR R11, [R10]
	MOV R11, #58
	STR R11, [R10]
	MOV R11, #32
	STR R11, [R10]
	MOV R12, #48 ;@ascii value for 0
	STR R12, [R10]
	MOV R12, #120 ;@ascii value for x
	STR R12, [R10]
	MOV R0, R8 ;@may need to save value of R0 here -- not sure
	PUSH {R0} ;@push instruction byte
	LSR R0, #4  ;@convert bits 7-4
	AND R0, #0b1111
	BL hex_ascii_converter
	STR R0, [R10]
	POP {R0} ;@pop instruction byte
	AND R0, #0b1111 ;@convert bits 3-0
	BL hex_ascii_converter
	STR R0, [R10]
	MOV R11, #10
	STR R11, [R10]
	MOV R11, #13
	STR R11, [R10]
	LDR R0, [R9, #15]
	MOV R11, #90 ;@ZPC:
	STR R11, [R10]
	MOV R11, #80
	STR R11, [R10]
	MOV R11, #67
	STR R11, [R10]
	MOV R11, #58
	STR R11, [R10]
	MOV R11, #32
	STR R11, [R10]
	MOV R12, #48 ;@ascii value for 0
	STR R12, [R10]
	MOV R12, #120 ;@ascii value for x
	STR R12, [R10]
	MOV R12, #32
ZPC_output:
	SUB R12, #4
	PUSH {R0}
	LSR R0, R12
	AND R0, #0b1111
	BL hex_ascii_converter
	STR R0, [R10]
	POP {R0}
	CMP R12, #0
	BEQ done
	BNE ZPC_output

done:
	LDR R1, =0x41220000 ;@load location of switches
	LDRB R2, [R1] ;@load switch value to r2
	TST R2, #0b10000000 ;@check if 7th switch is up
	BNE upload
	B done
