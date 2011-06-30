import rbtree;
import bst;
import hashtable;
import hurt.util.random;
import hurt.util.datetime;

import std.stdio;

void main() {
	int dim = 14;
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
	writeln("insert");
	for(int i = 0; i < dim; i++) {	
		writefln("%7d: %5d %5d %5d %5d", num[i].length,
			times[0][0][i]/iteration, times[1][0][i]/iteration,
			times[2][0][i]/iteration,times[3][0][i]/iteration);
	}

	writeln("\nsearch");
	for(int i = 0; i < dim; i++) {	
		writefln("%7d: %5d %5d %5d %5d", num[i].length,
			times[0][1][i]/iteration, times[1][1][i]/iteration,
			times[2][1][i]/iteration,times[3][1][i]/iteration);
	}

	writeln("\nremove");
	for(int i = 0; i < dim; i++) {	
		writefln("%7d: %5d %5d %5d %5d", num[i].length,
			times[0][2][i]/iteration, times[1][2][i]/iteration,
			times[2][2][i]/iteration,times[3][2][i]/iteration);
	}
}
