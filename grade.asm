	addi x5, x0, 1
	addi x6, x0, 2
	addi x7, x0, 3
	addi x8, x0, 4
	addi x9, x0, 5
	addi x1,x0,400
loop: beq x1,x0,exit
	addi x1,x1,-4
	lw x3,x1,0
	slti x4,x3,85
	addi x9,x0,5
	bne x4,x0,btest
	sw x9,x1,400
	beq x0,x0,loop
btest: slti x4,x3,60
	bne x4,x0,ctest
	sw x8,x1,400
	beq x0,x0,loop
ctest: slti x4,x3,40
	bne x4,x0,dtest
	sw x7,x1,400
	beq x0,x0,loop
dtest: slti x4,x3,10
	bne x4,x0,etest
	sw x6,x1,400
	beq x0,x0,loop
etest: sw x5,x1,400
	beq x0,x0,loop
exit: add x0, x0, x0
	ecall x0,x0,x0
