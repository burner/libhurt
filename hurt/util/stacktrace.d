module util.stacktrace;

import core.sync.mutex;
import std.stdio;
import std.date;
import std.conv;
import std.stdarg;

import hurt.container.dlst;
import hurt.algo.sorting;

public interface Printable {
	public string toString();
}

public final class StackTrace {
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

	private __gshared static Stats[string] allCalls;
	private __gshared static Mutex allCallsMutex;
	private static uint depth;
	private static DLinkedList!(StackTrace) stack;

	public static void printStats() {
		writeln("\nStats of all traced function:");
		writefln("%55s %15s %15s", "function", "calls", "time in ms");
		StackTrace.allCallsMutex.lock();
		Stats[] a = StackTrace.allCalls.values;
		sort!(Stats)(a, function(in Stats a, in Stats b) {
			 return a.calls > b.calls; });
		foreach(it; a) {
			writefln("%55s %15d, %15d", it.funcName~"() at "~it.file~":"~to!(string)(it.line), it.calls, it.time);
		}
		StackTrace.allCallsMutex.unlock();
	}

	public static void printTrace() {
		writeln("\nPrinting current stackTrace:");
		foreach(StackTrace it; StackTrace.stack) {
			it.print();
		}
	}

	static this() {
		StackTrace.stack = new DLinkedList!(StackTrace)();
		StackTrace.allCallsMutex = new Mutex();
	}

	this(string file, uint line, string funcName) {
		this.file = file;
		this.line = line;
		this.funcName = funcName;
		this.startTime = getUTCtime();
		this.localDepth = StackTrace.depth++;
		StackTrace.stack.pushBack(this);
	}

	public void print() {
		for(uint i = 0; i < this.localDepth; i++) {
			write("  ");
		}
		writefln("%s:%d %s(%s)", this.file, this.line, this.funcName, this.args);
	}

	public void putArgs(...) {
		string tmp = "";
		int cnt = 0;
		for(int i = 0; i < _arguments.length; i++) {
			//writeln("typeid = ",_arguments[i]);
			if(_arguments[i] == typeid(string)) {
				tmp ~= va_arg!(string)(_argptr);
				tmp ~= " ";
			} else if(_arguments[i] == typeid(Printable)) {
				tmp ~= va_arg!(Printable)(_argptr).toString();
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
		ulong timeDiff = getUTCtime() - this.startTime;
		//writeln("destructor ", timeDiff);
		string id = this.file ~ ":" ~ to!string(this.line);
		StackTrace.allCallsMutex.lock();
		if(id in StackTrace.allCalls) {
			Stats s = StackTrace.allCalls[id];
			s.calls++;
			s.time += timeDiff;	
		} else {
			Stats s = new Stats;
			StackTrace.allCalls[id] = s;
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
}
