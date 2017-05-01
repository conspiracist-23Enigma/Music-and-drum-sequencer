.syntax unified
.global main

.macro sil timeloops
	ldr r0, =#\timeloops
	bl silence
.endm

.macro three totaloops, loop1, loop2, loop3, amp
	ldr r4, =#\totaloops	@@not dependent on frequency
	ldr r5, =#\loop1
	ldr r6, =#\loop2	@@loopcounters
	ldr r7, =#\loop3
	mov r0, #2
	udiv r8, r5, r0		@@high low barriers, if less than them, then low or vice versa
	udiv r9, r6, r0
	udiv r10, r7, r0
	ldr r11, =#\amp		@@amplitude
	ldr r12, =#-\amp
	bl threenotes
.endm

.macro two totaloops, loop1, loop2, amp
	ldr r9, =#\totaloops	@@not dependent on frequency
	ldr r7, =#\loop1	@@loopcounters
	ldr r8, =#\loop2
	ldr r5, =#\amp
	ldr r6, =#-\amp		@@amplitude
	bl twonotes
.endm

main:
	bl init_audio

song:		@@harmony song
	three 32000, 346, 462, 693, 0x2000
	three 32000, 346, 462, 693, 0x2000
	three 32000, 291, 390, 582, 0x2000
	three 32000, 346, 462, 693, 0x2000
	three 32000, 291, 390, 582, 0x2000
	three 32000, 346, 462, 693, 0x2000
	sil 32000
	three 32000, 291, 390, 582, 0x2000
	sil 32000
	three 32000, 346, 462, 693, 0x2000
	sil 32000
	three 128000, 327, 436, 654, 0x2000
	three 32000, 163, 436, 654, 0x2000
	two 64000, 173, 693, 0x3750
	two 32000, 173, 462, 0x3750
	two 64000, 116, 346, 0x3750
	two 96000, 146, 291, 0x3750
	two 64000, 130, 778, 0x3750
	two 32000, 130, 519, 0x3750
	two 64000, 109, 390, 0x3750
	two 32000, 116, 309, 0x3750
	two 64000, 116, 309, 0x3750
	two 64000, 173, 693, 0x3750
	two 32000, 173, 462, 0x3750
	two 64000, 116, 346, 0x3750
	two 96000, 146, 291, 0x3750
	two 64000, 130, 778, 0x3750
	two 32000, 130, 519, 0x3750
	two 64000, 109, 390, 0x3750
	two 64000, 116, 309, 0x3750
	two 32000, 195, 309, 0x3750
	two 64000, 218, 873, 0x3750
	two 32000, 218, 582, 0x3750
	two 32000, 218, 436, 0x3750
	two 64000, 173, 346, 0x3750
	two 64000, 146, 291, 0x3750
	two 64000, 146, 925, 0x3750
	two 32000, 146, 617, 0x3750
	two 32000, 130, 462, 0x3750
	two 32000, 146, 390, 0x3750
	two 32000, 163, 390, 0x3750
	two 32000, 173, 309, 0x3750
	two 32000, 195, 309, 0x3750
	two 64000, 218, 1038, 0x3750
	two 64000, 218, 519, 0x3750
	two 64000, 173, 693, 0x3750
	two 32000, 146, 346, 0x3750
	two 32000, 173, 346, 0x3750
	three 64000, 116, 617, 925, 0x2000
	sil 4000
	three 128000, 116, 617, 925, 0x2000
	three 64000, 130, 519, 1038, 0x2000

	sil 70000
	ldr r7, =#0x8000
	ldr r8, =#0x7FFF
	mov r12, #66
	ldr r11, =#value

song2loop:		@@drum sequencer song
	ldr r10, [r11]
	add r11, #4
	lsr r10, #2
 	ldr r6, [r11], #4
 	bl play_percussion
 	subs r12, #1
 	bne song2loop
 	sil 70000
 	b song



@@ This function produces the percussion sounds, i.e- The drum sequencer
play_percussion:
	@@ Stroring registers on stack
	stmdb sp!, {r4, r5, r6, r9, r11, lr}
	sub sp , #24
	mov r4, r7
	mov r5, r8
	mov r9, r10
	udiv r6, r7, r6


	High:
		mov r0, r5
		bl play_audio_sample
		subs r9, #1
		bne High

		mov r9, r10

	Low:
		mov r0, r4
		bl play_audio_sample
		subs r9, #1
		bne Low

		mov r9, r10

		sub r5, r6		@@(decrementing and incrementing values so as to give
		add r4, r6		@@linear decay envelope)
		subs r6, #1
		bne High

		add sp , #24
		ldmia sp!, {r4, r5, r6, r9, r11, lr}	@@ Restoring registers from stack
		bx lr

threenotes:	@@This function adds three notes
	push {lr}
for2:
    cmp r5, #0		@@check if counter1 is zero
    beq doshit3
    b if3
doshit3:
    lsl r5, r8, #1

if3:
    cmp r5, r8		@@High or low?
    bmi else3
    mov r0, r11
    b end3
else3:
    mov r0, r12
end3:
    cmp r6, #0		@@check if counter2 is zero
    beq doshit4
    b if4
doshit4:
    lsl r6, r9, #1

if4:
    cmp r6, r9		@@High or low?
    bmi else4
    add r0, r11
    b end4
else4:
    add r0, r12
end4:
	cmp r7, #0		@@check if counter3 is zero
    beq doshit5
    b if5
doshit5:
    lsl r7, r10, #1

if5:
    cmp r7, r10
    bmi else5			@@High or low?
    add r0, r11
    b end5
else5:
    add r0, r12
end5:
    bl play_audio_sample

    sub r5, #1		@@decrease counters
    sub r6, #1
    sub r7, #1

    subs  r4, #1
    bne for2
    pop {lr}
    bx lr




twonotes:		@@ This function adds two notes
    push {lr}
    mov r0, #2
	udiv r10, r7, r0
	udiv r11, r8, r0

for:
    cmp r7, #0		@@check if counter1 is zero
    beq doshit1
    b if1
doshit1:
    lsl r7, r10, #1

if1:
    cmp r7, r10		@@High or low?
    bmi else1
    mov r0, r5
    b end1
else1:
    mov r0, r6
end1:
    cmp r8, #0		@@check if counter2 is zero
    beq doshit2
    b if2
doshit2:
    lsl r8, r11, #1

if2:
    cmp r8, r11
    bmi else2		@@High or low?
    add r0, r5
    b end2
else2:
    add r0, r6
end2:
    bl play_audio_sample

    sub r7, #1		@@decrease counters
    sub r8, #1

    subs  r9, #1
    bne for
    pop {lr}
    bx lr

@@ silence function
silence:
	stmdb sp!, {r11, lr}
	sub sp, #8
	mov r11, r0
	lag:
		mov r0, #0
		bl play_audio_sample
		subs r11, #1
		bne lag
		add sp, #8
		ldmia sp!, {r11 ,lr}
		bx lr

.data
value:
	.word 550, 140
	.word 490, 156
	.word 436, 176
	.word 436, 176
	.word 436, 176
	.word 550, 140
	.word 412, 186
	.word 412, 186
	.word 412, 186
	.word 490, 156
	.word 436, 176
	.word 436, 176
	.word 436, 176
	.word 550, 140
	.word 490, 156
	.word 490, 156
	.word 490, 156
	.word 550, 140
	.word 490, 156
	.word 436, 176
	.word 436, 176
	.word 436, 176
	.word 550, 140
	.word 412, 186
	.word 412, 186
	.word 412, 186
	.word 367, 105
	.word 412, 186
	.word 436, 176
	.word 550, 140
	.word 490, 156
	.word 734, 105
	.word 550, 280
	.word 550, 140
	.word 490, 156
	.word 436, 176
	.word 436, 176
	.word 436, 176
	.word 550, 140
	.word 412, 186
	.word 412, 186
	.word 412, 186
	.word 490, 156
	.word 436, 176
	.word 436, 176
	.word 436, 176
	.word 550, 140
	.word 490, 156
	.word 490, 156
	.word 490, 156
	.word 550, 140
	.word 490, 156
	.word 436, 176
	.word 436, 176
	.word 436, 176
	.word 550, 140
	.word 412, 186
	.word 412, 186
	.word 412, 186
	.word 367, 105
	.word 412, 186
	.word 436, 176
	.word 550, 140
	.word 490, 156
	.word 734, 105
	.word 550, 500
