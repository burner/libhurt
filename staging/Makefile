all:
	#dmd -m64 -w -O tree.d rbtree.d -L../libhurt.a -I.. -ofrbtree
	#./rbtree
	dmd -debug -gc -m64 -w -O -unittest inputstream.d exception.d stream.d utf.d -L../libhurt.a -I.. -ofinputstream
	./inputstream
