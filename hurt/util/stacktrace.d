module hurt.util.stacktrace;

import core.sync.mutex;
import hurt.io.stdio;
import hurt.container.isr;
import hurt.conv.conv;
import hurt.container.dlst;
import hurt.container.map;
import hurt.algo.sorting;
import hurt.string.formatter;
import hurt.util.util;

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
		printfln("%60s %8s %12s", "function", "calls", "time in ms");
		Trace.allCallsMutex.lock();
		Stats[] a = Trace.allCalls.values();
		assert(a.length == Trace.allCalls.getSize());
		sort!(Stats)(a, function(in Stats a, in Stats b) {
			 return a.time > b.time; });
		foreach(it; a) {
			printfln("%60s %8d %12d", it.funcName ~ " " ~ cropFileName(it.file) 
				~ ":" ~ format!(char,char)("%5d",it.line), it.calls, it.time);
		}
		Trace.allCallsMutex.unlock();
	}

	public static void printTrace() {
		println("\nPrinting current stackTrace:");
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
		for(uint i = 0; i < this.localDepth; i++) {
			hurt.io.stdio.print("  ");
		}
		printfln("%s:%4d %s", this.file, this.line, this.funcName);
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
