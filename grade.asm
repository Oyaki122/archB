	addi x1,x0,400
loop: addi x1,x1,-4
	lw x3,x1,0
	slti x4,x3,85
	addi x5,x0,5
	bne x4,x0,btest
	sw x5,x1,400
	beq x1,x0,exit
	beq x0,x0,loop
btest: slti x4,x3,60
	addi x5,x0,4
	bne x4,x0,ctest
	sw x5,x1,400
	beq x1,x0,exit
	beq x0,x0,loop
ctest: slti x4,x3,40
	addi x5,x0,3
	bne x4,x0,dtest
	sw x5,x1,400
	beq x1,x0,exit
	beq x0,x0,loop
dtest: slti x4,x3,10
	addi x5,x0,2
	bne x4,x0,etest
	sw x5,x1,400
	beq x1,x0,exit
	beq x0,x0,loop
etest: addi x5,x0,1
	sw x5,x1,400
	beq x1,x0,exit
	beq x0,x0,loop
exit: add x0, x0, x0
	ecall x0,x0,x0
