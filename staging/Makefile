SRC=deque.d

all:
	dmd -debug -gc -m64 -w -O -unittest $(SRC) -I. -L../libhurt.a -I.. -ofdeque
	./deque
