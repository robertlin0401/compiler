.source hw3.j
.class public Main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100  ; Define your storage size.
.limit locals 100 ; Define your local space number.
	ldc 400
	istore 0
	ldc 700
	istore 1
	iload 0
	ldc 400
	isub
	ifeq label0
	iconst_0
	goto label1
label0:
	iconst_1
label1:
	ifeq label2
	iload 1
	ldc 600
	isub
	ifle label3
	iconst_0
	goto label4
label3:
	iconst_1
label4:
	ifeq label5
	ldc "OuO\n"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	goto end0
label5:
	iload 1
	ldc 700
	isub
	ifeq label6
	iconst_0
	goto label7
label6:
	iconst_1
label7:
	ifeq label8
	ldc "Value of v1 is 400 and v2 is 700"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	goto end1
label8:
	ldc "QuQ\n"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
end1:
label2:
end0:
	return
.end method
