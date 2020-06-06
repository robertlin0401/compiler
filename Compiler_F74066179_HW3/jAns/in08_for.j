.source hw3.j
.class public Main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100  ; Define your storage size.
.limit locals 100 ; Define your local space number.
	ldc 0
	istore 0
	iload 0
	ldc 10
	iadd
	istore 0
label0:
	iload 0
	ldc 0
	isub
	ifgt label1
	iconst_0
	goto label2
label1:
	iconst_1
label2:
	ifeq end0
	iload 0
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(I)V
	iload 0
	ldc 1
	isub
	istore 0
	goto label0
end0:
	return
.end method
