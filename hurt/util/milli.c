#include <sys/time.h>

long getMilli() {
	struct timeval tv;
	gettimeofday(&tv, 0);
	return (tv.tv_sec*1000 + tv.tv_usec/1000.0)+0.5;
}
