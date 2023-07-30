	addi x1,x0,400
loop: addi x1,x1,-4
	lw x3,x1,0
	slti x4,x3,85
	bne x4,x0,btest
	addi x5,x0,5
	sw x5,x1,400
	beq x1,x0,exit
	beq x0,x0,loop
btest: slti x4,x3,60
	bne x4,x0,ctest
	addi x5,x0,4
	sw x5,x1,400
	beq x1,x0,exit
	beq x0,x0,loop
ctest: slti x4,x3,40
	bne x4,x0,dtest
	addi x5,x0,3
	sw x5,x1,400
	beq x1,x0,exit
	beq x0,x0,loop
dtest: slti x4,x3,10
	bne x4,x0,etest
	addi x5,x0,2
	sw x5,x1,400
	beq x1,x0,exit
	beq x0,x0,loop
etest: addi x5,x0,1
	sw x5,x1,400
	beq x1,x0,exit
	beq x0,x0,loop
exit: ecall x0,x0,x0
