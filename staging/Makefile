all:
	#dmd -m64 -w -O rbtree.d -L../libhurt.a -I.. -ofrbtree
	#./rbtree
	dmd -m64 -w -O -unittest hashtable.d rbtree.d treetest.d bst.d -L../libhurt.a -I.. -oftreetest
	./treetest
