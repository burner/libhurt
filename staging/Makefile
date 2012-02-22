SRC=formatter.d

#SRC=ctstr.d

all:
	dmd -debug -gc -m64 -w -unittest -version=staging $(SRC) -I. ../libhurt.a -I.. -offormatter
	./formatter
