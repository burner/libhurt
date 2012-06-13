import std.math;
import hurt.conv.conv;
import hurt.util.slog;

pure @safe:
struct vec3(T) {
	T values[3];
	
	this(T a, T b, T c) {
		values[0] = a;
		values[1] = b;
		values[2] = c;
	}

	void normalize() {
		double len = sqrt(conv!(T,real)((values[0] * values[0]) + 
			(values[1] * values[1]) +
			(values[2] * values[2])));

		values[0] = conv!(double,T)(values[0] / len);
		values[1] = conv!(double,T)(values[1] / len);
		values[2] = conv!(double,T)(values[2] / len);
	}

	T opIndex(size_t idx) {
		return values[idx];
	}

	T opIndex(size_t idx) const {
		return values[idx];
	}

	T opBinary(string op)(vec3!T rhs) if(op == "*") {
		return this.values[0] * rhs.values[0];
	}
}

unittest {
	auto a = vec3!int(1,2,3);
	auto b = vec3!int(4,5,6);
	assert(a * b == 4);
}
