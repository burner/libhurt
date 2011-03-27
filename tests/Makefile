DC=dmd
CFLAGS=-w -gc -I../ -L../libphobos2.a -L../libhurt.a -debug

TESTS=convtest stacktest stringutiltest vectortest pairlisttest

all:tests

tests: $(TESTS)

new: clean tests

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
	#exec ./vectortest

pairlisttest: pairlisttest.d Makefile
	$(DC) $(CFLAGS) pairlisttest.d
	exec ./pairlisttest

clean:
	rm -rf *.o
	rm -rf $(TESTS)
