tester: tester.o
tester.o: testplates.h
testplates.h: convert.py
	python3 convert.py > testplates.h

.PHONY: clean
clean:
	rm tester tester.o testplates.h
