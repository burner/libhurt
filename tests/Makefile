DC=dmd
CFLAGS=-w -I../ -L../libhurt.a

TESTS=convtest stacktest stringutiltest vectortest

all:tests

tests: $(TESTS)

convtest: convtest.d Makefile
	$(DC) $(CFLAGS) convtest.d
	exec ./convtest

stacktest: stacktest.d Makefile
	$(DC) $(CFLAGS) stacktest.d
	exec ./stacktest

stringutiltest: stringutiltest.d Makefile
	$(DC) $(CFLAGS) stringutiltest.d
	exec ./stringutiltest

vectortest: vectortest.d Makefile
	$(DC) $(CFLAGS) vectortest.d
	exec ./vectortest

clean:
	rm -rf *.o
	rm -rf $(TESTS)
