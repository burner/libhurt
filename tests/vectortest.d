import hurt.container.vector;

import std.stdio;

void main() {
	Vector!(int) vec = new Vector!(int)(3);
	vec.append(0);
	vec.append(1);
	vec.append(2);
	vec.append(3);
	vec.append(4);
	vec.append(5);
	vec.popBack();
	vec.insert(2,8);
	vec.remove(3);
	vec.insert(0,-1);

	Vector!(int) vec2 = new Vector!(int)(10);
	vec2.append(0);
	vec2.append(1);
	vec2.append(2);
	vec2.append(3);
	vec2.append(4);
	vec2.append(5);
	vec2.insert(2,8);
	vec2.append(6);
	vec2.append(7);
	vec2.insert(5,9);
	vec2.insert(0, vec2[5]);
	vec2.remove(2);
	vec2.remove(0);
	vec2.remove(8);
}
