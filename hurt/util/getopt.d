module hurt.util.getopt;

import hurt.conv.conv;
import hurt.container.vector;
import hurt.container.map;
import hurt.container.isr;
import hurt.io.stdio;

struct Args {
	private Vector!(string) optionType;
	private Vector!(string) optionLong;
	private Vector!(string) optionShort;
	private Vector!(string) description;
	private Map!(string,size_t) map;
	private string[] optionDesc;
	private string help;
	private string[] args;

	static Args opCall(string[] args) {
		return Args(args);
	}

	this(string[] args, string help = null) {
		this.args = args;
		this.map = new Map!(string,size_t)(ISRType.BinarySearchTree);
		this.description = new Vector!(string);
		this.optionLong = new Vector!(string);
		this.optionShort = new Vector!(string);
		this.optionType = new Vector!(string);
		foreach(idx, it; args[1..$]) {
			this.map.insert(it, idx+1);
		}

		/*for(auto it = this.map.begin(); it.isValid(); it++) {
			println((*it).getKey(), (*it).getData());
		}*/

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

			MapItem!(string,size_t) s = this.map.find(opShort);
			MapItem!(string,size_t) z = this.map.find(opLong);
			MapItem!(string,size_t) l;
			if(s !is null && l !is null) {
				throw new Exception("Option passed twice at position " ~
					conv!(size_t,string)(s.getData()) ~ " and position " ~
					conv!(size_t,string)(l.getData()));
			} else {
				if(s !is null)
					l = s;
				else
					l = z;
			}
			static if(is(T == bool)) {
				if(l.getData() < this.args.length-1 &&
						(this.args[l.getData()+1] == "true" ||
						 this.args[l.getData()+1] == "false") ) {
					value = conv!(string,bool)(this.args[l.getData()+1]);
				} else {
					value = true;
				}
			} else {
				if(l.getData() < this.args.length-1)
					value = conv!(string,T)(this.args[l.getData()+1]);	
				else
					throw new Exception("not enough arguments passed");
			}
			
			if(last && (this.map.find("-h") !is null || 
					this.map.find("--help") !is null)) {
				this.printHelp();
			}
		}
		return this;
	}
}
/*
void main(string[] args) {
	Args arguments = Args(args);
	arguments.setHelpText("test programm to test the args parser");
	int bar = 0;
	int foo = 0;
	bool tar = false;
	string file;
	arguments.setOption("-b", "--bar", "bar option", bar);
	arguments.setOption("-t", "--tar", "tar option", tar);
	arguments.setOption("-f", "--foo", "foo option", foo);
	arguments.setOption("-d", "--file", "file option", file, true);
	println(__LINE__,bar, foo, tar, file);
}*/
