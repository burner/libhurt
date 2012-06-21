module hurt.algo.sorting;

import hurt.conv.conv;
import hurt.container.vector;
import hurt.container.deque;

/** This sort function implements a iterativ quicksort.
 * you can put any kind of container that implements the [] operator. If you 
 * don't pass the bounds the length property muss be implemented and the range
 * needs to start with 0.
 *
 * Examples:
 * 		bool cmp(in int l, in int r) { return l < r; };
 * 		sort!(int)(a, &cmp, 2, 7);
 * 		sort!(int)(a, function(in int l, in int r) { return l < r; });
 */
void sort(T)(T[] a, bool function(in T a, in T b) cmp, ulong leftb = 0,
		 ulong rightb = 0) {
	debug assert(rightb <= a.length-1, "right index out of bound");
	debug assert(leftb <= rightb, "left index to big");

	//swap function
	void swap(ref T m, ref T n) {
		T tmp = m;
		m = n;
		n = tmp;
	}

	//partition function
	long partition(ulong left, ulong right) {
		ulong idx = (left+right+1)/2;
		const T pivot = a[idx];
		swap(a[idx], a[right]);
		for(ulong i = idx = left; i < right; i++) {
			if(cmp(a[i], pivot)) {
				swap(a[idx++], a[i]);
			}
		}
		swap(a[idx], a[right]);
		return idx;
	}

	//the actual quicksort begins here
	long[128] stack;
	long stackTop = 0;
	stack[stackTop++] = leftb;
	if(rightb != 0) {
		stack[stackTop++] = rightb;
	} else {
		stack[stackTop++] = a.length-1;
	}
	while(stackTop > 0) {
		long right = stack[--stackTop];
		long left = stack[--stackTop];
		while(right > left) {
			long i = partition(left, right);
			if(i-1 > left) {
				stack[stackTop++] = left;
				stack[stackTop++] = i-1;
			}
			left = i+1;
		}
	}
}

unittest {
	size_t[] a = new size_t[10];
	for(size_t i = 0; i < a.length; i++) {
		a[i] = a.length-i;
	}
	void test(size_t[] v) {
		foreach(idx, it; v) {
			if(idx > 0) {
				assert(v[idx-1] < it, 
					conv!(size_t,string)(v[idx-1]) ~ " " ~ 
					conv!(size_t,string)(it));
			}
		}
	}
	void test2(int[] v) {
		foreach(idx, it; v) {
			if(idx > 0) {
				assert(v[idx-1] < it, 
					conv!(size_t,string)(v[idx-1]) ~ " " ~ 
					conv!(size_t,string)(it));
			}
		}
	}
	sort!(size_t)(a, function(in size_t l, in size_t r) { return l < r; });
	test(a);
	int[] k = [0, 31, 32, 1027, 1540, 1541, 1452, 1546, 1547, 1036, 1282, 526];
	sort!(int)(k, function(in int l, in int r) { return l < r; });
	test2(k);

	k = [0, 31, 32, 1027, 1540, 1541, -1, 1452, 1546, 1547, 1036, 1282, 526];
	sort!(int)(k, function(in int l, in int r) { return l < r; });
	test2(k);
}

void sortVector(T)(Vector!(T) a, bool function(T a, T b) cmp, 
		size_t leftb = 0, size_t rightb= 0) {
	debug assert(rightb <= a.getSize()-1, "right index out of bound");
	debug assert(leftb <= rightb, "left index to big");

	//swap function
	void swap(size_t m, size_t n) {
		T tmp = a[m];
		a.set(m, a[n]);
		a.set(n, tmp);
	}

	//partition function
	long partition(size_t left, size_t right) {
		size_t idx = (left+right+1)/2;
		const T pivot = a[idx];
		swap(idx, right);
		for(ulong i = idx = left; i < right; i++) {
			if(cmp(a[i], pivot)) {
				swap(idx++, i);
			}
		}
		swap(idx, right);
		return idx;
	}

	//the actual quicksort begins here
	long[128] stack;
	long stackTop = 0;
	stack[stackTop++] = leftb;
	if(rightb != 0) {
		stack[stackTop++] = rightb;
	} else {
		stack[stackTop++] = a.getSize()-1;
	}
	while(stackTop > 0) {
		long right = stack[--stackTop];
		long left = stack[--stackTop];
		while(right > left) {
			long i = partition(left, right);
			if(i-1 > left) {
				stack[stackTop++] = left;
				stack[stackTop++] = i-1;
			}
			left = i+1;
		}
	}
}

void sortVectorUnsafe(T)(Vector!(T) a, bool function(in T a, in T b) cmp, 
		size_t leftb = 0, size_t rightb= 0) {
	debug assert(rightb <= a.getSize()-1, "right index out of bound");
	debug assert(leftb <= rightb, "left index to big");

	//swap function
	void swap(size_t m, size_t n) {
		T tmp = a[m];
		a.set(m, a[n]);
		a.set(n, tmp);
	}

	//partition function
	long partition(size_t left, size_t right) {
		size_t idx = (left+right+1)/2;
		const T pivot = a[idx];
		swap(idx, right);
		for(ulong i = idx = left; i < right; i++) {
			if(cmp(a[i], pivot)) {
				swap(idx++, i);
			}
		}
		swap(idx, right);
		return idx;
	}

	//the actual quicksort begins here
	long[128] stack;
	long stackTop = 0;
	stack[stackTop++] = leftb;
	if(rightb != 0) {
		stack[stackTop++] = rightb;
	} else {
		stack[stackTop++] = a.getSize()-1;
	}
	while(stackTop > 0) {
		long right = stack[--stackTop];
		long left = stack[--stackTop];
		while(right > left) {
			long i = partition(left, right);
			if(i-1 > left) {
				stack[stackTop++] = left;
				stack[stackTop++] = i-1;
			}
			left = i+1;
		}
	}
}

unittest {
	Vector!(size_t) a = new Vector!(size_t)();
	for(size_t i = 0; i < 10; i++) {
		a.pushBack(10-i);
	}
	void test(T)(Vector!(T) v) {
		foreach(idx, it; v) {
			if(idx > 0) {
				assert(v[idx-1] < it, 
					conv!(size_t,string)(v[idx-1]) ~ " " ~ 
					conv!(size_t,string)(it));
			}
		}
	}
	sortVector!(size_t)(a, 
		function(in size_t l, in size_t r) { return l < r; });
	test!(size_t)(a);
	Vector!(int) k = new Vector!(int)();
	foreach(it; [0, 31, 32, 1027, 1540, 1541, 1452, 1546, 1547, 1036, 1282, 
			526]) {
		k.pushBack(it);
	}
	sortVector!(int)(k, function(in int l, in int r) { return l < r; });
	test!(int)(k);

	k = new Vector!(int)();
	foreach(it; [0, 31, 32, 1027, 1540, -1,1541, 1452, 1546, 1547, 1036, 1282, 
			526]) {
		k.pushBack(it);
	}
	sortVector!(int)(k, function(in int l, in int r) { return l < r; });
	test!(int)(k);
}

void sortDeque(T)(Deque!(T) a, bool function(in T a, in T b) cmp, 
		size_t leftb = 0, size_t rightb= 0) {
	debug assert(rightb <= a.getSize()-1, "right index out of bound");
	debug assert(leftb <= rightb, "left index to big");

	//swap function
	void swap(size_t m, size_t n) {
		T tmp = a[m];
		//a.set(m, a[n]);
		//a.set(n, tmp);
		a[m] = a[n];
		a[n] = tmp;
	}

	//partition function
	long partition(size_t left, size_t right) {
		size_t idx = (left+right+1)/2;
		const T pivot = a[idx];
		swap(idx, right);
		for(ulong i = idx = left; i < right; i++) {
			if(cmp(a[i], pivot)) {
				swap(idx++, i);
			}
		}
		swap(idx, right);
		return idx;
	}

	//the actual quicksort begins here
	long[128] stack;
	long stackTop = 0;
	stack[stackTop++] = leftb;
	if(rightb != 0) {
		stack[stackTop++] = rightb;
	} else {
		stack[stackTop++] = a.getSize()-1;
	}
	while(stackTop > 0) {
		long right = stack[--stackTop];
		long left = stack[--stackTop];
		while(right > left) {
			long i = partition(left, right);
			if(i-1 > left) {
				stack[stackTop++] = left;
				stack[stackTop++] = i-1;
			}
			left = i+1;
		}
	}
}

unittest {
	void test(T)(Deque!(T) v) {
		foreach(idx, it; v) {
			if(idx > 0) {
				assert(v[idx-1] < it, 
					conv!(size_t,string)(v[idx-1]) ~ " " ~ 
					conv!(size_t,string)(it));
			}
		}
	}

	Deque!(int) k = new Deque!(int)([0, 31, 32, 1027, 1540, -1,1541, 1452, 1546,
		1547, 1036, 1282, 526]);
	sortDeque!(int)(k, function(in int l, in int r) { return l < r; });
	test!(int)(k);
}
