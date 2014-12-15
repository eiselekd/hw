
	.section .text
	.align	4

	.global start


	.org 0x100
start:
	l.movhi 	r3,hi(1073741824)	 # move immediate M
	l.movhi 	r4,hi(16908288)	 # move immediate M
	l.ori   	r4,r4,772 # iorsi3
	l.sw    	0(r3),r4	 # SI store
	l.movhi 	r3,hi(1073741824)	 # move immediate M
.L2:
	l.sw    	0(r3),r4	 # SI store
	l.j     	.L2 # jump_internal	# delay slot filled
	l.addi  	r4,r4,1 # addsi3
	
