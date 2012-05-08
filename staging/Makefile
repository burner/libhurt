#SRC=formatter.d

#SRC=arraytree.d arraybst.d
SRC=lru.d

all:
	dmd -debug -gc -m64 -w -unittest -version=staging $(SRC) -I. ../libhurt.a -I.. -oflru
	./lru
