module hurt.io.inputstream;

import hurt.io.file;
import hurt.io.ioflags;
import hurt.io.stdio;

import hurt.conv.conv;
import hurt.conv.tostring;
import hurt.container.vector;
import hurt.string.stringbuffer;

import std.stdio;

class InputStream {
	int fd;
	enum BOM {
		UTF8,
		UTF16,
		UTF32
	}
	
	BOM encoding;
	Vector!(ubyte) buf;
	StringBuffer!(char) sbchar;

	this(string fileName) {
		this.fd = open(fileName, FileFlags.O_RDONLY, 0);
		int error = getErrno();
		assert(error == 0, errnoToString(error));
		this.sbchar = new StringBuffer!(char)();
		acquireBOM();
	}

	void acquireBOM() {
		seek(this.fd, 0,SeekType.SEEK_SET);	
		ubyte[] readb = new ubyte[4];
		long rcnt = read(fd, cast(byte[])readb, 4);
		if(rcnt >= 4 && readb[0] == 0xEF && readb[1] == 0xBB && readb[2] == 0xBF) {
			this.encoding = BOM.UTF8;
		} else if(rcnt >= 4 && (readb[0] == 255 && readb[1] == 254 && readb[2] == 0 && 
				readb[3] == 0) ||(readb[3] == 0xFF && readb[2] == 0xFE && readb[1] == 0 
				&& readb[1] == 0)) {
			this.encoding = BOM.UTF32;
		} else if(rcnt >= 4 && (readb[0] == 0xFE && readb[1] == 0xFF)
				|| (readb[1] == 0xFE && readb[0] == 0xFF)){
			this.encoding = BOM.UTF16;
		} else {
			this.encoding = BOM.UTF8;
			seek(this.fd, 0,SeekType.SEEK_SET);	
		}
	}

	string getBOM() const {
		if(this.encoding == BOM.UTF16) {
			return "UTF16";
		} else if(this.encoding == BOM.UTF32) {
			return "UTF32";
		} else {
			return "UTF8";
		}
	}

	string readLine() {
		byte[128] tmp;
		char b;
		long rcnt = read(fd, tmp, 128);
		void[] ba = cast(void[])(&b);
		rcnt = read(fd, cast(byte[])(&b), b.sizeof);
		for(int i = 0; i < rcnt; i++)
			print(integerToString!(char,ubyte)(cast(ubyte)tmp[i], 2));
		println();
		char a;
		println(a, cast(char)(tmp[0] | tmp[1] | tmp[2]));
		println("ö", cast(char)(tmp[0]), b);
		return null;
	}

	~this() {
		this.close();
	}

	void close() {
		hurt.io.file.close(fd);
	}
}

void main() {
	InputStream ins = new InputStream("utf8");
	println(ins.getBOM());
	string line = ins.readLine();
}
