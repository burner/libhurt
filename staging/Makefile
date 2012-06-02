#SRC=formatter.d

#SRC=arraytree.d arraybst.d
SRC=stringstore.d

all:
	dmd -debug -gc -m64 -w -unittest -version=staging $(SRC) -I. ../libhurt.a -I.. -ofstringstore
	./stringstore
