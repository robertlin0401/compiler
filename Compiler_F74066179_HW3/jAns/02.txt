.source hw3.j
.class public Main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100  ; Define your storage size.
.limit locals 100 ; Define your local space number.
	ldc 3
	ldc 4
	ldc 5
	 
	ldc 8
	ineg
	iadd
	imul
	isub
	ldc 10
	ldc 7
	idiv
	isub
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(I)V
	ldc 3
	ldc 4
	ldc 5
	 
	ldc 8
	ineg
	iadd
	imul
	isub
	ldc 10
	ldc 7
	idiv
	isub
	ldc 4
	ineg
	ldc 3
	irem
	isub
	ifgt label0
	iconst_0
	goto label1
label0:
	iconst_1
	goto label2
label1:
label2:
	iconst_1
	iconst_1
	ixor
	iconst_0
	iconst_1
	ixor
	iconst_1
	ixor
	iand
	ior
	ifne label3
	ldc "false"
	goto label4
label3:
	ldc "true"
label4:
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	ldc 3.000000
	ldc 4.000000
	ldc 5.000000
	 
	ldc 8.000000
	fneg
	fadd
	fmul
	fsub
	ldc 10.000000
	ldc 7.000000
	fdiv
	fsub
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(F)V
	ldc 3.000000
	ldc 4.000000
	ldc 5.000000
	 
	ldc 8.000000
	fneg
	fadd
	fmul
	fsub
	ldc 10.000000
	ldc 7.000000
	fdiv
	fsub
	ldc 4.000000
	fneg
	fcmpl
	ifgt label5
	iconst_0
	goto label6
label5:
	iconst_1
	goto label7
label6:
label7:
	iconst_1
	iconst_1
	ixor
	iconst_0
	iconst_1
	ixor
	iconst_1
	ixor
	iand
	ior
	ifne label8
	ldc "false"
	goto label9
label8:
	ldc "true"
label9:
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	return
.end method
