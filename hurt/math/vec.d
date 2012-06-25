module hurt.math.vec;

import std.math;
import hurt.conv.conv;
import hurt.util.slog;
import hurt.string.formatter;

@safe pure:
struct vec3(T) {
	T values[3];
	
	this(T a, T b, T c) {
		this.values[0] = a;
		this.values[1] = b;
		this.values[2] = c;
	}

	this(vec3!T old) {
		this(old.x, old.y, old.z);
	}

	this(const ref vec3!T old) {
		this(old.x, old.y, old.z);
	}

	void normalize() {
		double len = sqrt(conv!(T,real)((this.values[0] * this.values[0]) + 
			(this.values[1] * this.values[1]) +
			(this.values[2] * this.values[2])));

		this.values[0] = conv!(double,T)(this.values[0] / len);
		this.values[1] = conv!(double,T)(this.values[1] / len);
		this.values[2] = conv!(double,T)(this.values[2] / len);
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
		return this.values[idx];
	}

	T opIndex(size_t idx) const {
		return this.values[idx];
	}

	void opIndexAssign(T value, size_t idx) {
		this.values[idx] = value;
	}

	vec3!T opAssign(vec3!T value) {
		this.values[0] = value.x;
		this.values[1] = value.y;
		this.values[2] = value.z;
		return this;
	}

	vec3!T opUnary(string op)() const {
		static if(op == "-") {
			return vec3!T(-this.values[0], -this.values[1], -this.values[2]);
		}
		assert(false);
	}

	vec3!T opBinary(string op)(vec3!T rhs) const if(op == "+") {
		return vec3!T(this.values[0]*rhs.x, this.values[1]+rhs.y, this.values[2]+rhs.z);
	}

	T opBinary(string op)(vec3!T rhs) const if(op == "*") {
		return this.values[0]*rhs.x + this.values[1]*rhs.y + this.values[2]*rhs.z;	
		assert(false);
	}

	vec3!T opBinary(string op)(const T value) const {
		static if(op == "*") {
			return vec3!T(this.values[0] * value, 
				this.values[1] * value, 
				this.values[2] * value);
		} else static if(op == "/") {
			return vec3!T(this.values[0] / value, 
				this.values[1] / value, 
				this.values[2] / value);
		}
		assert(false);
	}

	string toString() const {
		return format("%f:%f:%f", this.values[0], this.values[1], this.values[2]);
	}

	T length() const {
		return conv!(float,T)(sqrt(
			conv!(T,real)(this.values[0] * this.values[0]) + 
			conv!(T,real)(this.values[1] * this.values[1]) + 
			conv!(T,real)(this.values[2] * this.values[2])));
	}
}

unittest {
}
