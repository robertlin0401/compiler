make

testList="
	in01_arithmetic
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

