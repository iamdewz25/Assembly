	.global main
	.func main
main:
loaddata:
	sub sp,sp,#24

	LDR R1,valuemat1 @matrix 1
	ldr r2,valuemat2 @matrix 2

loadmatrix:
	vldr s0,[r1,#0]
	vldr s1,[r1,#4]
	vldr s2,[r1,#8]
	vldr s3,[r1,#12]
	vldr s4,[r1,#16]
	vldr s5,[r1,#20]

@matrix2
	vldr s6,[r2,#0]
	vldr s7,[r2,#4]
	vldr s8,[r2,#8]
	vldr s9,[r2,#12]
	vldr s10,[r2,#16]
	vldr s11,[r2,#20]
mul:
	vmul.f32 s12,s0,s6 @a11*b11
	vmul.f32 s13,s1,s8 @a12*b21
	vmul.f32 s14,s2,s10 @a13*b31

	vadd.f32 s12,s12,s13
	vadd.f32 s12,s12,s14 @ans a11

	vmul.f32 s13,s0,s7 @a11*b12
	vmul.f32 s14,s1,s9 @a12*b22
	vmul.f32 s15,s2,s11 @a13*b32

	vadd.f32 s13,s13,s14
	vadd.f32 s13,s13,s15 @ans a12


	vmul.f32 s14,s3,s6 @a21*b11
	vmul.f32 s15,s4,s8 @a22*b21
	vmul.f32 s16,s5,s10 @a23*b31

	vadd.f32 s14,s14,s15
	vadd.f32 s14,s14,s16 @ans a21

	vmul.f32 s15,s3,s7 @a21*b12
	vmul.f32 s16,s4,s9 @a22*b22
	vmul.f32 s17,s5,s11 @a23*b32

	vadd.f32 s15,s15,s16
	vadd.f32 s15,s15,s17 @ans a22

	vcvt.f64.f32 d0,s12
	vcvt.f64.f32 d1,s13
	vcvt.f64.f32 d2,s14
	vcvt.f64.f32 d3,s15

printfloat:
	LDR R0, =string
	VMOV R2, R3, D0
	vstr d1,[sp]
	vstr d2,[sp,#8]
	vstr d3,[sp,#16]
	BL printf
	add sp,sp,#24
exit:
	MOV R7, #1 @ Exit Syscall
	SWI 0

valuemat1: .word matrix1
valuemat2: .word matrix2

	.data
matrix1: .float 1.0, 2.0, 3.0
	 .float 4.0, 5.0, 6.0

matrix2: .float 1.0, 1.0
	 .float 2.0, 3.0
	 .float 5.0, 0.0
string: .asciz "%.1f %.1f \n%.1f %.1f\n"
test: .asciz "test: %f\n"
