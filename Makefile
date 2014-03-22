
test: compile
	istanbul cover _mocha -- -R spec ./test

compile:
	coffee -c ./