module algo.sorting;

import std.stdio;

/* This sort function implements a iterativ quicksort.
 * you can put any kind of container that implements the [] operator. If you 
 * don't pass the bounds the length property muss be implemented and the range
 * needs to start with 0.
 *
 * Examples:
 * 		bool cmp(in int l, in int r) { return l < r; };
 * 		sort!(int)(a, &cmp, 2, 7);
 * 		sort!(int)(a, function(in int l, in int r) { return l < r; });
 */
void sort(T)(T[] a, bool function(in T a, in T b) cmp, uint leftb = 0,
		 uint rightb= 0) {
	debug assert(rightb <= a.length-1, "right index out of bound");
	debug assert(leftb <= rightb, "left index to big");

	//swap function
	void swap(ref T m, ref T n) {
		T tmp = m;
		m = n;
		n = tmp;
	}

	//partition function
	int partition(uint left, uint right) {
		uint idx = (left+right+1)/2;
		const T pivot = a[idx];
		swap(a[idx], a[right]);
		for(uint i = idx = left; i < right; i++) {
			if(cmp(a[i], pivot)) {
				swap(a[idx++], a[i]);
			}
		}
		swap(a[idx], a[right]);
		return idx;
	}

	//the actual quicksort begins here
	int[128] stack;
	int stackTop = 0;
	stack[stackTop++] = leftb;
	if(rightb != 0) {
		stack[stackTop++] = rightb;
	} else {
		stack[stackTop++] = a.length-1;
	}
	while (stackTop > 0) {
		int right = stack[--stackTop];
		int left = stack[--stackTop];
		while (right > left) {
			int i = partition(left, right);
			if (i-1 > left) {
				stack[stackTop++] = left;
				stack[stackTop++] = i-1;
			}
			left = i+1;
		}
	}
}

unittest {
	int[] a = new int[10];
	for(int i = 0; i < a.length; i++) {
		a[i] = a.length-i;
	}
	void print() {
		foreach(it; a) write(it, " ");
		writeln();
	}
	print();
	sort!(int)(a, function(in int l, in int r) { return l < r; }, 2, 3);
	print();
}
