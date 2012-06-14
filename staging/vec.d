module hurt.math.vec;

import std.math;
import hurt.conv.conv;
import hurt.util.slog;
import hurt.string.formatter;

@safe pure:
struct vec3(T) {
	T values[3];
	
	this(T a, T b, T c) {
		values[0] = a;
		values[1] = b;
		values[2] = c;
	}

	this(vec3!T old) {
		this(old.x, old.y, old.z);
	}

	this(const ref vec3!T old) {
		this(old.x, old.y, old.z);
	}

	void normalize() {
		double len = sqrt(conv!(T,real)((values[0] * values[0]) + 
			(values[1] * values[1]) +
			(values[2] * values[2])));

		values[0] = conv!(double,T)(values[0] / len);
		values[1] = conv!(double,T)(values[1] / len);
		values[2] = conv!(double,T)(values[2] / len);
	}

	@property T x(T value) {
		return this.values[0] = value;
	}

	@property T y(T value) {
		return this.values[1] = value;
	}

	@property T z(T value) {
		return this.values[2] = value;
	}

	@property T x() const {
		return this.values[0];
	}

	@property T y() const {
		return this.values[1];
	}

	@property T z() const {
		return this.values[2];
	}

	T opIndex(size_t idx) {
		return values[idx];
	}

	T opIndex(size_t idx) const {
		return values[idx];
	}

	void opIndexAssign(T value, size_t idx) {
		values[idx] = value;
	}

	vec3!T opAssign(vec3!T value) {
		values[0] = value.x;
		values[1] = value.y;
		values[2] = value.z;
		return this;
	}

	vec3!T opUnary(string op)() const {
		static if(op == "-") {
			return vec3!T(-values[0], -values[1], -values[2]);
		}
		assert(false);
	}

	vec3!T opBinary(string op)(vec3!T rhs) const if(op == "+") {
		return vec3!T(values[0]*rhs.x, values[1]+rhs.y, values[2]+rhs.z);
	}

	T opBinary(string op)(vec3!T rhs) const if(op == "*") {
		return values[0]*rhs.x + values[1]*rhs.y + values[2]*rhs.z;	
		assert(false);
	}

	vec3!T opBinary(string op)(const T value) const {
		static if(op == "*") {
			return vec3!T(values[0] * value, 
				values[1] * value, 
				values[2] * value);
		} else static if(op == "/") {
			return vec3!T(values[0] / value, 
				values[1] / value, 
				values[2] / value);
		}
		assert(false);
	}

	string toString() const {
		return format("%f:%f:%f", values[0], values[1], values[2]);
	}

	T length() const {
		return conv!(float,T)(sqrt(
			conv!(T,real)(values[0] * values[0]) + 
			conv!(T,real)(values[1] * values[1]) + 
			conv!(T,real)(values[2] * values[2])));
	}
}

unittest {
}
