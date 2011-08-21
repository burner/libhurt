all:
	#dmd -m64 -w -O tree.d rbtree.d -L../libhurt.a -I.. -ofrbtree
	#./rbtree
	dmd -debug -gc -m64 -w -O -unittest getopt -L../libhurt.a -I.. -ofgetopt
	./getopt --foo 5 --bar 4 -h --tar -d myFile
