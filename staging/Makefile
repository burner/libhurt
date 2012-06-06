#SRC=formatter.d

#SRC=arraytree.d arraybst.d
SRC=test.d `find hurt -name \*.d`

all:
	dmd -debug -gc -m64 -w -unittest -version=staging $(SRC) -I. ../libhurt.a -I.. -ofnettest
	./nettest
