make

testList="
	in01_arithmetic 
	in02_precedence 
	in03_scope
"

for test in $testList
do
	./mycompiler < input/$test.go
	java -jar jasmin.jar hw3.j
	java Main > answer/$test.out
done

git diff answer/
rm -r answer/
cp -r copyAns/ answer/

