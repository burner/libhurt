DC=dmd
CFLAGS=-w -I../ -L../libhurt.a

TESTS=convtest stacktest

all:tests

tests: $(TESTS)

convtest: convtest.d Makefile
	$(DC) $(CFLAGS) convtest.d
	exec ./convtest

stacktest: stacktest.d Makefile
	$(DC) $(CFLAGS) stacktest.d
	exec ./stacktest

clean:
	rm -rf *.o
	rm -rf $(TESTS)
