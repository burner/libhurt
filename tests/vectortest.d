import hurt.container.vector;
import hurt.conv.conv;

import std.stdio;

void main() {
	int[] t = [123,13,5345,752,12,3,1,654,22];
	Vector!(int) vec = new Vector!(int)(3);
	assert(vec.capacity() == 3);
	assert(vec.empty(), "empty it should be");
	vec.append(t[0]);
	assert(vec.capacity() == 3, "no growth should have happend");
	assert(!vec.empty(), "empty it should not be");
	assert(vec.get(0) == t[0], "first element wrong");
	assert(vec.popFront() == t[0], "popFront failed");
	assert(vec.empty(), "empty it should be");
	vec.append(t[0]);
	assert(vec.capacity() == 3, "no growth should have happend");
	assert(vec.get(0) == t[0], "first element wrong");
	assert(vec.popBack() == t[0], "popFront failed");
	vec.insert(0, t[0]);
	assert(vec.capacity() == 3, "no growth should have happend");
	assert(vec.get(0) == t[0], "first element wrong");
	assert(vec.popBack() == t[0], "popFront failed");
	vec.insert(0, t[0]);
	assert(vec.capacity() == 3, "no growth should have happend");
	assert(vec.get(0) == t[0], "first element wrong");
	assert(vec.popFront() == t[0], "popFront failed");
	assert(vec.empty(), "empty it should be");
	assert(vec.capacity() == 3, "no growth should have happend");
	
	foreach(idx,it;t) {
		vec.append(it);
		if(idx == 3)
			assert(vec.capacity() == 6);
		assert(vec.getSize() == idx+1, "size is wrong");

		assert(vec.indexOf(it) == idx, "idx wrong : idx = " 
			~ conv!(typeof(idx),string)(idx) ~ " indexOf = " 
			~ conv!(long,string)(vec.indexOf(it)));
	}
	assert(vec.elements() == t, "this should be the same");

	long tPtr = t.length;
	while(!vec.empty()) {
		int tmp = vec.popBack();	
		tPtr--;
		assert(tmp == t[tPtr], "wrong element popped"); // not sure how to right popped
		assert(vec.elements() == t[0..tPtr], "should be the same");
	}

	foreach(idx,it;t) {
		if(idx != 0) {
			vec.insert(0, it);
		} else {
			vec.append(it);
		}
		assert(vec.getSize() == idx+1, "size is wrong");

		assert(vec.indexOf(it) == 0, "idx wrong : idx = " 
			~ conv!(typeof(idx),string)(idx) ~ " indexOf = " 
			~ conv!(long,string)(vec.indexOf(it)));
	}
	
	assert(vec.elements() == t.reverse, "this should be the same");
	vec.setSize(3);
	assert(vec.getSize() == 3, "size should be 3");
	vec.setSize(-10);
	assert(vec.empty(), "should be empty");

	foreach(idx,it;t) {
		vec.append(it);
	}
	long oldSize = vec.getSize();
	vec.insert(0, 128);
	assert(vec.get(0) == 128, "first element wrong");
	assert(vec.getSize() == oldSize+1, "size wrong");
	oldSize = vec.getSize();
	vec.insert(1, 129);
	assert(vec.get(1) == 129, "second element wrong");
	assert(vec.getSize() == oldSize+1, "size wrong");
	oldSize = vec.getSize();
	vec.insert(vec.getSize()-2, 139);
	assert(vec.get(vec.getSize()-3) == 139, "second element wrong");
	assert(vec.getSize() == oldSize+1, "size wrong");
}
