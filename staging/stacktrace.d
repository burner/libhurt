module util.stacktrace;

import core.sync.mutex;
import std.conv;
import core.vararg;

import hurt.io.stdio;
import hurt.container.isr;
import hurt.conv.conv;
import hurt.container.dlst;
import hurt.container.map;
import hurt.algo.sorting;

extern(C) long getMilli();
/*
public final class StackTrace(string fn = __FILE__, int ln = __LINE__) {
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
	private static DLinkedList!(StackTrace) stack;

	public static void printStats() {
		println("\nStats of all traced function:");
		printfln("%55s %15s %15s", "function", "calls", "time in ms");
		StackTrace.allCallsMutex.lock();
		Stats[] a = StackTrace.allCalls.values();
		sort!(Stats)(a, function(in Stats a, in Stats b) {
			 return a.calls > b.calls; });
		foreach(it; a) {
			printf("%55s %15d, %15d", it.funcName~"() at "~ it.file ~ ":" ~ 
				conv!(int,string)(it.line), it.calls, it.time);
		}
		StackTrace.allCallsMutex.unlock();
	}

	public static void printTrace() {
		printfln("\nPrinting current stackTrace\n:");
		foreach(StackTrace it; StackTrace.stack) {
			it.print();
		}
	}

	static this() {
		StackTrace.stack = new DLinkedList!(StackTrace)();
		StackTrace.allCalls = new Map!(string,Stats)(ISRType.HashTable);
		StackTrace.allCallsMutex = new Mutex();
	}

	this(string func) {
		this.file = file;
		this.line = line;
		this.funcName = func;
		this.startTime = getMilli();
		this.localDepth = StackTrace.depth++;
		StackTrace.stack.pushBack(this);
	}

	public void print() {
		for(uint i = 0; i < this.localDepth; i++) {
			hurt.io.stdio.print("  ");
		}
		printfln("%s:%d %s", this.file, this.line, this.funcName);
	}

	public void putArgs(...) {
		string tmp = "";
		int cnt = 0;
		for(int i = 0; i < _arguments.length; i++) {
			//writeln("typeid = ",_arguments[i]);
			if(_arguments[i] == typeid(string)) {
				tmp ~= va_arg!(string)(_argptr);
				tmp ~= " ";
			} else if(_arguments[i] == typeid(int)) {
				tmp ~= to!(string)(va_arg!(int)(_argptr));
				tmp ~= " ";
			} else if(_arguments[i] == typeid(char)) {
				tmp ~= to!(string)(va_arg!(char)(_argptr));
				tmp ~= " ";
			} else if(_arguments[i] == typeid(double)) {
				tmp ~= to!(string)(va_arg!(double)(_argptr));
				tmp ~= " ";
			} else {
				//StackTrace.printTrace();
			}
		}
		//writeln(tmp);
		this.args = tmp[0 .. $-1];
	}

	~this() {
		ulong timeDiff = getMilli() - this.startTime;
		//writeln("destructor ", timeDiff);
		string id = this.file ~ ":" ~ to!string(this.line);
		StackTrace.allCallsMutex.lock();
		if(StackTrace.allCalls.contains(id)) {
			Stats s = *StackTrace.allCalls.find(id);
			s.calls++;
			s.time += timeDiff;	
		} else {
			Stats s = new Stats;
			StackTrace.allCalls.insert(id, s);
			s.calls++;
			s.time = timeDiff;	
			s.funcName = this.funcName;
			s.line = this.line;
			s.file= this.file;
		}
		StackTrace.allCallsMutex.unlock();
		StackTrace.depth--;
		StackTrace.stack.popBack();
	}
}*/

struct StackTrace(string file = __FILE__, int line = __LINE__) {
	string file;
	int line;
}

void bar() {
}

void foo() {
	bar();
}

void main() {
	StackTrace st();	
}
