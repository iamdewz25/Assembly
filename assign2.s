.data
not: 				@for data transfer command
.asciz "Sorry!! This command is not data processing\n"
newline:
.asciz "\n"
shiftL:
.asciz "LSL"
shiftR:
.asciz "LSR"
rotateR:
.asciz "ROR"
AR:
.asciz "ASR"
return:
.word 0
sharp:
.asciz "#%d"
Rn:
.asciz "R%d"
comma:
.asciz ","
space:
.asciz " "
op:				@command list
.asciz "ANDEORSUBRSBADDADCSBCRSCTSTTEQCMPCMNORRMOVBICMVN"
branch:				@condition list
.asciz "EQNEHALOMIPLVSVCHILSGELTGTLE "
result:
.asciz " "
testval:			@test commmand list
	addlt r2,r4,r4,lsr r5
	mvn r9,r1,lsl #31
	ldr r1,=testval
	tst r5,r6
	cmn r7,#9
	teq r3,r7,lsl #22
	mvnlt r5,#5
	add r4,r6,#44
	add r5,r1,r2,lsl #31
	.word 0			@for check end list

	.text
	.global main
	.global printf
	.global scanf
main:
	ldr r1,=return
	str lr,[r1]
	mov r9,#0		@index of command testval
x:				@loop for main operaton program
	ldr r2,=testval
	ldr r10,[r2,r9] 	@LOAD machine code
	cmp r10,#0		@check end of list
	beq exit

checkcommmand:			@check command is/is not data processing commmand
	mov r5,r10,lsl #4
	lsr r5,#30		@get f bit for check
	cmp r5,#1
	beq notcommand		@f equal 1 is data transfer command
	bne opcheck		@if 0 is data processing

notcommand:			@method show warning if command is not data processing
	ldr r0,=not
	bl printf
	add r9,r9,#4		@add index 4 byte (32 bit)
	b x			@goto next index

opcheck:			@check opcode
	mov r1,r10,lsl #7
	lsr r1,#28 		@find opcode bit

	ldr r4,=op		@load opcode command list
	mov r0,#3 		@find index opcode
	mul r8,r1,r0		@find index in opcode command list
	mov r6,#0		@check round of print command char 3 char

loopop:				@loop print opcode command
	cmp r6,#3
	beq checkcon
	ldr r2,=result
	ldrb r5,[r4,r8]
	strb r5,[r2,#0]

	mov r7,#4		@print opcode
	mov r0,#1
	mov r2,#1
	ldr r1,=result
	swi 0

	add r8,r8,#1		@add index opcode list
	add r6,r6,#1		@add round check
	b loopop

checkcon:			@check condition bit
	mov r1,r10,lsr #28 	@find condition bit
	mov r0,#2
	mul r8,r1,r0		@find index in condition command list
	mov r6,#0

	ldr r4,=branch		@load condition list for print

	cmp r8,#30		@check if command is always command
	beq tapspace

loopcon:			@loop print condition command
	cmp r6,#2		@check is 2 round for stop print contiotion command
	beq tapspace		@if round = 2 print spacebar

	ldr r2,=result
	ldrb r5,[r4,r8]
	strb r5,[r2,#0]

	mov r7,#4		@showdata to monitor 1 char per round
	mov r0,#1
	mov r2,#1
	ldr r1,=result
	swi 0

	add r8,r8,#1
	add r6,r6,#1
	b loopcon

tapspace:			@method print spacebar
	mov r7,#4
	mov r0,#1
	mov r2,#1
	ldr r1,=space
	swi 0

checkRd:			@check destination operand

	mov r1,r10,lsl #7
	lsr r1,#28 		@load opcode bit to check command

	cmp r1,#8		@check command is tst for skip print Rd
	beq checkRn
	cmp r1,#9		@check command is teq for skip print Rd
        beq checkRn
	cmp r1,#10		@check command is cmp for skip print Rd
        beq checkRn
	cmp r1,#11		@check command is cmn for skip print Rd
        beq checkRn
	cmp r1,#13		@check command is mov for skip print Rd
        beq checkRn1
	cmp r1,#15		@check command is mvn for skip print Rd
	beq checkRn1

	mov r2,r10,lsl #16
	lsr r2,#28 		@find Register destination

	ldr r0,=Rn
	mov r1,r2
	bl printf

	ldr r0,=comma
	bl printf
	b checkRn

checkRn1:			@method for print Rn mov and mvn command
        mov r5,r10,lsl #16
        mov r5,r5,lsr #28	@find Rn bit
        ldr r0,=Rn
        mov r1,r5
        bl printf
        ldr r0,=comma
        bl printf
	b checkIm

checkRn:			@method for print Rn normal
	mov r5,r10,lsl #12
	mov r5,r5,lsr #28	@find Rn bit

	ldr r0,=Rn
        mov r1,r5
        bl printf

        ldr r0,=comma
        bl printf

checkIm:			@check immediate for check second source operand is register
				@ or constant
	mov r2,r10,lsl #6
	mov r5,r2,lsr #31	@get Imm bit

	cmp r5,#0		@check case Imm bit
	beq checkOperand2	@if Imm bit = 0	is register
	bne checkint		@if Imm bit = 1	is constant

checkint:			@method to print Operand 2(constant)  if Imm bit = 1
	mov r2,r10,lsl #20
	lsr r2,#20		@get constant to print

	ldr r0,=sharp
	mov r1,r2

	bl printf
	ldr r0,=newline
	bl printf

	add r9,r9,#4
	b x			@goto next index

checkOperand2:			@case register is 2 operand Imm bit = 0
	mov r2,r10,lsl #28
	lsr r2,#28		@get register number

      	ldr r0,=Rn		@print command
        mov r1,r2
        bl printf

checkShift:			@check shift command behind operand 2 (only Imm bit = 1 case)
	mov r2,r10,lsl #20
	lsr r2,#24		@load shift operation set

	cmp r2,#0		@check have shift??
	ldreq r0,=newline; 	@if not have goto next index
	bleq printf
	addeq r9,r9,#4
	beq x
				@if have goto dowm method

	mov r5,r10,lsl #27
	lsr r5,#31		@load bit 4 to check shift by Register or constant

	cmp r5,#1		@check bit 4 (1 bit)
	beq shiftRegistor 	@if = 1 goto print shift register

	movne r6,r2,lsr #3 	@else goto print shift constant
	ldrne r0,=comma
	blne printf

	cmp r5,#1		@check for shift constant again for bug case
	bne shiftint

shiftRegistor: 			@method to print shift command and Register
	ldr r0,=comma
	bl printf

	mov r5,r10,lsl #20
	mov r6,r5,lsr #28 	@find register shift number
	lsl r5,#5
	lsr r5,#30		@find shift command

	cmp r5,#0		@shift left command
        ldreq r0,=shiftL
        cmp r5,#1
        ldreq r0,=shiftR	@shift right command
        cmp r5,#2
        ldreq r0,=AR		@shift arithmetic right command
        cmp r5,#3
        ldreq r0,=rotateR	@shift rotate right command
        bl printf

        ldr r0,=space
        bl printf

        ldr r0,=Rn
        mov r1,r6
        bl printf

	ldr r0,=newline		@print newline
	bl printf

	add r9,r9,#4 		@add index 4 byte(32 bit)
	b x			@goto next index


shiftint:			@method to print shift command and constant

	mov r5,r10,lsl #25
	lsr r5,#30		@load shift command

	cmp r5,#0	 	@shift left command
	ldreq r0,=shiftL
	cmp r5,#1	 	@shift right command
        ldreq r0,=shiftR
	cmp r5,#2	 	@shift arithmetic right command
        ldreq r0,=AR
	cmp r5,#3	 	@shift rotate right command
        ldreq r0,=rotateR
	bl printf

	ldr r0,=space
	bl printf

	ldr r0,=sharp
	mov r1,r6
	bl printf

	ldr r0,=newline
        bl printf
	add r9,r9,#4 		@add index 4 byte(32 bit)
	b x			@goto next index

exit:				@exit program

	ldr lr,=return
	ldr lr,[lr]
	bx lr
