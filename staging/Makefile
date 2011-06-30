all:
	#dmd -m64 -w -O hashtable.d -L../libhurt.a -I.. -ofhashtable
	#./hashtable
	dmd -m64 -w -O -unittest hashtable.d rbtree.d treetest.d bst.d -L../libhurt.a -I.. -oftreetest
	./treetest
