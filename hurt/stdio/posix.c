#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>

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
	return close(fd);
}
