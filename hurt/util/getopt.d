module hurt.util.getopt;

import hurt.conv.conv;
import hurt.container.deque;
import hurt.container.multimap;
import hurt.container.map;
import hurt.container.isr;
import hurt.container.vector;
import hurt.io.stdio;
import hurt.util.slog;
import hurt.string.stringutil;
import hurt.string.stringbuffer;
import hurt.string.formatter;

struct Args {
	private Deque!(string) optionType;
	private Deque!(string) optionLong;
	private Deque!(string) optionShort;
	private Deque!(string) description;
	private MultiMap!(string,size_t) map;
	private Map!(size_t,string) unprocessed; // used to get the unprocessed
	private string[] optionDesc;
	private string help;
	private string[] args;

	static Args opCall(string[] args) {
		return Args(args);
	}

	this(string[] args, string help = null) {
		this.args = args;
		this.map = new MultiMap!(string,size_t)(ISRType.BinarySearchTree);
		this.unprocessed = new Map!(size_t,string)(ISRType.HashTable);
		this.description = new Deque!(string);
		this.optionLong = new Deque!(string);
		this.optionShort = new Deque!(string);
		this.optionType = new Deque!(string);
		foreach(idx, it; args[1..$]) {
			this.unprocessed.insert(idx+1, it);
			this.map.insert(it, idx+1);
		}

		this.help = help;
	}

	public void setHelpText(string help) {
		this.help = help;	
	}

	public void printHelp() {
		if(this.help !is null && this.help.length > 0) {
			println(this.help,'\n');
		}
		println("--help or -h\nprints this help\n");
		size_t shIn = 0;
		size_t lngIn = 0;
		for(size_t idx = 0; idx < this.description.getSize(); idx++) {
			if(this.optionType[idx] == "bool") {
				printfln("%s or %s optional followed by true or false\n%s\n",
					this.optionLong[idx], this.optionShort[idx], 
					this.description[idx]);
			} else {
				printfln("%s or %s followed by an %s\n%s\n", 
					this.optionLong[idx], this.optionShort[idx], 
					this.optionType[idx], this.description[idx]);
			}
		}
	}

	private bool notAnOption(string str) {
		foreach(it; this.optionShort) {
			if(it == str)
				return false;
		}
		foreach(it; this.optionLong) {
			if(it == str)
				return false;
		}
		return true;
	}

	public size_t getNumberOfUnprocessed() const {
		return this.unprocessed.getSize();	
	}

	public int opApply(int delegate(ref size_t, ref string) dg) {
		ISRIterator!(MapItem!(size_t,string)) it = this.unprocessed.begin();
		for(; it.isValid(); it++) {
			size_t kT = (*it).getKey();
			string dT = (*it).getData();
			if(int r = dg(kT,dT)) {
				return r;
			}
		}
		return 0;
	}

	public int opApply(int delegate(ref string) dg) {
		ISRIterator!(MapItem!(size_t,string)) it = this.unprocessed.begin();
		for(; it.isValid(); it++) {
			string dT = (*it).getData();
			if(int r = dg(dT)) {
				return r;
			}
		}
		return 0;
	}

	private void checkForConflicts(string conflicts, string opShort,
			string opLong) {
		string[] conOptions = split(conflicts,',');
		// check if conflicts are presend
		bool conflict = false;
		StringBuffer!(char) conflictReport = new StringBuffer!(char)();
		foreach(string it; conOptions) {
			hurt.container.multimap.Iterator!(string,size_t) cIt =
				this.map.lower(it);
			// report conflict
			if(cIt.isValid()) {
				conflictReport.pushBack(format("%s %s conflicts with %s", 
					opShort !is null ? opShort : "",
					opLong !is null ? opLong : "",
					it));
				conflictReport.pushBack('\n');
				conflict = true;
			}
		}
		if(conflict) {
			throw new Exception(conflictReport.getString());
		}
	}

	private void optionStringsGood(string opShort, string opLong) {
		if((opShort is null && opLong is null) ||
				(opShort is null && opLong !is null && opLong.length == 0) ||
				(opShort !is null && opLong is null && opShort.length == 0) ||
				(opShort !is null && opLong !is null && opShort.length == 0 &&
				opLong.length == 0)) {
			throw new Exception("passed option description null or to short");
		} 
	}

	private void getArgument(T)(string opShort, string opLong, ref T value,
			hurt.container.multimap.Iterator!(string,size_t) l) {
		static if(is(T == bool)) {
			if(l.isValid() && l.getData() < this.args.length-1 &&
					this.notAnOption(this.args[l.getData()+1])) {

				if(this.args[l.getData()+1] == "true" ||
						this.args[l.getData()+1] == "false") {
					value = conv!(string,bool)(this.args[l.getData()+1]);
					this.unprocessed.remove(l.getData()+1);
				} else {
					throw new Exception(
						format("passed invalid bool flag \"%s\"", 
						this.args[l.getData()+1]));
				}
			} else {
				value = true;
			}
		} else {
			if(l.isValid() && l.getData() < this.args.length-1 &&
					this.notAnOption(this.args[l.getData()+1])) {
				value = conv!(string,T)(this.args[l.getData()+1]);	
				this.unprocessed.remove(l.getData()+1);
			} else {
				throw new Exception(
					format("not enough arguments passed for %s etc. " ~
					"%s %b %d %d", opLong, opShort, l.isValid(), 
					l.isValid() ? l.getData()+1 : -1, this.args.length));
			}
		}
	}

	/** For every option you want parsed call this function.
	 * @author Robert "BuRnEr" Schadek
	 *  
	 * @param last Last must be set to true for the last option set.
	 *   If last is set to true and an option with name -h or --help
	 *   has been passed previously the help is printed
	 *  
	 * @return The Args struct so you can concat the setOption process
	 *   with a simple dot.
	 */
	public Args setOption(T)(string opShort, string opLong, string desc, 
			ref T value, bool last = false, string conflicts = null) {
		this.optionStringsGood(opShort, opLong);
		this.description.pushBack(desc);
		this.optionShort.pushBack(opShort);
		this.optionLong.pushBack(opLong);
		this.optionType.pushBack(typeid(T).toString);

		// check if the option is present
		hurt.container.multimap.Iterator!(string,size_t) s = opShort !is null ? 
			this.map.lower(opShort) : this.map.invalidIterator();
		hurt.container.multimap.Iterator!(string,size_t) z = opLong !is null ? 
			this.map.lower(opLong) : this.map.invalidIterator();
		hurt.container.multimap.Iterator!(string,size_t) l;
		//if(s !is null && l !is null) {
		if(s.isValid() && z.isValid()) {
			throw new Exception("Option passed twice at position " ~
				conv!(size_t,string)(s.getData()) ~ " and position " ~
				conv!(size_t,string)(z.getData()));
		} else {
			if(s.isValid()) {
				l = s;
			} else {
				l = z;
			}
		}

		if(last && (this.map.lower("-h").isValid() || 
				this.map.lower("--help").isValid())) {
			this.printHelp();
		}

		if(!l.isValid()) {
			return this;
		}
		this.unprocessed.remove(l.getData());

		// check conflicts
		this.checkForConflicts(conflicts, opShort, opLong);

		if(this.args is null || this.args.length == 1) {
			return this;
		}

		this.getArgument(opShort, opLong, value, l);

		return this;
	}

	public Args setMultipleOptions(T)(string opShort, string opLong, 
			string desc, ref T[] values, bool last = false, 
			string conflicts = null) {
		this.optionStringsGood(opShort, opLong);
		this.description.pushBack(desc);
		this.optionShort.pushBack(opShort);
		this.optionLong.pushBack(opLong);
		this.optionType.pushBack(typeid(T).toString);

		// check if the option is present
		hurt.container.multimap.Iterator!(string,size_t) s = opShort !is null ? 
			this.map.range(opShort) : this.map.invalidIterator();
		hurt.container.multimap.Iterator!(string,size_t) l = opLong !is null ? 
			this.map.range(opLong) : this.map.invalidIterator();
		if(!s.isValid() && !l.isValid()) {
			return this;
		}

		// check conflicts
		this.checkForConflicts(conflicts, opShort, opLong);

		if(this.args is null || this.args.length == 1) {
			return this;
		}

		Vector!(T) vec = new Vector!(T)();
		//this.getArgument(opShort, opLong, value, l);
		for(; s.isValid(); s++) {
			T tValue;
			this.unprocessed.remove(s.getData());
			this.getArgument(opShort, opLong, tValue, s);
			vec.pushBack(tValue);
		}
		for(; l.isValid(); l++) {
			T tValue;
			this.unprocessed.remove(l.getData());
			this.getArgument(opShort, opLong, tValue, l);
			vec.pushBack(tValue);
		}
		values = vec.elements();

		if(last && (this.map.lower("-h").isValid() || 
				this.map.lower("--help").isValid())) {
			this.printHelp();
		}
		
		return this;
	}
}

/*
void main(string[] args) {
	string[] ar = split(
	"./getopt -b 100 -t false --foo 300 --file getopt.d 5555" ~
	" -m 1 -m 2 --multiple 3");
	Args arguments = Args(ar);
	arguments.setHelpText("test programm to test the args parser");
	int bar = 0;
	int zar = 0;
	int foo = 0;
	int[] m;
	bool tar = false;
	string file;
	arguments.setOption("-b", "--bar", "bar option", bar);
	arguments.setOption!(int)("-z", null, "zar option", zar);
	arguments.setOption("-t", "--tar", "tar option", tar);
	arguments.setOption("-f", "--foo", "foo option", foo);
	arguments.setMultipleOptions("-m", "--multiple", "multplie option", m);
	arguments.setOption("-d", "--file", "file option", file, true, "-z");
	println(__LINE__,bar, foo, tar, file);
	foreach(int mIt; m) {
		printf("%d ", mIt);
	}
	println();

	foreach(size_t idx, string it; arguments) {
		printfln("%u %s", idx, it);
	}
}*/
