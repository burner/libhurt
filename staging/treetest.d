import rbtree;
import bst;
import hashtable;
import hurt.util.random;
import hurt.util.datetime;

import std.stdio;

bool compare(T)(RBTree!(T) rb, HashTable!(T) ht, BinarySearchTree!(T) bst, 
		T[T] dht) {
	assert(bst.getSize() == rb.getSize() 
		&& ht.getSize() == dht.length
		&& bst.getSize() == ht.getSize());
	bool ret = true;
	foreach(it;dht.values()) {
		ret = bst.search(it) ? true : false;	
		ret = ret && rb.search(it) ? true : false;	
		ret = ret && ht.search(it) ? true : false;	
		if(!ret) {
			writeln(__LINE__);
			return false;
		}
	}

	foreach(it;rb.values()) {
		ret = bst.search(it) ? true : false;	
		ret = ret && it in dht ? true : false;	
		ret = ret && ht.search(it) ? true : false;	
		if(!ret) {
			writeln(__LINE__);
			return false;
		}
	}
			
	foreach(it;ht.values()) {
		ret = bst.search(it) ? true : false;	
		ret = ret && it in dht ? true : false;	
		ret = ret && rb.search(it) ? true : false;	
		if(!ret) {
			writeln(__LINE__);
			return false;
		}
	}
			
	foreach(it;bst.values()) {
		ret = ht.search(it) ? true : false;	
		ret = ret && it in dht ? true : false;	
		ret = ret && rb.search(it) ? true : false;	
		if(!ret) {
			writeln(__LINE__);
			return false;
		}
	}
			
	return true;
}

void main() {
	int dim = 11;
	int[][] num = new int[][dim];
	int startSize = 32;
	foreach(ref it; num) {
		it = new int[startSize*=2];
		foreach(ref jt;it) {
			jt = rand();
		}
	}

	int iteration = 3;
	long[][][] times = new long[][][](4,3,dim);
	long start;
	for(int i = 0; i < iteration; i++) {
		foreach(idx, it; num) {
			BinarySearchTree!(int) bst = new BinarySearchTree!(int)();
			start = getMilli();
			foreach(jt; it)
				bst.insert(jt);
			times[0][0][idx] += getMilli() - start;

			RBTree!(int) rb = new RBTree!(int)();
			start = getMilli();
			foreach(jt; it)
				rb.insert(jt);
			times[1][0][idx] += getMilli() - start;

			int[int] das;
			start = getMilli();
			foreach(jt; it)
				das[jt] = jt;
			times[2][0][idx] += getMilli() - start;

			HashTable!(int) ht = new HashTable!(int)(false);
			start = getMilli();
			foreach(jt; it)
				ht.insert(jt);
			times[3][0][idx] += getMilli() - start;

			assert(compare!(int)(rb, ht, bst, das));

			start = getMilli();
			foreach(jt; it)
				assert(bst.search(jt));
			times[0][1][idx] += getMilli() - start;

			start = getMilli();
			foreach(jt; it)
				assert(rb.search(jt));
			times[1][1][idx] += getMilli() - start;

			start = getMilli();
			foreach(jt; it)
				assert(jt in das);
			times[2][1][idx] += getMilli() - start;

			start = getMilli();
			foreach(jt; it)
				assert(ht.search(jt));
			times[3][1][idx] += getMilli() - start;


			start = getMilli();
			foreach(jt; it)
				bst.remove(jt);
			times[0][2][idx] += getMilli() - start;

			start = getMilli();
			foreach(jt; it)
				rb.remove(jt);
			times[1][2][idx] += getMilli() - start;

			start = getMilli();
			foreach(jt; it)
				das.remove(jt);	
			times[2][2][idx] += getMilli() - start;

			start = getMilli();
			foreach(jt; it)
				ht.remove(jt);	
			times[3][2][idx] += getMilli() - start;

			writeln(it.length);
		}
	}
	writefln("%7s: %5s %5s %5s %5s","insert", "bst", "rbtree", "d", "hm");
	for(int i = 0; i < dim; i++) {	
		writefln("%7d:  %5d %5d %5d %5d", num[i].length,
			times[0][0][i]/iteration, times[1][0][i]/iteration,
			times[2][0][i]/iteration,times[3][0][i]/iteration);
	}

	writefln("\n%7s: %5s %5s %5s %5s","search", "bst", "rbtree", "d", "hm");
	for(int i = 0; i < dim; i++) {	
		writefln("%7d: %5d  %5d %5d %5d", num[i].length,
			times[0][1][i]/iteration, times[1][1][i]/iteration,
			times[2][1][i]/iteration,times[3][1][i]/iteration);
	}

	writefln("\n%7s: %5s %5s %5s %5s","remove", "bst", "rbtree", "d", "hm");
	for(int i = 0; i < dim; i++) {	
		writefln("%7d: %5d  %5d %5d %5d", num[i].length,
			times[0][2][i]/iteration, times[1][2][i]/iteration,
			times[2][2][i]/iteration,times[3][2][i]/iteration);
	}
}
