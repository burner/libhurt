SRC=mapset.d

all:
	dmd -debug -gc -m64 -w -unittest $(SRC) -I. ../libhurt.a -I.. -ofmapset
	./mapset
