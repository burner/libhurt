module hurt.container.bitmap;

import hurt.conv.conv;

public class BitMap {
	private uint[] bits;
	
	public this(uint initSize = 1) {
		this.bits = new uint[initSize];
	}

	BitMap set(uint idx, bool value) {
		if((idx / 31u) >= this.bits.length) {
			this.bits.length = this.bits.length + idx / 31u;
		}
		// if value set the bit
		if(value) {
			uint toSet = 1u << (idx % 31u);
			this.bits[idx/31u] |= toSet;
		} else {
			uint toUnSet = ~(1u << (idx % 31u));
			this.bits[idx/31u] &= toUnSet;
		}

		return this;
	}

	bool has(uint idx) const {
		if((idx / 31u) >= this.bits.length) {
			return false;
		} else {
			uint toCheck = 1u << (idx % 31u);	
			return (this.bits[idx / 31u] & toCheck) != 0;
		}
	}

	override string toString() const {
		char[] ret = new char[bits.length*32];
		uint idx = 0;
		foreach_reverse(it; this.bits) {
			for(uint i = 31; i+1 ; i--) {
				ret[idx++] = (it & (1u<<i)) ? '1' : '0';
			}
		}
		return ret.idup;
	}

	private uint[] getData() {
		return this.bits;
	}

	override bool opEquals(Object o) {
		BitMap t = cast(BitMap)o;
		uint[] td = t.getData();
		if(td.length != this.bits.length) {
			return false;
		}

		foreach(idx,it;this.bits) {
			if(it != td[idx]) {
				return false;
			}
		}
		return true;
	}
}

unittest {

	BitMap f = new BitMap();
	f.set(0,true);
	assert(f.has(0));
	f.set(1,true);
	assert(f.has(0)); assert(f.has(1));
	f.set(2,true);
	assert(f.has(0)); assert(f.has(1)); assert(f.has(2));
	f.set(4,true);
	assert(f.has(0)); assert(f.has(1)); assert(f.has(2)); assert(f.has(4));
	f.set(8,true);
	assert(f.has(0));
	assert(f.has(1)); assert(f.has(2)); assert(f.has(4)); assert(f.has(8)); 
	f.set(9,true); assert(f.has(0)); assert(f.has(1)); assert(f.has(2));
	assert(f.has(4)); assert(f.has(8)); assert(f.has(9));
	f.set(12,true);
	assert(f.has(0)); assert(f.has(1)); assert(f.has(2)); assert(f.has(4));
	assert(f.has(8)); assert(f.has(9)); assert(f.has(12)); f.set(14,true);
	assert(f.has(0)); assert(f.has(1)); assert(f.has(2)); assert(f.has(4));
	assert(f.has(8)); assert(f.has(9)); assert(f.has(12)); assert(f.has(14));
	f.set(16,true);
	assert(f.has(0)); assert(f.has(1)); assert(f.has(2)); assert(f.has(4));
	assert(f.has(8)); assert(f.has(9)); assert(f.has(12)); assert(f.has(14));
	assert(f.has(16));
	f.set(20,true);
	assert(f.has(0)); assert(f.has(1)); assert(f.has(2)); assert(f.has(4));
	assert(f.has(8)); assert(f.has(9)); assert(f.has(12)); assert(f.has(14));
	assert(f.has(16)); assert(f.has(20));
	f.set(31,true);
	assert(f.has(0)); assert(f.has(1)); assert(f.has(2)); assert(f.has(4));
	assert(f.has(8)); assert(f.has(9)); assert(f.has(12)); assert(f.has(14));
	assert(f.has(16)); assert(f.has(20)); assert(f.has(31));
	f.set(62,true);
	assert(f.has(0)); assert(f.has(1)); assert(f.has(2)); assert(f.has(4));
	assert(f.has(8)); assert(f.has(9)); assert(f.has(12)); assert(f.has(14));
	assert(f.has(16)); assert(f.has(20)); assert(f.has(31)); assert(f.has(62));

	uint[] randomIdx = [0, 31, 32, 1027, 1540, 1541, 1452, 1546, 1547, 1036, 1282, 526, 
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

	BitMap a = new BitMap();
	BitMap b = new BitMap();

	foreach(idx,it;randomIdx) {
		a.set(it, true);
		assert(a != b);
		b.set(it, true);

		assert(a == b);

		assert(a.has(it));

		foreach(jt;randomIdx[0..idx]) 
			assert(a.has(jt), conv!(uint,string)(jt));
		foreach(jt;randomIdx[(idx+1)..$]) 
			assert(!a.has(jt), conv!(uint,string)(jt));
	}

	foreach(idx,it;randomIdx) {
		a.set(it,false);
		assert(a != b);
		b.set(it,false);

		assert(a == b);

		assert(!a.has(it));

		foreach(jt;randomIdx[0..idx]) 
			assert(!a.has(jt), conv!(uint,string)(jt));
		foreach(jt;randomIdx[(idx+1)..$])
			assert(a.has(jt), conv!(uint,string)(jt));
	}
}
