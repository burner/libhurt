all: 
	scons -j3

clean:
	rm -rf libhurt.a
	scons --clean

cleanAll: clean
	make -C tests clean	

count:
	wc -l `find hurt tests -name \*.d && find hurt tests -name \*.c`

new: clean all
