all:
	#dmd -m64 -w -O tree.d rbtree.d -L../libhurt.a -I.. -ofrbtree
	#./rbtree
	dmd -m64 -w -O -unittest set.d hashtable.d tree.d rbtree.d bst.d -L../libhurt.a -I.. -ofset
	./set
