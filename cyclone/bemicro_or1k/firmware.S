
	.section .text
	.align	4

	.global start

.org 0x100
start:
.L2:
	l.j     	.L2 # jump_internal
	l.nop			# nop delay slot
	
