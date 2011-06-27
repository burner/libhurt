all:
	dmd -m64 -w -unittest -debug -gc treetest.d rbtree.d bst.d -L../libhurt.a -I.. -oftreetest
	./treetest
