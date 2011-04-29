#include <sys/time.h>

long getTicks() {
	struct timeval tv;
	gettimeofday (&tv, 0x0);
	return tv.tv_usec / 1000;
}
