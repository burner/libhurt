import rbtree;
import bst;
import hurt.util.random;
import hurt.util.datetime;

import std.stdio;

void main() {
	int dim = 19;
	int[][] num = new int[][dim];
	int startSize = 5;
	foreach(ref it; num) {
		it = new int[startSize*=2];
		foreach(ref jt;it) {
			jt = rand();
		}
	}

	int iteration = 3;
	long[][][] times = new long[][][](3,3,dim);
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
		}
	}
	writeln(getMilli()-start, " ", dim);
	writeln("insert");
	for(int i = 0; i < dim; i++) {	
		writeln(times[0][0][i]/iteration, " ", times[1][0][i]/iteration, " ", 
			times[2][0][i]/iteration);
	}

	writeln("\nsearch");
	for(int i = 0; i < dim; i++) {	
		writeln(times[0][1][i]/iteration, " ", times[1][1][i]/iteration, " ",
			times[2][1][i]/iteration);
	}
}
