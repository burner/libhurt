all:
	#dmd -m64 -w -O tree.d rbtree.d -L../libhurt.a -I.. -ofrbtree
	#./rbtree
	dmd -m64 -w -O -unittest hashtable.d tree.d rbtree.d treetest.d bst.d -L../libhurt.a -I.. -oftreetest
	./treetest
