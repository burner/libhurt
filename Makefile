all: 
	./IncreBuildId.sh
	scons -j3

clean:
	rm -rf libhurt.a
	scons --clean

cleanAll: clean
	make -C tests clean	

count:
	wc -l `find hurt tests -name \*.d && find hurt tests -name \*.c`

unittest:
	dmd -m64 unit.d -Llibhurt.a -unittest -debug -gc -gs -I. 
	./unit

unit: all 
	dmd -m64 unit.d -Llibhurt.a -unittest -debug -gc -gs -I. 
	./unit

new: clean all
