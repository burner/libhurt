#SRC=formatter.d

SRC=binvec.d

all:
	dmd -debug -gc -m64 -w -unittest -version=staging $(SRC) -I. ../libhurt.a -I.. -ofbinvec
	./binvec
