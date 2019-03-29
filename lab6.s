	.global _start
_start:

read:
	mov r7,#3
	mov r0,#0
	mov r2,#81
	ldr r1,=string
	swi 0

loaddata:
	mov r0,#0 @string check
	mov r5,#0 @com table
	ldr r1,=string
	ldr r3,=com

loadchar:
	ldrb r2,[r1,r0]
	cmp r2,#10
	beq write

checktable:
	ldrb r4,[r3,r5]
	cmp r4,r2
	addne r5,r5,#1
	bne checktable
	beq change

change:
	sub r5,r5,#5
	cmp r5,#0
	addmi r5,r5,#26
	ldrb r6,[r3,r5]
	strb r6,[r1,r0]
	mov r5,#0 @reset index com
	add r0,r0,#1 @add index string
	b loadchar

write:
	mov r7,#4
	mov r0,#1
	mov r2,#81
	ldr r1,=string
	swi 0
exit:
	mov r7,#1
	swi 0

.data
com: .ascii "ABXYPQRMNCEDKLJOSHTUFVZGWI"
string: .ascii " "
	.skip 81
