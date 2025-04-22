addi x1,x0,0
addi x2,x0,20
main:
	addi x1,x1,1
	blt x1,x2,main
	ebreak