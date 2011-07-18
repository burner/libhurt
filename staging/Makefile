all:
	#dmd -m64 -w -O tree.d rbtree.d -L../libhurt.a -I.. -ofrbtree
	#./rbtree
	dmd -m64 -w -O -unittest map.d hashtable.d tree.d rbtree.d bst.d -L../libhurt.a -I.. -ofmap
	./map
