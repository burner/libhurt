module hurt.stdio.ioflags;

enum FileFlags {
	O_ACCMODE =	 00000003,
	O_RDONLY  =  00000000,
	O_WRONLY  =  00000001,
	O_RDWR	  =  00000002,
	O_CREAT	  =  00000100,	/* not fcntl */
	O_EXCL	  =  00000200,	/* not fcntl */
	O_NOCTTY  =  00000400,	/* not fcntl */
	O_TRUNC	  =  00001000,	/* not fcntl */
	O_APPEND  =  00002000,
	O_NONBLOCK = 00004000,
	O_DSYNC	  =  00010000,	/* used to be O_SYNC, see below */
	FASYNC	  =  00020000,	/* fcntl, for BSD compatibility */
	O_DIRECT  =  00040000,	/* direct disk access hint */
	O_LARGEFILE =00100000,
	O_DIRECTORY= 00200000,	/* must be a directory */
	O_NOFOLLOW=	 00400000,	/* don't follow links */
	O_NOATIME =	 01000000,
	O_CLOEXEC =	 02000000	/* set close_on_exec */
}

enum ModeValues {
	S_IRWXU = 0x700,
	S_IRUSR = 0x400,
	S_IWUSR = 0x200,
	S_IXUSR = 0x100,
	S_IRWXG = 0x070,
	S_IRGRP = 0x040,
	S_IWGRP = 0x020,
	S_IXGRP = 0x010,
	S_IRWXO = 0x007,
	S_IROTH = 0x004,
	S_IWOTH = 0x002,
	S_IXOTH = 0x001
}

enum SeekType {
	SEEK_SET = 0,
	SEEK_CUR = 1,
	SEEK_END = 2
}
