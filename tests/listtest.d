import hurt.container.dlst;
import hurt.container.list;
import hurt.container.fdlist;
import hurt.util.random.random;
import hurt.util.datetime;
import hurt.util.slog;
import hurt.io.stdio;
import hurt.string.formatter;

import std.stdio;

void main() {
	bool binvec = false;
	//int dim = 10;
	int dim = 10;
	int[][] num = new int[][dim];
	int startSize = 32;
	log();
	foreach(ref it; num) {
		it = new int[startSize*=2];
		foreach(ref jt;it) {
			jt = random();
		}
	}

	int iteration = 5;
	long[][][] times = new long[][][](3,7,dim);
	long start;
	for(int i = 0; i < iteration; i++) {
		foreach(idx, it; num) {
			auto dll = new DLinkedList!(int)();
			start = getMilli();
			foreach(jt; it) {
				dll.pushBack(jt);
			}
			times[0][0][idx] += getMilli() - start;
			log("%d", times[0][0][idx]);

			auto fdll = new FDoubleLinkedList!(int)();
			start = getMilli();
			foreach(jt; it) {
				fdll.pushBack(jt);
			}
			times[1][0][idx] += getMilli() - start;
			log("%d", times[1][0][idx]);

			auto lst = new List!(int)();
			start = getMilli();
			foreach(jt; it)
				lst.pushBack(jt);
			times[2][0][idx] += getMilli() - start;
			log("%d", times[2][0][idx]);

			assert(lst.getSize() == it.length, format("%d != %d", 
				lst.getSize(), it.length));
			assert(fdll.getSize() == it.length, format("%d != %d", 
				fdll.getSize(), it.length));
			assert(dll.getSize() == it.length, format("%d != %d", dll.getSize(),
				it.length));

			start = getMilli();
			for(auto jt = 0; jt < it.length; jt++) {
				auto z = dll[jt];
			}
			times[0][1][idx] += getMilli() - start;
			log("%d", times[0][1][idx]);

			start = getMilli();
			for(auto jt = 0; jt < it.length; jt++) {
				auto z = fdll[jt];
			}
			times[1][1][idx] += getMilli() - start;
			log("%d", times[1][1][idx]);

			start = getMilli();
			for(auto jt = 0; jt < it.length; jt++) {
				auto z = lst[jt];
			}
			times[2][1][idx] += getMilli() - start;
			log("%d", times[2][1][idx]);

			start = getMilli();
			foreach(jt; it)
				dll.popBack();
			times[0][2][idx] += getMilli() - start;
			log("%d", times[0][2][idx]);

			start = getMilli();
			foreach(jt; it)
				fdll.popBack();
			times[1][2][idx] += getMilli() - start;
			log("%d", times[1][2][idx]);

			start = getMilli();
			foreach(jt; it)
				lst.popBack();	
			times[2][2][idx] += getMilli() - start;
			log("%d", times[2][2][idx]);

			assert(dll !is null);
			start = getMilli();
			foreach(jt; it) {
				dll.pushFront(jt);
			}
			times[0][3][idx] += getMilli() - start;
			log("%d", times[0][3][idx]);

			start = getMilli();
			foreach(jt; it) {
				fdll.pushFront(jt);
			}
			times[1][3][idx] += getMilli() - start;
			log("%d", times[1][3][idx]);

			start = getMilli();
			foreach(jt; it)
				lst.pushFront(jt);
			times[2][3][idx] += getMilli() - start;
			log("%d", times[2][3][idx]);

			assert(lst.getSize() == it.length, format("%d != %d", 
				lst.getSize(), it.length));
			assert(fdll.getSize() == it.length, format("%d != %d", 
				fdll.getSize(), it.length));
			assert(dll.getSize() == it.length, format("%d != %d", 
				dll.getSize(), it.length));

			start = getMilli();
			foreach(jt; it) {
				dll.popFront();
			}
			times[0][4][idx] += getMilli() - start;
			log("%d", times[0][4][idx]);

			start = getMilli();
			foreach(jt; it) {
				fdll.popFront();
			}
			times[1][4][idx] += getMilli() - start;
			log("%d", times[1][4][idx]);

			start = getMilli();
			foreach(jt; it)
				lst.popFront();
			times[2][4][idx] += getMilli() - start;
			log("%d", times[2][4][idx]);

			start = getMilli();
			foreach(jt; it) {
				dll.pushFront(jt);
			}
			times[0][4][idx] += getMilli() - start;
			log("%d", times[0][4][idx]);

			start = getMilli();
			foreach(jt; it) {
				fdll.pushFront(jt);
			}
			times[1][4][idx] += getMilli() - start;
			log("%d", times[1][4][idx]);

			start = getMilli();
			foreach(jt; it)
				lst.pushFront(jt);
			times[2][4][idx] += getMilli() - start;
			log("%d", times[2][4][idx]);

			foreach(jt; it) {
				lst.popFront();
				fdll.popFront();
				dll.popFront();
			}
			assert(lst.isEmpty());
			assert(fdll.isEmpty());
			assert(dll.isEmpty());

			start = getMilli();
			dll.pushBack(66);
			foreach(jt; it) {
				dll.insert(jt % dll.getSize(), jt);
			}
			times[0][5][idx] += getMilli() - start;
			log("%d", times[0][5][idx]);

			assert(fdll !is null);
			start = getMilli();
			fdll.pushBack(66);
			foreach(jt; it) {
				fdll.insert(jt % fdll.getSize(), jt);
			}
			times[1][5][idx] += getMilli() - start;
			log("%d", times[1][5][idx]);

			start = getMilli();
			lst.pushBack(66);
			foreach(jt; it)
				lst.insert(jt % lst.getSize(), jt);
			times[2][5][idx] += getMilli() - start;
			log("%d", times[2][5][idx]);

			assert(lst.getSize() == it.length+1, format("%d != %d", 
				lst.getSize(), it.length));
			assert(fdll.getSize() == it.length+1, format("%d != %d", 
				fdll.getSize(), it.length));
			assert(dll.getSize() == it.length+1, format("%d != %d", 
				dll.getSize(), it.length));

			start = getMilli();
			lst.pushBack(66);
			foreach(jt; it) {
				dll.remove(jt % dll.getSize());
			}
			times[0][6][idx] += getMilli() - start;
			log("%d", times[0][6][idx]);

			start = getMilli();
			fdll.pushBack(66);
			foreach(jt; it) {
				fdll.remove(jt % fdll.getSize());
			}
			times[1][6][idx] += getMilli() - start;
			log("%d", times[1][6][idx]);

			start = getMilli();
			lst.pushBack(66);
			foreach(jt; it) {
				lst.remove(jt % lst.getSize());
			}
			times[2][6][idx] += getMilli() - start;
			log("%d", times[2][6][idx]);

			writeln(it.length);
		}
	}
	printfln("%7s: %5s %5s %5s","pushBack", "dlst", "fdlst", "lst");
	for(int i = 0; i < dim; i++) {	
		printfln("%7d:  %5d %5d %5d", num[i].length,
			times[0][0][i]/iteration, times[1][0][i]/iteration,
			times[2][0][i]/iteration);
	}

	printfln("\n%7s: %5s %5s %5s","pushFront", "dlst", "fdlst", "lst");
	for(int i = 0; i < dim; i++) {	
		printfln("%7d:  %5d %5d %5d", num[i].length,
			times[0][3][i]/iteration, times[1][3][i]/iteration,
			times[2][3][i]/iteration);
	}

	printfln("\n%7s: %5s %5s %5s","opIndex", "dlst", "fdlst", "lst");
	for(int i = 0; i < dim; i++) {	
		printfln("%7d: %5d  %5d %5d", num[i].length,
			times[0][1][i]/iteration, times[1][1][i]/iteration,
			times[2][1][i]/iteration);
	}

	printfln("\n%7s: %5s %5s %5s","popBack", "dlst", "fdlst", "lst");
	for(int i = 0; i < dim; i++) {	
		printfln("%7d: %5d  %5d %5d", num[i].length,
			times[0][2][i]/iteration, times[1][2][i]/iteration,
			times[2][2][i]/iteration);
	}

	printfln("\n%7s: %5s %5s %5s","popFront", "dlst", "fdlst", "lst");
	for(int i = 0; i < dim; i++) {	
		printfln("%7d: %5d  %5d %5d", num[i].length,
			times[0][4][i]/iteration, times[1][4][i]/iteration,
			times[2][4][i]/iteration);
	}

	printfln("\n%7s: %5s %5s %5s","insert", "dlst", "fdlst", "lst");
	for(int i = 0; i < dim; i++) {	
		printfln("%7d: %5d  %5d %5d", num[i].length,
			times[0][5][i]/iteration, times[1][5][i]/iteration,
			times[2][5][i]/iteration);
	}

	printfln("\n%7s: %5s %5s %5s","remove", "dlst", "fdlst", "lst");
	for(int i = 0; i < dim; i++) {	
		printfln("%7d: %5d  %5d %5d", num[i].length,
			times[0][6][i]/iteration, times[1][6][i]/iteration,
			times[2][6][i]/iteration);
	}
}
