module hurt.util.getopt;

import hurt.container.vector;
import hurt.container.map;
import hurt.container.isr;
import hurt.io.stdio;

struct Args {
	private Vector!(string) optionLong;
	private Vector!(string) optionShort;
	private Map!(string,size_t) map;
	private string[] optionDesc;
	private string help;

	static Args opCall(string[] args) {
		return Args(args);
	}

	this(string[] args, string help = null) {
		this.map = new Map!(string,size_t)(ISRType.BinarySearchTree);
		this.optionLong = new Vector!(string);
		this.optionShort = new Vector!(string);
		foreach(idx, it; args[1..$]) {
			this.map.insert(it, idx+1);
		}

		for(auto it = this.map.begin(); it.isValid(); it++) {
			println((*it).getKey(), (*it).getData());
		}

		this.help = help;
	}

	public void setHelpText(string help) {
		this.help = help;	
	}

	public Args setOption(T)(string opShort, string opLong, ref T value) {
		if(opShort is null || opShort.length == 0 || 
				opLong is null || opLong.length == 0) {
			throw new Exception("passed option description null or to short");
		} else {
			this.optionShort.pushBack(opShort);
			this.optionLong.pushBack(opLong);
		}
		return this;
	}
}

void main(string[] args) {
	Args arguments = Args(args);
}
