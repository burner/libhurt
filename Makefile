DC=dmd
CFLAGS=-c -w

ALGO_OBJS=hurt.algo.sorting.o

CONTAINER_OBJS=hurt.container.dlst.o hurt.container.stack.o hurt.container.vector.o

MATH_OBJS=hurt.math.bigintbase10.o

STRING_OBJS=hurt.string.stringbuffer.o

UTIL_OBJS=hurt.util.stacktrace.d

all: $(ALGO_OBJS) $(CONTAINER_OBJS) $(MATH_OBJS) $(STRING_OBJS)
	ar -r libhurt.a *.o

clean:
	rm -rf *.o
	rm -rf libhurt.a

cleanAll: clean
	make -C tests clean	

test: $(ALGO_OBJS) $(CONTAINER_OBJS) $(MATH_OBJS) $(STRING_OBJS)
	make
	make -C tests

hurt.algo.sorting.o: hurt/algo/sorting.d Makefile
	$(DC) $(CFLAGS) hurt/algo/sorting.d -ofhurt.algo.sorting.o

hurt.container.vector.o: hurt/container/vector.d Makefile
	$(DC) $(CFLAGS) hurt/container/vector.d -ofhurt.container.vector.o

hurt.container.stack.o: hurt/container/stack.d Makefile
	$(DC) $(CFLAGS) hurt/container/stack.d -ofhurt.container.stack.o

hurt.container.dlst.o: hurt/container/dlst.d Makefile
	$(DC) $(CFLAGS) hurt/container/dlst.d -ofhurt.container.dlst.o

hurt.math.bigintbase10.o: hurt/math/bigintbase10.d Makefile
	$(DC) $(CFLAGS) hurt/math/bigintbase10.d -ofhurt.math.bigintbase10.o

hurt.string.stringbuffer.o: hurt/string/stringbuffer.d hurt/util/stacktrace.d Makefile
	$(DC) $(CFLAGS) hurt/string/stringbuffer.d -ofhurt.string.stringbuffer.o

hurt.util.stacktrace.o: hurt/util/stacktrace.d hurt/algo/sorting.d hurt/container/dlst.d Makefile
	$(DC) $(CFLAGS) hurt/util/stacktrace.d -ofhurt.util.stacktrace.o
