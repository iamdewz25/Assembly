
	.data
	.balign 4
return: .word 0
	.balign 4
testval:
	.float 0.5 	@0
	.float 0.25	@4
	.float -1.0	@8
	.float 100.0	@12
	.float 1234.567	@16
	.float -9876.543 @20
	.float 7070.7070 @24
	.float 3.3333	@28
	.float 694.3e-9	@32
	.float 6.0221e2	@36
	.float 6.0221e21 @40
	.word 0
start: .asciz "float number : "
firstnum: .asciz "%d.%s\n"
str: .asciz "-"
string: .asciz " "
	.skip 40
fbit: .word 0
fbitprint: .asciz "ieee 754 in hex : %x\n"
signprint: .asciz "sign : %d\n"
num: .word 0
sign: .word 0
expoprint: .asciz "exponant : %d\n"
expo: .word 0
manprint: .asciz "Mantissta : %x\n\n"
man: .word 0
	.text
	.global main
	.global printf
main:
	ldr r1,=return
	str lr,[r1]


	mov r8,#0
	mov r11,#10


loaddata:
	cmp r8,#44
	ldrne r0,=start
	blne printf

	ldr r0,=testval
	ldr r12,[r0,r8] @load data

	ldr r5,=fbit
	str r12,[r5]

	cmp r12,#0 @check stop
	beq exit


exponant:

	ldr r5,=0x7f800000
	and r3,r12,r5
	lsr r3,r3,#23 @exponant

	ldr r5,=expo
	str r3,[r5]

	add r3,r3,#1  @expo + 1
	mov r9,r3
	cmp r3,#127
	rsblt r3,r3,#127 @127 -expo
	subge r3,r3,#127 @expo -127

mantissa:
	ldr r5,=0x7fffff
	and r4,r12,r5 @mantissa with 24 bit

	ldr r5,=man
	str r4,[r5]

	ldr r5,=0x800000
	orr r1,r4,r5
	lsl r1,r1,#8 @mantissa 32 bit


intoint:
	cmp r9,#127 @check expo > 127
	addlt r0,r3,#32 
	rsbge r0,r3,#32 @shift n bit
	lsr r6,r1,r0 @int before point

	ldr r5,=num
	str r6,[r5] @store integer


	movge r7,r1,lsl r3 @case expo >= 127
	movlt r7,r1,lsr r3 @case expo < 127

	mov r6,#0 @index string

loopprint:
	umull r9,r10,r7,r11
	mov r7,r9 @set data to mul
	ldr r5,=string
	add r10,r10,#48 @change to ascii
	str r10,[r5,r6]  @store data
	add r6,r6,#1 
	cmp r9,#0 @check stop loop
	beq signbit
	b loopprint

signbit:
	lsr r2,r12,#31 @signbit

	ldr r5,=sign
	str r2,[r5]

	cmp r2,#0 @check negative
	ldrne r0,=str
	blne printf


print:
	ldr r0,=firstnum @string
	ldr r1,=num	@before point
	ldr r1,[r1]
	ldr r2,=string @after point
	bl printf

	ldr r0,=fbitprint
	ldr r1,=fbit
	ldr r1,[r1]
	bl printf

	ldr r0,=signprint
	ldr r1,=sign
	ldr r1,[r1]
	bl printf

	ldr r0,=expoprint
	ldr r1,=expo
	ldr r1,[r1]
	bl printf

	ldr r0,=manprint
	ldr r1,=man
	ldr r1,[r1]
	bl printf
	add r8,r8,#4 @add index +4
	b loaddata



exit:
	ldr lr,=return
	ldr lr,[lr]
	bx lr
