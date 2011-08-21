src = Split('''
hurt/algo/sorting.d
hurt/container/bitmap.d
hurt/container/dlst.d
hurt/container/iterator.d
hurt/container/multimap.d
hurt/container/set.d
hurt/container/vector.d
hurt/container/bst.d
hurt/container/hashtable.d
hurt/container/list.d
hurt/container/pairlist.d
hurt/container/stack.d
hurt/container/deque.d
hurt/container/isr.d
hurt/container/map.d
hurt/container/rbtree.d
hurt/container/tree.d
''')

src += Split('''
hurt/algo/sorting.d
''')

src += Split('''
hurt/conv/charconv.d
hurt/conv/conv.d
hurt/conv/convutil.d
hurt/conv/tointeger.d
hurt/conv/chartonumeric.d
hurt/conv/numerictochar.d
hurt/conv/tostring.d
''')

src += Split('''
hurt/exception/exception.d
hurt/exception/illegalargumentexception.d
hurt/exception/ioexception.d
hurt/exception/outofrangeexception.d
hurt/exception/formaterror.d
hurt/exception/invaliditeratorexception.d
hurt/exception/nullexception.d
hurt/exception/valuerangeexception.d
''')

src += Split('''
hurt/io/file.d
hurt/io/inputstream.d
hurt/io/ioflags.d
hurt/io/posix.c
hurt/io/stdio.d
hurt/io/stream.d
''')

src += Split('''
hurt/math/bigintbase10.d
hurt/math/mathutil.d
''')

src += Split('''
hurt/string/formatter.d
hurt/string/stringbuffer.d
hurt/string/stringutil.d
hurt/string/utf.d
''')

src += Split('''
hurt/util/array.d
hurt/util/crc32.d
hurt/util/datetime.d
hurt/util/milli.c
hurt/util/random.d
hurt/util/stacktrace.d
hurt/util/util.d
hurt/util/getopt.d
''')

lib = Library(target = 'hurt', source=src, CCFLAGS = '-Wall -ggdb', DFLAGS = Split("-unittest -gc -g"))
