#SRC=binvec.d

#SRC=arraytree.d arraybst.d
#SRC=test.d `find hurt -name \*.d`

all:
	dmd -debug -gc -m64 -w -unittest -version=statging quaternion.d vec.d matrix.d -I. -I.. ../libhurt.a -ofmatrix
	./matrix
