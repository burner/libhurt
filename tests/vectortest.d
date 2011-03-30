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
	foreach(it;vec) {
		writeln(it);
	}
	vec.popBack();
	writeln("size = ", vec.getSize(), "\n");
	vec.insert(2,8);
	foreach(it;vec) {
		writeln(it);
	}
	writeln("size = ", vec.getSize(), "\n");
	vec.remove(3);
	foreach(it;vec) {
		writeln(it);
	}
	writeln("size = ", vec.getSize(), "\n");
	vec.insert(0,-1);
	foreach(it;vec) {
		writeln(it);
	}
	writeln("size = ", vec.getSize(), "\n");

	Vector!(int) vec2 = new Vector!(int)(10);
	vec2.append(0);
	vec2.append(1);
	vec2.append(2);
	vec2.append(3);
	vec2.append(4);
	vec2.append(5);
	foreach(it;vec2) {
		writeln(it);
	}
	writeln("size = ", vec2.getSize(), "\n");
	vec2.insert(2,8);
	foreach(it;vec2) {
		writeln(it);
	}
	writeln("size = ", vec2.getSize(), "\n");
	vec2.append(6);
	vec2.append(7);
	foreach(it;vec2) {
		writeln(it);
	}
	vec2.insert(5,9);
	writeln("\nsize = ", vec2.getSize());
	foreach(it;vec2) {
		writeln(it);
	}
	vec2.insert(0, vec2[5]);
	writeln("\nsize = ", vec2.getSize());
	foreach(it;vec2) {
		writeln(it);
	}
	vec2.remove(2);
	writeln("\nsize = ", vec2.getSize());
	foreach(it;vec2) {
		writeln(it);
	}
	vec2.remove(0);
	writeln("\nsize = ", vec2.getSize());
	foreach(it;vec2) {
		writeln(it);
	}
	vec2.remove(8);
	writeln("\nsize = ", vec2.getSize());
	foreach(it;vec2) {
		writeln(it);
	}
}
