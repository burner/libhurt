DC=dmd
#CFLAGS=-w -gc -I../ -L../libhurt.a -debug -m64 
CFLAGS=-w -gc -I../ -L../libhurt.a -debug -m64 -unittest
#CFLAGS=-w -gc -I../ -debug -m64

#TESTS=convtest stacktest stringutiltest vectortest pairlisttest utiltest dlsttest unit maptest
TESTS=settest

all:tests

tests: $(TESTS)

new: clean tests

printtest: printtest.d Makefile
	$(DC) $(CFLAGS) printtest.d
	exec ./printtest

filetest: filetest.d Makefile
	$(DC) $(CFLAGS) filetest.d
	exec ./filetest

maptest: maptest.d Makefile
	$(DC) $(CFLAGS) maptest.d
	exec ./maptest

settest: settest.d Makefile
	$(DC) $(CFLAGS) settest.d
	exec ./settest

rbtreetest: rbtreetest.d Makefile
	$(DC) $(CFLAGS) rbtreetest.d
	exec ./rbtreetest

convtest: convtest.d Makefile
	$(DC) $(CFLAGS) convtest.d
	exec ./convtest

unit: unit.d Makefile
	$(DC) $(CFLAGS) unit.d
	exec ./unit

stacktest: stacktest.d Makefile
	$(DC) $(CFLAGS) stacktest.d
	exec ./stacktest

stringutiltest: stringutiltest.d Makefile
	$(DC) $(CFLAGS) stringutiltest.d
	exec ./stringutiltest

vectortest: vectortest.d Makefile
	$(DC) $(CFLAGS) vectortest.d
	exec ./vectortest

dlsttest: dlsttest.d Makefile
	$(DC) $(CFLAGS) dlsttest.d
	exec ./dlsttest

pairlisttest: pairlisttest.d Makefile
	$(DC) $(CFLAGS) pairlisttest.d
	exec ./pairlisttest

utiltest: utiltest.d Makefile
	$(DC) $(CFLAGS) utiltest.d
	exec ./utiltest

clean:
	rm -rf *.o
	rm -rf $(TESTS)
