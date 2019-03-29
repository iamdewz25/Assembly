
.global _start
_start:
_read:
    mov r7,#3
    mov r0,#0
    mov r2,#3
    ldr r1,=sum1
    swi 0

_read2:
    mov r7,#3
    mov r0,#0
    mov r2,#3
    ldr r1,=sum2
    swi 0

_add:
    mov r6,#10
    ldr r3,=sum1
    ldrb r4,[r3,#0]
    sub r4,r4,#48
    muls r2,r4,r6

    ldrb r5,[r3,#1]
    sub r5,r5,#48
    add r5,r2,r5

    ldr r3,=sum2
    ldrb r7,[r3,#0]
    sub r7,r7,#48
    muls r2,r7,r6

    ldrb r8,[r3,#1]
    sub r8,r8,#48

    add r7,r2,r8
    add r4,r5,r7

mov r6,#2
mov r8,#0
mov r3,r4

_la:
    mov r3,r4
_loop:
    cmp r3,#10
    blt _done
    sub r3,r3,#10
    add r8,r8,#1
    B _loop
_done:
    cmp r6,#-1
    beq _out
    ldr r5,=ans
    add r3,r3,#48
    strb r3,[r5,r6]
    sub r6,r6,#1
    mov r4,r8
    mov r8,#0
    B _la
_out:
    mov r7,#4
    mov r0,#1
    mov r2,#4
    ldr r1,=ans
    swi 0
_exit:
    mov r7,#1
    swi 0
.data
ans: .ascii "   \n"
sum1: .ascii "   \n"
sum2: .ascii "   \n"



