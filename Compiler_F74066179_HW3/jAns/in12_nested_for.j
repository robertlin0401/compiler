.source hw3.j
.class public Main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100  ; Define your storage size.
.limit locals 100 ; Define your local space number.
	ldc 0
	istore 0
	ldc 999
	istore 1
label0:
	iload 1
	ldc 1
	istore 1
label1:
	iload 1
	ldc 9
	isub
	ifle label2
	iconst_0
	goto label3
label2:
	iconst_1
label3:
	goto label5
label4:
	iload 1
	ldc 1
	iadd
	istore 1
	goto label1
label5:
	ifeq end0
label6:
	iload 0
	ldc 1
	istore 0
label7:
	iload 0
	ldc 9
	isub
	ifle label8
	iconst_0
	goto label9
label8:
	iconst_1
label9:
	goto label11
label10:
	iload 0
	ldc 1
	iadd
	istore 0
	goto label7
label11:
	ifeq end1
	iload 1
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(I)V
	ldc "*"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	iload 0
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(I)V
	ldc "="
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	iload 1
	iload 0
	imul
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(I)V
	ldc "\t"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	goto label10
end1:
	ldc "\n"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	goto label4
end0:
	return
.end method
