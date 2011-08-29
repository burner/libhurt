SRC=hurt/time/wallclock.d hurt/time/time.d hurt/time/stopwatch.d \
hurt/time/iso8601.d hurt/time/clock.d hurt/time/chrono/calender.d \
hurt/time/chrono/gregorian.d hurt/time/chrono/hijri.d \
hurt/time/chrono/korean.d hurt/time/chrono/thaibuddhist.d \
hurt/time/chrono/gregorianbased.d hurt/time/chrono/hebrew.d \
hurt/time/chrono/japanese.d hurt/time/chrono/taiwan.d

all:
	#dmd -m64 -w -O tree.d rbtree.d -L../libhurt.a -I.. -ofrbtree
	#./rbtree
	dmd -debug -gc -m64 -w -O -unittest $(SRC) timemain.d -I. -L../libhurt.a -I.. -oftimemain
	./timemain
