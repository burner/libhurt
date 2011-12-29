module hurt.util.getopt;

import hurt.conv.conv;
import hurt.container.deque;
import hurt.container.multimap;
import hurt.container.isr;
import hurt.io.stdio;
import hurt.util.slog;
import hurt.string.stringutil;
import hurt.string.formatter;

struct Args {
	private Deque!(string) optionType;
	private Deque!(string) optionLong;
	private Deque!(string) optionShort;
	private Deque!(string) description;
	private MultiMap!(string,size_t) map;
	private string[] optionDesc;
	private string help;
	private string[] args;

	static Args opCall(string[] args) {
		return Args(args);
	}

	this(string[] args, string help = null) {
		this.args = args;
		this.map = new MultiMap!(string,size_t)(ISRType.BinarySearchTree);
		this.description = new Deque!(string);
		this.optionLong = new Deque!(string);
		this.optionShort = new Deque!(string);
		this.optionType = new Deque!(string);
		foreach(idx, it; args[1..$]) {
			this.map.insert(it, idx+1);
		}
		hurt.container.multimap.Iterator!(string,size_t) it = map.begin();
		for(; it.isValid(); it++) {
			printfln("%s => %d", it.getKey(), it.getData());
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
		println("--help or -h\nprint this help\n");
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
			ref T value, bool last = false) {
		if(opShort is null || opShort.length == 0 || 
				opLong is null || opLong.length == 0 ||
				desc is null || desc.length == 0) {
			throw new Exception("passed option description null or to short");
		} else {
			this.description.pushBack(desc);
			this.optionShort.pushBack(opShort);
			this.optionLong.pushBack(opLong);
			this.optionType.pushBack(typeid(T).toString);

			// check if the option is present
			hurt.container.multimap.Iterator!(string,size_t) s = 
				this.map.lower(opShort);
			hurt.container.multimap.Iterator!(string,size_t) z = 
				this.map.lower(opLong);
			hurt.container.multimap.Iterator!(string,size_t) l;
			if(s !is null && l !is null) {
				throw new Exception("Option passed twice at position " ~
					conv!(size_t,string)(s.getData()) ~ " and position " ~
					conv!(size_t,string)(l.getData()));
			} else {
				if(s.isValid())
					l = s;
				else
					l = z;
			}
			log();
			if(!l.isValid()) {
				return this;
			}
			log();

			if(this.args is null || this.args.length == 1) {
				return this;
			}
			log();

			static if(is(T == bool)) {
				if(l.isValid() && l.getData() < this.args.length-1 &&
						this.notAnOption(this.args[l.getData()+1]) &&
						(this.args[l.getData()+1] == "true" ||
						 this.args[l.getData()+1] == "false") ) {
					log();
					value = conv!(string,bool)(this.args[l.getData()+1]);
				} else {
					log();
					value = true;
				}
			} else {
				if(l.isValid() && l.getData() < this.args.length-1 &&
						this.notAnOption(this.args[l.getData()+1])) {
					value = conv!(string,T)(this.args[l.getData()+1]);	
					log();
				} else {
					log();
					throw new Exception(
						format("not enough arguments passed for %s etc. " ~
						"%s %b %d %d", opLong, opShort, l.isValid(), 
						l.isValid() ? l.getData()+1 : -1, this.args.length));
				}
			}
			
			if(last && (this.map.lower("-h").isValid() || 
					this.map.lower("--help").isValid())) {
				this.printHelp();
			}
		}
		return this;
	}
}

void main(string[] args) {
	string[] ar = split("./getopt -b 100 -t 200 --foo 300 --file getopt.d");
	Args arguments = Args(ar);
	arguments.setHelpText("test programm to test the args parser");
	int bar = 0;
	int foo = 0;
	bool tar = false;
	string file;
	arguments.setOption("-b", "--bar", "bar option", bar);
	log();
	arguments.setOption("-t", "--tar", "tar option", tar);
	log();
	arguments.setOption("-f", "--foo", "foo option", foo);
	log();
	arguments.setOption("-d", "--file", "file option", file, true);
	log();
	println(__LINE__,bar, foo, tar, file);
}
