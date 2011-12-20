import hurt.io.stdio;

struct vec(T,size_t size) {
	T[size] data;
	static if(size == 1) {
		@property
		T x() {
			return data[0];
		}
	} else static if(size == 2) {
		@property
		T x() {
			return data[0];
		}
		@property
		T y() {
			return data[1];
		}
	} else static if(size == 3) {
		@property
		T x() {
			return data[0];
		}
		@property
		T y() {
			return data[1];
		}
		@property
		T z() {
			return data[2];
		}
	} else static if(size > 3) {
		@property
		T x() {
			return data[0];
		}
		@property
		T y() {
			return data[1];
		}
		@property
		T z() {
			return data[2];
		}
		@property
		T w() {
			return data[3];
		}
	}

	this(T[size] args...) {
		assert(args.length == data.length);
		foreach(size_t idx, T it; args) {
			this.data[idx] = it;
		}
	}
}

struct mat(T, size_t rows, size_t columns) {
	T[columns][rows] data;
	
	this(T[columns][rows] args...) {
		foreach(size_t idx, int[] it; args) {
			foreach(size_t jdx, int jt; it) {
				data[idx][jdx] = jt;
			}
		}
	}
}

void main() {
	vec!(int,3) a = vec!(int,3)(11,22,33);
	printfln("%d %d %d", a.data[0], a.data[1], a.data[2]);
	printfln("%d %d %d", a.x, a.y, a.z);
	mat!(int,4,4) ma;
	foreach(size_t idx, int[] it; ma.data) {
		foreach(size_t jdx, int jt; it) {
			printf("%d %d, ", idx, jdx);
		}
		printfln("\n");
	}
}
