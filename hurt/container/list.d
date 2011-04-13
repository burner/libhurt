module hurt.container.list;

class List(T) {
	private class Item(T) {
		T value;
		Item!(T) next;
	
		this(T value) {
			this.value = value;
			this.next = null;
		}
	}

	private Item!(T) root;
	private uint size;
	
	public this() {
		this.root = null;
		this.size = 0;
	}

	public List!(T) clear() {
		this.root = null;
		return this;
	}

	bool find(T search) {
		Item!(T) tmp = this.root;
		while(tmp !is null) {
			if(search == tmp.value) {
				return true;
			}
			tmp = tmp.next;
		}
		return false;
	}

	List!(T) remove(T search) {
		if(this.root is null)
			return null;
		if(this.root.value == search) {
			this.root = this.root.next;
			this.size--;
		}
		Item!(T) tmp = this.root;
		while(tmp !is null) {
			if(tmp.next !is null && tmp.next.value == search) {
				tmp.next = tmp.next.next;
				this.size--;
				return this;
			}
			tmp = tmp.next;
		}
		return this;	
	}

	List!(T) insert(T toIn) {
		if(root is null) {
			this.root = new Item!(T)(toIn);
			this.size++;
			return this;
		}
		Item!(T) ne = new Item!(T)(toIn);
		ne.next = this.root;
		this.root = ne;
		this.size++;
		return this;
	}

	public uint getSize() const {
		return this.size;
	}

	int opApply(int delegate(ref Item!(T)) dg) {
		int result = 0;
		Item!(T) it = root;
		while(it !is null) {
			result = dg(it);
			if(result)
				break;

			it = it.next;
		}
		return result;
	}
}

unittest {
	List!(int) l1 = new List!(int)();
	int[] randomIdx = [0, 31, 32, 1027, 1540, 1541, 1452, 1546, 1547, 1036, 1282, 526, 
		2575, 2576, 1554, 531, 1048, 2585, 1563, 2590, 1056, 2081, 548, 1061, 
		38, 2091, 2711, 1070, 1583, 1078, 2615, 1081, 1084, 1034, 2997, 578, 
		2627, 2629, 1096, 73, 2122, 2743, 1617, 595, 85, 787, 1628, 1124, 1126, 
		2663, 1299, 1642, 1265, 621, 112, 1651, 2165, 1146, 2171, 2684, 1152, 
		2177, 2695, 1162, 651, 1677, 655, 148, 1685, 662, 1175, 2245, 2211, 943, 
		1192, 2231, 2233, 1724, 701, 197, 1057, 1736, 2764, 2766, 2770, 723, 740, 
		217, 2271, 737, 228, 744, 2287, 2288, 1320, 2803, 1780, 2806, 1273, 1786, 
		1275, 2300, 2302, 767, 2818, 774, 129, 2826, 268, 2833, 1810, 1811, 1814, 
		1306, 2332, 2335, 291, 1318, 1832, 2347, 2862, 1327, 2864, 1329, 1954, 
		307, 2357, 2871, 1851, 36, 1341, 1342, 2869, 2368, 321, 837, 1350, 344, 
		345, 2399, 2552, 2407, 2920, 874, 2923, 366, 2415, 1394, 883, 373, 2422, 
		2426, 1916, 2197, 1409, 900, 1927, 1931, 1425, 1938, 2453, 2969, 922, 2460, 
		1439, 2466, 1956, 421, 422, 2983, 424, 427, 428, 430, 2479, 437, 2489, 1982, 
		962, 455, 418, 977, 2002, 1499, 1500, 992, 2018, 487, 1000, 2471, 2541, 
		1009, 498, 500, 1016];

	foreach(idx,it; randomIdx) {
		l1.insert(it);
		foreach(jt; randomIdx[0..idx]) {
			assert(l1.find(jt));
		}
		foreach(jt; randomIdx[idx+1..$]) {
			assert(!l1.find(jt));
		}
	}

	foreach(idx,it; randomIdx) {
		l1.remove(it);
		foreach(jt; randomIdx[0..idx]) {
			assert(!l1.find(jt));
		}
		foreach(jt; randomIdx[idx+1..$]) {
			assert(l1.find(jt));
		}
	}
}
