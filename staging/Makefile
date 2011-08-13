all:
	#dmd -m64 -w -O tree.d rbtree.d -L../libhurt.a -I.. -ofrbtree
	#./rbtree
	dmd -debug -gc -m64 -w -O -unittest inputstream.d exception.d util.d stream.d crc32.d utf.d system.d -L../libhurt.a -I.. -ofinputstream
	./inputstream
