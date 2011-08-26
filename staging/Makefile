all:
	#dmd -m64 -w -O tree.d rbtree.d -L../libhurt.a -I.. -ofrbtree
	#./rbtree
	dmd -debug -gc -m64 -w -O -unittest foralldchar.d -L../libhurt.a -I.. -offoralldchar
	./foralldchar
