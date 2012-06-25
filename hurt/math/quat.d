module hurt.math.quat;

// nice quaternion

import hurt.math.vec;
import hurt.math.matrix;
import hurt.util.slog;
import hurt.string.formatter;

import std.math;

immutable double PIOVER180 = std.math.PI / 180.0;

pure @safe:
struct quat(T : float) {
	
	T q[4];

	this(T yaw, T pitch, T roll) {
		this.fromEuler(yaw, pitch, roll);
	}

	this(const quat!T old) {
		this.q[0] = old.q[0];
		this.q[1] = old.q[1];
		this.q[2] = old.q[2];
		this.q[3] = old.q[3];
	}


	this(T x, T y, T z, T w) {
		this.q[0] = x;
		this.q[1] = y;
		this.q[2] = z;
		this.q[3] = w;
	}

	void normalize() {
		T mag2 = this.q[3] * this.q[3] + this.q[0] * this.q[0] + this.q[1] * this.q[1] + this.q[2] * this.q[2];
		T mag = sqrt(mag2);

		this.q[0] /= mag;
		this.q[1] /= mag;
		this.q[2] /= mag;
		this.q[3] /= mag;
	}

	quat getConjugate() const {
		return quat(-this.q[0], -this.q[1], -this.q[2], this.q[3]);
	}

	quat opBinary(string op)(const quat rq) const if(op == "*") {
	// the constructor takes its arguments as (x, y, z, w)
		return quat!T(
			this.q[3] * rq.q[0] + this.q[0] * rq.q[3] + this.q[1] * rq.q[2] - this.q[2] * rq.q[1],
			this.q[3] * rq.q[1] + this.q[1] * rq.q[3] + this.q[2] * rq.q[0] - this.q[0] * rq.q[2],
			this.q[3] * rq.q[2] + this.q[2] * rq.q[3] + this.q[0] * rq.q[1] - this.q[1] * rq.q[0],
			this.q[3] * rq.q[3] - this.q[0] * rq.q[0] - this.q[1] * rq.q[1] - this.q[2] * rq.q[2]);
	}

	vec3!T opBinary(string op)(const vec3!T vec) const {
		vec3!T vn = vec3!T(vec);
		vn.normalize();
 
		quat vecQuat, resQuat;
		vecQuat.x = vn.x;
		vecQuat.y = vn.y;
		vecQuat.z = vn.z;
		vecQuat.w = 0.0f;
 
		resQuat = vecQuat * getConjugate();
		resQuat = this * resQuat;
 
		return vec3!T(resQuat.x, resQuat.y, resQuat.z);
	}

	void fromEuler(T pitch, T yaw, T roll) {
		// Basically we create 3 Quaternions, one for pitch, one for yaw, one for roll
		// and multiply those together.
		// the calculation below does the same, just shorter
		//log("%f", PIOVER180);
	 
		T p = pitch * PIOVER180 / 2.0;
		T y = yaw * PIOVER180 / 2.0;
		T r = roll * PIOVER180 / 2.0;

		//log("%f:%f:%f",p,y,r);
	 
		T sinp = sin(p);
		T siny = sin(y);
		T sinr = sin(r);
		T cosp = cos(p);
		T cosy = cos(y);
		T cosr = cos(r);

		//log("%f:%f:%f:%f:%f:%f",sinp, siny, sinr, cosp, cosy, cosr);
	 
		this.q[0] = sinr * cosp * cosy - cosr * sinp * siny;
		this.q[1] = cosr * sinp * cosy + sinr * cosp * siny;
		this.q[2] = cosr * cosp * siny - sinr * sinp * cosy;
		this.q[3] = cosr * cosp * cosy + sinr * sinp * siny;
	 
		this.normalize();
	}

	mat!(T,4,4) getMatrix() const {
		T x2 = this.x * this.x;
		T y2 = this.y * this.y;
		T z2 = this.z * this.z;
		T xy = this.x * this.y;
		T xz = this.x * this.z;
		T yz = this.y * this.z;
		T wx = this.w * this.x;
		T wy = this.w * this.y;
		T wz = this.w * this.z;
 
		// This calculation would be a lot more complicated for non-unit length
		//quaternions Note: The constructor of Matrix4 expects the Matrix in
		//column-major format like expected by OpenGL
		return mat!(T,4,4)([1.0 - 2.0 * (y2 + z2), 2.0 * (xy - wz), 
			2.0 * (xz + wy), 0.0, 2.0 * (xy + wz), 1.0 - 2.0 * (x2 + z2), 
			2.0 * (yz - wx), 0.0, 2.0 * (xz - wy), 2.0 * (yz + wx), 
			1.0 - 2.0 * (x2 + y2), 0.0, 0.0, 0.0, 0.0, 1.0]);
	}

	@property T x() const {
		return this.q[0];
	}

	@property T y() const {
		return this.q[1];
	}

	@property T z() const {
		return this.q[2];
	}

	@property T w() const {
		return this.q[3];
	}

	@property quat!T x(T x) {
		this.q[0] = x;
		return this;
	}

	@property quat!T y(T y) {
		this.q[1] = y;
		return this;
	}

	@property quat!T z(T z) {
		this.q[2] = z;
		return this;
	}

	@property quat!T w(T w) {
		this.q[3] = w;
		return this;
	}

	string toString() const {
		return format("%f:%f:%f:%f", this.q[0],this.q[1],this.q[2],this.q[3]);
	}
}

unittest {
	quat!(double) q = quat!(double)(45.0, 45.0, 0.0);
	log("%s", q.toString());
	vec3!double v = vec3!double(1.0, 0.0, 0.0);

	log("%s", v.toString());
	auto v2 = q * v;
	log("%s", v2.toString());

	auto q2 = q.getConjugate();
	auto v3 = q2 * v2;
	log("%s", v3.toString());

	auto m = q2.getMatrix();
	log("\n%s", m.toString());

	quat!(double) q3 = quat!(double)(315.0, 315.0, 0.0);
	v3 = q3 * v2;
	log("%s", v3.toString());
}

version(staging) {
void main() {
}
}
