SRC=binarysearchrange.d

all:
	dmd -debug -gc -m64 -w -O -unittest $(SRC) -I. -L../libhurt.a -I.. -ofbinarysearchrange
	./binarysearchrange
