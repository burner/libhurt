DC=dmd
CFLAGS=-w -I../ -L../libhurt.a

TESTS=stacktest

stacktest: stacktest.d Makefile
	$(DC) $(CFLAGS) stacktest.d
	exec ./stacktest

clean:
	rm -rf *.o
	rm -rf $(TESTS)
	
