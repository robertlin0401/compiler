./myparser < input/in01_arithmetic.go > answer/in01_arithmetic.out
./myparser < input/in02_precedence.go > answer/in02_precedence.out
./myparser < input/in03_scope.go > answer/in03_scope.out
./myparser < input/in04_array.go > answer/in04_array.out
./myparser < input/in05_assignment.go > answer/in05_assignment.out
./myparser < input/in06_conversion.go > answer/in06_conversion.out
./myparser < input/in07_if.go > answer/in07_if.out
./myparser < input/in08_for.go > answer/in08_for.out
./myparser < input/in09_type_error.go > answer/in09_type_error.out
./myparser < input/in10_variable_error.go > answer/in10_variable_error.out
./myparser < input/in11_monster.go > answer/in11_monster.out
git diff answer/
rm -r answer/
cp -r copyAns/ answer/

