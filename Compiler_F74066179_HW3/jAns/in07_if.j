.source hw3.j
.class public Main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100  ; Define your storage size.
.limit locals 100 ; Define your local space number.
	ldc 0
	istore 0
	iload 0
	ldc 0
	isub
	ifeq label0
	iconst_0
	goto label1
label0:
	iconst_1
label1:
	ifeq label2
	ldc "Hello"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
label2:
end0:
	return
.end method
