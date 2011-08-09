//module stacktrace;


import core.sync.mutex;
import hurt.io.stdio;
import hurt.container.isr;
import hurt.conv.conv;
import hurt.container.dlst;
import hurt.container.map;
import hurt.algo.sorting;

extern(C) long getMilli();

public class Trace {
	private string file;
	private uint line;
	private string funcName;
	private ulong startTime;
	private string args;
	private uint localDepth;

	private class Stats {
		string file;
		uint line;
		string funcName;
		uint calls;
		ulong time;
	}

	private __gshared static Map!(string,Stats) allCalls;
	private __gshared static Mutex allCallsMutex;
	private static uint depth;
	private static DLinkedList!(Trace) stack;

	public static void printStats() {
		println("\nStats of all traced function:");
		printfln("%50s %14s %14s", "function", "calls", "time in ms");
		Trace.allCallsMutex.lock();
		Stats[] a = Trace.allCalls.values();
		assert(a.length == Trace.allCalls.getSize());
		sort!(Stats)(a, function(in Stats a, in Stats b) {
			 return a.calls > b.calls; });
		foreach(it; a) {
			printfln("%50s %14d %14d", it.funcName~"() at "~ it.file ~ ":" ~ 
				conv!(int,string)(it.line), it.calls, it.time);
		}
		Trace.allCallsMutex.unlock();
	}

	public static void printTrace() {
		printfln("\nPrinting current stackTrace\n:");
		foreach(Trace it; Trace.stack) {
			it.print();
		}
	}

	static this() {
		Trace.stack = new DLinkedList!(Trace)();
		Trace.allCalls = new Map!(string,Stats)(ISRType.HashTable);
		Trace.allCallsMutex = new Mutex();
	}

	this(string func, string file = __FILE__, int line = __LINE__) {
		this.file = file;
		this.line = line;
		this.funcName = func;
		this.startTime = getMilli();
		this.localDepth = Trace.depth++;
		Trace.stack.pushBack(this);
	}

	public void print() {
		println(__LINE__);
		for(uint i = 0; i < this.localDepth; i++) {
			hurt.io.stdio.print("  ");
		}
		println(__LINE__);
		printfln("%s:%d %s", this.file, this.line, this.funcName);
	}

	~this() {
		ulong timeDiff = getMilli() - this.startTime;
		//writeln("destructor ", timeDiff);
		string id = this.file ~ ":" ~ conv!(int,string)(this.line);
		Trace.allCallsMutex.lock();
		if(Trace.allCalls.contains(id)) {
			Stats s = *Trace.allCalls.find(id);
			s.calls++;
			s.time += timeDiff;	
		} else {
			Stats s = new Stats;
			Trace.allCalls.insert(id, s);
			s.calls++;
			s.time = timeDiff;	
			s.funcName = this.funcName;
			s.line = this.line;
			s.file= this.file;
		}
		Trace.allCallsMutex.unlock();
		Trace.depth--;
		Trace.stack.popBack();
	}
}

void bar() {
	scope auto trace = new Trace("bar");
	int u = 1;
	for(int i = 0; i < 10000; i++) { u += i;}
}

void foo() {
	scope auto trace = new Trace("foo");
	bar();
	bar();
	bar();
	bar();
	bar();
	bar();
}

void main() {
	scope auto trace = new Trace("main");
	foo();
	foo();
	foo();
	bar();
	bar();
	bar();
	delete trace;
	Trace.printStats();
}