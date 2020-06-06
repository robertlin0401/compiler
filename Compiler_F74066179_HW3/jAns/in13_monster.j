.source hw3.j
.class public Main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100  ; Define your storage size.
.limit locals 100 ; Define your local space number.
	ldc 0
	istore 0
label0:
	iload 0
	ldc 0
	istore 0
label1:
	iload 0
	ldc 10
	isub
	iflt label2
	iconst_0
	goto label3
label2:
	iconst_1
label3:
	goto label5
label4:
	iload 0
	ldc 1
	iadd
	istore 0
	goto label1
label5:
	ifeq end0
	iload 0
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(I)V
	goto label4
end0:
	ldc 3
	newarray int
	astore 1
	aload 1
	ldc 0
	ldc 1
	ldc 2
	iadd
	iastore
	aload 1
	ldc 1
	aload 1
	ldc 0
	iaload
	ldc 1
	isub
	iastore
	aload 1
	ldc 2
	aload 1
	ldc 1
	iaload
	ldc 3
	idiv
	iastore
	aload 1
	ldc 2
	iaload
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
	ifgt label6
	iconst_0
	goto label7
label6:
	iconst_1
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
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	ldc 3
	newarray float
	astore 2
	aload 2
	ldc 0
	ldc 1.100000
	ldc 2.100000
	fadd
	fastore
	aload 2
	ldc 0
	faload
	f2i
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(I)V
	ldc 0
	istore 3
	iload 3
	ldc 2
	iadd
	istore 3
label10:
	iload 3
	ldc 0
	isub
	ifgt label11
	iconst_0
	goto label12
label11:
	iconst_1
label12:
	ifeq end1
	iload 3
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(I)V
	iload 3
	ldc 1
	isub
	istore 3
	iload 3
	ldc 0
	isub
	ifne label13
	iconst_0
	goto label14
label13:
	iconst_1
label14:
	ifeq label15
	ldc 3.140000
	fstore 4
	fload 4
	ldc 1.000000
	fadd
	f2i
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(I)V
	ldc "If x != "
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	ldc 0
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(I)V
	fload 4
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(F)V
	goto end2
label15:
	ldc 6.600000
	fstore 5
	ldc "If x == "
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	ldc 0
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(I)V
	fload 5
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(F)V
end2:
	ldc 0
	istore 6
label16:
	iload 6
	ldc 1
	istore 6
label17:
	iload 6
	ldc 3
	isub
	ifle label18
	iconst_0
	goto label19
label18:
	iconst_1
label19:
	goto label21
label20:
	iload 6
	ldc 1
	iadd
	istore 6
	goto label17
label21:
	ifeq end3
	iload 3
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(I)V
	ldc "*"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	iload 6
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(I)V
	ldc "="
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	iload 3
	iload 6
	imul
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(I)V
	ldc "\t"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	goto label20
end3:
	goto label10
end1:
	return
.end method
