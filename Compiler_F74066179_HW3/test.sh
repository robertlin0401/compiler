make

testList="
	in01_arithmetic 
	in02_precedence 
	in03_scope 
	in04_array 
	in05_assignment 
	in06_conversion 
	in07_if 
	in08_for 
	in11_nested_if 
	in12_nested_for
"

for test in $testList
do
	./mycompiler < input/$test.go
#	cp hw3.j jAns/$test.j
	java -jar jasmin.jar hw3.j
	java -Xverify:none Main > answer/$test.out
done

git diff answer/
rm -r answer/
cp -r copyAns/ answer/

