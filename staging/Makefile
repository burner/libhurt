#SRC=formatter.d

#SRC=arraytree.d arraybst.d
SRC=crs.d

all:
	dmd -debug -gc -m64 -w -unittest -version=staging $(SRC) -I. ../libhurt.a -I.. -ofcrs
	./crs
