.source hw3.j
.class public Main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100  ; Define your storage size.
.limit locals 100 ; Define your local space number.
	ldc 3
	istore 0
	ldc 3.140000
	fstore 1
	ldc 0
	istore 2
	ldc 0.0
	fstore 3
	iload 2
	iload 0
	fload 1
	f2i
	iadd
	istore 2
	fload 3
	iload 0
	i2f
	fload 1
	fadd
	fstore 3
	iload 2
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(I)V
	fload 3
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(F)V
	iload 2
	iload 0
	ldc 6.280000
	f2i
	iadd
	istore 2
	fload 3
	ldc 6
	i2f
	fload 1
	fadd
	fstore 3
	iload 2
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(I)V
	fload 3
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(F)V
	return
.end method
