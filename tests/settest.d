import hurt.container.set;
import hurt.conv.conv;
import oldset;

import std.stdio;

void print(OldSet!(int) old, Set!(int) ne) {
	write("old: ");
	foreach(it;old.values()) {
		write(it, " ");
	}
	writeln();	
	write("new: ");
	foreach(it;ne) {
		write(it, " ");
	}
	writeln();	
}

bool same(OldSet!(int) old, Set!(int) ne) {
	if(old.getSize() != ne.getSize()) {
		return false;
	}
	int runsOld = 0;
	foreach(it;old.values()) {
		if(!ne.contains(it)) {
			return false;
		}
		runsOld++;
	}
	outer: foreach(it;old.values()) {
		foreach(jt; ne) {
			if(it == jt) {
				continue outer;
			}
		}
		print(old, ne);
		return false;
	}
	int runsNew = 0;
	foreach(it;ne) {
		if(!ne.contains(it)) {
			return false;
		}
		runsNew++;
	}
	if(runsOld != runsNew) {
		return false;
	}
	return true;
}

void main() {
	OldSet!(int) intTest = new OldSet!(int)();
	OldSet!(int) intTestCopy = intTest.dup();
	Set!(int) intTestNew = new Set!(int);
	Set!(int) intTestNewCopy = new Set!(int);

	assert(intTest == intTestCopy, "should be the same");
	assert(same(intTest, intTestNew), "shoule hold the same values");
	assert(intTestNew == intTestNewCopy, "should be the same");
	int[] t = [123,13,5345,752,12,3,1,654,22];

	foreach(idx,it;t) {
		assert(intTest.insert(it));
		assert(it == *intTestNew.insert(it));
		assert(same(intTest, intTestNew), "shoule hold the same values");
		foreach(jt;t[0..idx]) {
			assert(intTest.contains(jt));
			assert(intTestNew.contains(jt));
		}
		assert(intTest != intTestCopy, "should not be the same");
		assert(intTestNew != intTestNewCopy, "should not be the same");
		intTestCopy = intTest.dup();
		intTestNewCopy = intTestNew.dup();
		assert(intTest == intTestCopy, "should be the same");
		assert(intTestNew == intTestNewCopy, "should be the same");
		foreach(jt;t[idx+1..$]) {
			assert(!intTest.contains(jt));
			assert(!intTestNew.contains(jt));
		}
	}

	foreach(idx,it;t) {
		assert(!intTest.insert(it), conv!(int,string)(it));
		assert(intTest.contains(it), conv!(int,string)(it));
		assert(intTestNew.contains(it), conv!(int,string)(it));
		assert(same(intTest, intTestNew), "shoule hold the same values");
		intTestCopy = intTest.dup();
		intTestNewCopy = intTestNew.dup();
		assert(intTest == intTestCopy, "should be the same");
		assert(intTestNew == intTestNewCopy, "should be the same");
	}

	foreach(idx,it;t) {
		assert(intTest.remove(it), conv!(int,string)(it));
		intTestNew.remove(it);
		assert(same(intTest, intTestNew), "shoule hold the same values");
		assert(!intTest.contains(it), conv!(int,string)(it));
		assert(!intTestNew.contains(it), conv!(int,string)(it));
		foreach(jt;t[0..idx]) {
			assert(!intTest.contains(jt));
			assert(!intTestNew.contains(jt));
		}
		foreach(jt;t[idx+1..$]) {
			assert(intTest.contains(jt));
			assert(intTestNew.contains(jt));
		}
		intTestCopy = intTest.dup();
		intTestNewCopy = intTestNew.dup();
		assert(intTest == intTestCopy, "should be the same");
		assert(intTestNew == intTestNewCopy, "should be the same");
		assert(same(intTestCopy, intTestNewCopy), "shoule hold the same values");
	}
	writeln("set compare test done");
}
