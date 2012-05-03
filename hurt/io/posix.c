#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <errno.h>
#include <math.h>

int flushCStdout() {
	return fflush(stdout);
}

int writeC(int fd, const void *buf, size_t count) {
	return write(fd, buf, count);
}

int fsyncC(int fd) {
	return fsyncC(fd);
}

int openC(const char *name, unsigned int flags, unsigned int mode) {
	int f = open(name, flags, mode);
	return f;
}

int closeC(const int fd) {
	//return close(fd);
	return 0;
}

long getFdSize(const int fd) {
	struct stat s;
	fstat(fd, &s);
	return s.st_size;
}

int seekC(const int fd, const long offset, const int st) {
	return lseek(fd, offset, st);
}

long readC(const int fd, void *buf, const long count) {
	return read(fd, buf, count);
}

int getErrno() {
	return errno;
}

double sqrtC(double x) {
	return sqrt(x);
}
