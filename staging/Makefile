SRC=hurt/util/random/engines/cmwc.d \
hurt/util/random/engines/twister.d \
hurt/util/random/engines/kiss.d \
hurt/util/random/engines/kisscmwc.d \
hurt/util/random/engines/sync.d \
hurt/util/random/engines/urandom.d \
hurt/util/random/engines/arraysource.d \
hurt/util/random/twister.d \
hurt/util/random/ziggurat.d \
hurt/util/random/kiss.d \
hurt/util/random/random.d \
hurt/util/random/normalsource.d \
hurt/util/random/expsource.d \
hurt/math/bracket.d \
rand.d

#SRC=stdin.d

all:
	dmd -debug -gc -m64 -w -unittest cin.o -version=staging $(SRC) -I. ../libhurt.a -I.. -ofrand
	./rand
