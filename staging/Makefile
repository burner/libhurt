SRC=multiset.d

#SRC=arraytree.d arraybst.d
#SRC=test.d `find hurt -name \*.d`

all:
	dmd -debug -gc -m64 -w -unittest -version=statging ${SRC} -I. -I.. ../libhurt.a -of${SRC}exec
	./${SRC}exec
	#dmd -debug -gc -m64 -w -unittest -version=statging quat.d vec.d matrix.d -I. -I.. ../libhurt.a -ofmatrix
	#./matrix

