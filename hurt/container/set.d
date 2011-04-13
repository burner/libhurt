module hurt.container.set;

import hurt.conv.conv;

import std.stdio;

public class Set(T) {
	T[T] array;

	this(Set!(T) toCopy) {
		foreach(it;toCopy.values()) {
			this.insert(it);
		}
	}

	this() {
	
	}
	
	bool insert(T value) {
		if(value in this.array) {
			return false;
		} else {
			this.array[value] = value;
			return true;
		}
	}

	bool remove(T value) {
		if(value in this.array) {
			this.array.remove(value);
			return true;
		} else {
			return false;
		}
	}

	bool contains(T value) const {
		if(value in this.array) {
			return true;
		} else {
			return false;
		}
	}

	T[] values() {
		return this.array.values();
	}

	Set!(T) dup() {
		Set!(T) ret = new Set!(T)(this);
		return ret;
	}

	override bool opEquals(Object o) const {
		Set!(T) f = cast(Set!(T))o;
		foreach(it; f.values()) {
			if(!this.contains(it)) {
				return false;
			}	
		}
		return f.values().length == this.array.length;
	}

	bool empty() const {
		return this.array.length == 0;
	}	
}

unittest {
	Set!(int) intTest = new Set!(int)();
	Set!(int) intTestCopy = intTest.dup();
	assert(intTest == intTestCopy, "should be the same");
	int[] t = [123,13,5345,752,12,3,1,654,22];
	foreach(idx,it;t) {
		assert(intTest.insert(it));
		foreach(jt;t[0..idx]) {
			assert(intTest.contains(jt));
		}
		intTestCopy = intTest.dup();
		assert(intTest == intTestCopy, "should be the same");
		foreach(jt;t[idx+1..$]) {
			assert(!intTest.contains(jt));
		}
	}
	foreach(idx,it;t) {
		assert(!intTest.insert(it), conv!(int,string)(it));
		assert(intTest.contains(it), conv!(int,string)(it));
		intTestCopy = intTest.dup();
		assert(intTest == intTestCopy, "should be the same");
	}
	foreach(idx,it;t) {
		assert(intTest.remove(it), conv!(int,string)(it));
		assert(!intTest.contains(it), conv!(int,string)(it));
		foreach(jt;t[0..idx]) {
			assert(!intTest.contains(jt));
		}
		foreach(jt;t[idx+1..$]) {
			assert(intTest.contains(jt));
		}
		intTestCopy = intTest.dup();
		assert(intTest == intTestCopy, "should be the same");
	}
}
