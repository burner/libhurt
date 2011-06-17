DC=dmd
#CFLAGS=-c -w -gc -d-debug -m64
CFLAGS=-c -w -gc -debug -m64 -unittest
CCFLAGS=-c -Wall -m64 -static

ALGO_OBJS=hurt.algo.sorting.o

CONTAINER_OBJS= hurt.container.bitmap.o hurt.container.dlst.o hurt.container.list.o hurt.container.multimap.o \
hurt.container.pairlist.o hurt.container.set.o hurt.container.stack.o hurt.container.vector.o \
hurt.container.rbtree.o hurt.container.map.o hurt.container.deque.o

EXCEPTION_OBJS=hurt.exception.illegalargumentexception.o hurt.exception.valuerangeexception.o hurt.exception.nullexception.o \
hurt.exception.outofrangeexception.o hurt.exception.formaterror.o hurt.exception.invaliditeratorexception.o

MATH_OBJS=hurt.math.mathutil.o hurt.math.bigintbase10.o

STRING_OBJS=hurt.string.stringbuffer.o hurt.string.stringutil.o hurt.string.formatter.o

UTIL_OBJS=hurt.util.array.o hurt.util.stacktrace.o hurt.util.milli.o hurt.util.random.o \
hurt.util.datetime.o

CONV_OBJS=hurt.conv.chartonumeric.o hurt.conv.charconv.o hurt.conv.conv.o hurt.conv.convutil.o \
hurt.conv.numerictochar.o hurt.conv.tointeger.o hurt.conv.tostring.o

IO_OBJS=hurt.io.ioflags.o hurt.io.posix.o hurt.io.file.o hurt.io.inputstream.o \
hurt.io.stdio.o

all: $(ALGO_OBJS) $(CONTAINER_OBJS) $(EXCEPTION_OBJS) $(STRING_OBJS) $(UTIL_OBJS) $(CONV_OBJS) $(MATH_OBJS) $(IO_OBJS)
	ar -r libhurt.a *.o

clean:
	rm -rf *.o
	rm -rf libhurt.a

cleanAll: clean
	make -C tests clean	

new: clean all
	

count:
	wc -l `find . -name \*.d && find . -name \*.c`

test: $(ALGO_OBJS) $(CONTAINER_OBJS) $(MATH_OBJS) $(STRING_OBJS)
	make
	make -C tests

hurt.algo.sorting.o: hurt/algo/sorting.d Makefile
	$(DC) $(CFLAGS) hurt/algo/sorting.d -ofhurt.algo.sorting.o

hurt.container.vector.o: hurt/container/vector.d Makefile
	$(DC) $(CFLAGS) hurt/container/vector.d -ofhurt.container.vector.o

hurt.container.pairlist.o: hurt/container/pairlist.d Makefile
	$(DC) $(CFLAGS) hurt/container/pairlist.d -ofhurt.container.pairlist.o

hurt.container.stack.o: hurt/container/stack.d Makefile
	$(DC) $(CFLAGS) hurt/container/stack.d -ofhurt.container.stack.o

hurt.container.rbtree.o: hurt/container/rbtree.d Makefile
	$(DC) $(CFLAGS) hurt/container/rbtree.d -ofhurt.container.rbtree.o

hurt.container.map.o: hurt/container/map.d hurt/container/rbtree.d Makefile
	$(DC) $(CFLAGS) hurt/container/map.d -ofhurt.container.map.o

hurt.container.dlst.o: hurt/container/dlst.d Makefile
	$(DC) $(CFLAGS) hurt/container/dlst.d -ofhurt.container.dlst.o

hurt.container.list.o: hurt/container/list.d Makefile
	$(DC) $(CFLAGS) hurt/container/list.d -ofhurt.container.list.o

hurt.container.set.o: hurt/container/set.d hurt/container/rbtree.d Makefile
	$(DC) $(CFLAGS) hurt/container/set.d -ofhurt.container.set.o

hurt.container.multimap.o: hurt/container/multimap.d hurt/container/rbtree.d hurt/container/dlst.d hurt/container/iterator.d hurt/util/array.d Makefile
	$(DC) $(CFLAGS) hurt/container/multimap.d -ofhurt.container.multimap.o

hurt.container.bitmap.o: hurt/container/bitmap.d Makefile
	$(DC) $(CFLAGS) hurt/container/bitmap.d -ofhurt.container.bitmap.o

hurt.container.deque.o: hurt/container/deque.d Makefile
	$(DC) $(CFLAGS) hurt/container/deque.d -ofhurt.container.deque.o

hurt.math.mathutil.o: hurt/math/mathutil.d Makefile
	$(DC) $(CFLAGS) hurt/math/mathutil.d -ofhurt.math.mathutil.o

hurt.math.bigintbase10.o: hurt/math/bigintbase10.d Makefile
	$(DC) $(CFLAGS) hurt/math/bigintbase10.d -ofhurt.math.bigintbase10.o

hurt.string.stringbuffer.o: hurt/string/stringbuffer.d hurt/util/stacktrace.d Makefile
	$(DC) $(CFLAGS) hurt/string/stringbuffer.d -ofhurt.string.stringbuffer.o

hurt.string.stringutil.o: hurt/string/stringutil.d hurt/util/stacktrace.d Makefile
	$(DC) $(CFLAGS) hurt/string/stringutil.d -ofhurt.string.stringutil.o

hurt.string.formatter.o: hurt/string/formatter.d Makefile
	$(DC) $(CFLAGS) hurt/string/formatter.d -ofhurt.string.formatter.o

hurt.util.array.o: hurt/util/array.d Makefile
	$(DC) $(CFLAGS) hurt/util/array.d -ofhurt.util.array.o

hurt.util.stacktrace.o: hurt/util/stacktrace.d hurt/algo/sorting.d hurt/container/dlst.d Makefile
	$(DC) $(CFLAGS) hurt/util/stacktrace.d -ofhurt.util.stacktrace.o

hurt.util.random.o: hurt/util/random.d Makefile
	$(DC) $(CFLAGS) hurt/util/random.d -ofhurt.util.random.o

hurt.util.datetime.o: hurt/util/datetime.d Makefile
	$(DC) $(CFLAGS) hurt/util/datetime.d -ofhurt.util.datetime.o

hurt.util.milli.o: hurt/util/milli.c Makefile
	gcc $(CCFLAGS) hurt/util/milli.c -o hurt.util.milli.o

hurt.conv.conv.o: hurt/conv/conv.d hurt/conv/charconv.d hurt/conv/tointeger.d hurt/conv/tostring.d Makefile
	$(DC) $(CFLAGS) hurt/conv/conv.d -ofhurt.conv.conv.o

hurt.conv.charconv.o: hurt/conv/charconv.d hurt/conv/charconv.d Makefile
	$(DC) $(CFLAGS) hurt/conv/charconv.d -ofhurt.conv.charconv.o

hurt.conv.chartonumeric.o: hurt/conv/chartonumeric.d Makefile
	$(DC) $(CFLAGS) hurt/conv/chartonumeric.d -ofhurt.conv.chartonumeric.o

hurt.conv.convutil.o: hurt/conv/convutil.d Makefile
	$(DC) $(CFLAGS) hurt/conv/convutil.d -ofhurt.conv.convutil.o

hurt.conv.tointeger.o: hurt/conv/tointeger.d hurt/conv/convutil.d hurt/conv/chartonumeric.d Makefile
	$(DC) $(CFLAGS) hurt/conv/tointeger.d -ofhurt.conv.tointeger.o

hurt.conv.tostring.o: hurt/conv/tostring.d hurt/conv/tostring.d Makefile
	$(DC) $(CFLAGS) hurt/conv/tostring.d -ofhurt.conv.tostring.o

hurt.conv.numerictochar.o: hurt/conv/numerictochar.d Makefile
	$(DC) $(CFLAGS) hurt/conv/numerictochar.d -ofhurt.conv.numerictochar.o

hurt.exception.illegalargumentexception.o: hurt/exception/illegalargumentexception.d Makefile
	$(DC) $(CFLAGS) hurt/exception/illegalargumentexception.d -ofhurt.exception.illegalargumentexception.o

hurt.exception.valuerangeexception.o: hurt/exception/valuerangeexception.d Makefile
	$(DC) $(CFLAGS) hurt/exception/valuerangeexception.d -ofhurt.exception.valuerangeexception.o

hurt.exception.outofrangeexception.o: hurt/exception/outofrangeexception.d Makefile
	$(DC) $(CFLAGS) hurt/exception/outofrangeexception.d -ofhurt.exception.outofrangeexception.o

hurt.exception.nullexception.o: hurt/exception/nullexception.d Makefile
	$(DC) $(CFLAGS) hurt/exception/nullexception.d -ofhurt.exception.nullexception.o

hurt.exception.formaterror.o: hurt/exception/formaterror.d Makefile
	$(DC) $(CFLAGS) hurt/exception/formaterror.d -ofhurt.exception.formaterror.o

hurt.exception.invaliditeratorexception.o: hurt/exception/invaliditeratorexception.d Makefile
	$(DC) $(CFLAGS) hurt/exception/invaliditeratorexception.d -ofhurt.exception.invaliditeratorexception.o

hurt.io.ioflags.o: hurt/io/ioflags.d Makefile
	$(DC) $(CFLAGS) hurt/io/ioflags.d -ofhurt.io.ioflags.o

hurt.io.stdio.o: hurt/io/stdio.d hurt/string/formatter.d hurt/conv/conv.d Makefile
	$(DC) $(CFLAGS) hurt/io/stdio.d -ofhurt.io.stdio.o

hurt.io.inputstream.o: hurt/io/inputstream.d Makefile
	$(DC) $(CFLAGS) hurt/io/inputstream.d -ofhurt.io.inputstream.o

hurt.io.posix.o: hurt/io/posix.c Makefile
	gcc $(CCFLAGS) hurt/io/posix.c -o hurt.io.posix.o

hurt.io.file.o:hurt/io/file.d Makefile
	$(DC) $(CFLAGS) hurt/io/file.d -ofhurt.io.file.o
