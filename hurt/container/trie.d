module hurt.container.trie;

import hurt.container.deque;
import hurt.container.map;
import hurt.container.isr;
import hurt.string.stringbuffer;
import hurt.string.formatter;
import hurt.io.stdio;
import hurt.util.slog;
import hurt.util.pair;

private class TrieNode(T,S) {
	private T[] member;
	private Map!(S,TrieNode!(T,S)) follow;

	this() {
		//this.follow = new Map!(S,TrieNode!(T,S))(ISRType.HashTable);
	}

	bool insert(Deque!(S) path, size_t idx, T object) {
		if(idx == path.getSize()) { // reached the end of the path
			// allready has an object
			if(this.member !is null) {
				return false;
			// insert a new object
			} else {
				this.member = new T[1];
				this.member[0] = object;
				return true;
			}
		}

		// has a follow for the path 
		if(this.follow !is null && this.follow.contains(path[idx])) { 
			// lazy construct the follow map
			return this.follow.find(path[idx]).getData().
				insert(path, idx+1, object);

		// path not present 
		} else if(this.follow is null || !follow.contains(path[idx])) { 
			// lazy construct the follow map
			if(this.follow is null) {
				this.follow = new Map!(S,TrieNode!(T,S))(ISRType.HashTable);
			}
			TrieNode!(T,S) node = new TrieNode!(T,S)();
			this.follow.insert(path[idx], node);
			return node.insert(path, idx+1, object);
		} else {
			assert(false, "shouldn't be reached");
		}
	}

	bool contains(Deque!(S) path, size_t idx) {
		if(idx == path.getSize()) {
			return this.member !is null;
		} else {
			// if there are no follow items this branch doesn't contain
			// the object search for
			if(this.follow is null) {
				return false;
			}
			//return this.follow.find(path[idx]).getData().
				//contains(path, idx+1);
			MapItem!(S,TrieNode!(T,S)) mapItem = this.follow.find(path[idx]);
			if(mapItem is null) {
				return false;
			}
			assert(mapItem !is null);
			TrieNode!(T,S) tmp =  mapItem.getData();
			assert(tmp !is null);
			return tmp.contains(path, idx+1);
		}
	}

	T find(Deque!(S) path, size_t idx) {
		if(idx == path.getSize()) {
			return this.member[0];
		} else {
			// if there are no follow items this branch doesn't contain
			// the object search for
			if(this.follow is null) {
				throw new Exception("Object not found");
			}
			//return this.follow.find(path[idx]).getData().
				//contains(path, idx+1);
			MapItem!(S,TrieNode!(T,S)) mapItem = this.follow.find(path[idx]);
			if(mapItem is null) {
				throw new Exception("Object not found");
			}
			assert(mapItem !is null);
			TrieNode!(T,S) tmp =  mapItem.getData();
			assert(tmp !is null);
			return tmp.find(path, idx+1);
		}
	}

	public void toString(StringBuffer!(char) ret, size_t indent) {
		// if there is a member
		if(this.member !is null) {
			ret.pushBack(format("%d", this.member[0]));
		}
		ret.pushBack('\n');

		// nothing follows so return
		if(this.follow is null) {
			return;
		}

		ISRIterator!(MapItem!(S,TrieNode!(T,S))) it = this.follow.begin();
		for(; it.isValid(); it++) {
			for(size_t idx = 0; idx < indent; idx++) {
				ret.pushBack(format("%8s", " "));
			}
			ret.pushBack(format("%4d%4s", (*it).getKey(), "=> "));
			(*it).getData().toString(ret, indent+1);
		}
	}
}

class Trie(T,S) {
	private Map!(S,TrieNode!(T,S)) follow;
	private size_t size;

	this() {
		this.size = 0;
		this.follow = new Map!(S,TrieNode!(T,S))(ISRType.HashTable);
	}

	size_t getSize() const {
		return this.size;
	}

	bool insert(Deque!(S) path, T object) {
		assert(path.getSize() > 0);
		if(this.follow.contains(path[0])) { // first symbol allready present
			bool wasInserted =  this.follow.find(path[0]).getData().
				insert(path, 1, object);
			// increment the size if something was inserted
			if(wasInserted) {
				this.size++;
			}
			return wasInserted;
		} else { // need to insert the first symbol into the root
			TrieNode!(T,S) node = new TrieNode!(T,S)();
			this.follow.insert(path[0], node);
			this.size++;
			return node.insert(path, 1, object);
		}
	}

	bool contains(Deque!(S) path) {
		// trie path must be at least one element long
		assert(path !is null);
		assert(path.getSize() > 0);

		MapItem!(S, TrieNode!(T,S)) mi = this.follow.find(path[0]);
		if(mi !is null) {
			return mi.getData().contains(path, 1);
		} else {
			return false;
		}
	}

	T find(Deque!(S) path) {
		// trie path must be at least one element long
		assert(path !is null);
		assert(path.getSize() > 0);

		MapItem!(S, TrieNode!(T,S)) mi = this.follow.find(path[0]);
		if(mi !is null) {
			return mi.getData().find(path, 1);
		} else {
			static if(is(T : Object)) {
				return null;
			} else {
				return T.init;
			}
		}
	}

	public override string toString() {
		StringBuffer!(char) ret = new StringBuffer!(char)(128);
		ISRIterator!(MapItem!(S,TrieNode!(T,S))) it = this.follow.begin();
		for(; it.isValid(); it++) {
			ret.pushBack(format("%4d%4s", (*it).getKey(), "=> "));
			(*it).getData().toString(ret, 1);
		}
		return ret.getString();
	}
}

unittest {
	Trie!(int,int) t = new Trie!(int,int)();
	assert(t.getSize() == 0);
	assert(t.insert(new Deque!(int)([1,2,3]), 987));
	assert(t.contains(new Deque!(int)([1,2,3])));
	assert(987 == t.find(new Deque!(int)([1,2,3])));
	assert(t.getSize() == 1);

	assert(t.insert(new Deque!(int)([1,2,5]), 986));
	assert(t.contains(new Deque!(int)([1,2,3])));
	assert(t.contains(new Deque!(int)([1,2,5])));
	assert(987 == t.find(new Deque!(int)([1,2,3])));
	assert(986 == t.find(new Deque!(int)([1,2,5])));
	assert(t.getSize() == 2);

	assert(t.insert(new Deque!(int)([1,3]), 985));
	assert(t.contains(new Deque!(int)([1,2,3])));
	assert(t.contains(new Deque!(int)([1,2,5])));
	assert(t.contains(new Deque!(int)([1,3])));
	assert(987 == t.find(new Deque!(int)([1,2,3])));
	assert(986 == t.find(new Deque!(int)([1,2,5])));
	assert(985 == t.find(new Deque!(int)([1,3])));
	assert(t.getSize() == 3);

	assert(!t.insert(new Deque!(int)([1,3]), -985));
	assert(987 == t.find(new Deque!(int)([1,2,3])));
	assert(986 == t.find(new Deque!(int)([1,2,5])));
	assert(985 == t.find(new Deque!(int)([1,3])));
	assert(t.getSize() == 3);

	int[] shuffle = [1, 3, 4, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16, 17, 18, 20,
	54, 57, 58, 59, 60, 61, 63, 64, 65, 66, 67, 70, 72, 73, 74, 75, 80, 82, 83,
	85, 86, 87, 89, 91, 93, 94, 96, 97, 101, 102, 104, 106, 109, 114, 115, 116,
	163, 164, 165, 166, 168, 169, 172, 173, 174, 175, 177, 179, 180, 181, 182,
	543, 544, 545, 547, 548, 550, 551, 554, 555, 556, 558, 559, 561, 562, 566,
	567, 568, 569, 571, 573, 575, 576, 577, 578, 580, 582, 586, 587, 588, 592,
	642, 645, 646, 647, 648, 652, 655, 656, 657, 659, 660, 663, 664, 665, 669,
	726, 727, 728, 730, 731, 732, 733, 734, 735, 739, 740, 741, 742, 743, 744,
	796, 797, 798, 803, 804, 807, 808, 811, 812, 815, 817, 818, 819, 820, 821];

	int[] index = [1, 3, 4, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16, 17, 18, 20,
	54, 57, 58, 59, 60, 61, 63, 64, 65, 66, 67, 70, 72, 73, 74, 75, 80, 82, 83,
	85, 86, 87, 89, 91, 93, 94, 96, 97, 101, 102, 104, 106, 109, 114, 115, 116,
	163, 164, 165, 166, 168, 169, 172, 173, 174, 175, 177, 179, 180, 181, 182,
	543, 544, 545, 547, 548, 550, 551, 554, 555, 556, 558, 559, 561, 562, 566,
	567, 568, 569, 571, 573, 575, 576, 577, 578, 580, 582, 586, 587, 588, 592,
	642, 645, 646, 647, 648, 652, 655, 656, 657, 659, 660, 663, 664, 665, 669,
	726, 727, 728, 730, 731, 732, 733, 734, 735, 739, 740, 741, 742, 743, 744,
	796, 797, 798, 803, 804, 807, 808, 811, 812, 815, 817, 818, 819, 820, 821,
	867, 870, 872, 874, 876, 878, 880, 881, 882, 883, 884, 885, 887, 888, 889,
	1118, 1119, 1124, 1125, 1127, 1129, 1130, 1131, 1132, 1134, 1135, 1136,
	1171, 1172, 1173, 1174, 1175, 1176, 1177, 1178, 1181, 1184, 1186, 1189,
	1666, 1667, 1669, 1670, 1672, 1673, 1674, 1675, 1678, 1681, 1682, 1683,
	1690, 1693, 1694, 1695, 1696, 1697, 1698, 1699, 1700, 1701, 1703, 1704,
	1728, 1729, 1730, 1731, 1732, 1733, 1734, 1736, 1738, 1739, 1740, 1741,
	1881, 1882, 1884, 1886, 1887, 1888, 1889, 1891, 1893, 1894, 1895, 1896,
	1897, 1899, 1901, 1902, 1903, 1905, 1906, 1907, 1908, 1909, 1910, 1911,
	1912, 1913, 1914, 1915, 1916, 1917, 1918, 1922, 1924, 1925, 1929, 1930,
	1931, 1934, 1935, 1938, 1939, 1942, 1943, 1944, 1945, 1946, 1947, 1948,
	1949, 1950, 1951, 1952, 1955, 1956, 1958, 1960, 1961, 1963, 1964, 1965,
	1969, 1970, 1972, 1973, 1975, 1976, 1977, 1978, 1983, 1985, 1987, 1988,
	1990, 1992, 1994, 1996, 1998, 1999];

	size_t idxCnt = 0;

	int getNextLength() {
		return shuffle[index[idxCnt++ % index.length] % shuffle.length] % 7 + 1;
	}

	int getNextValue() {
		idxCnt += 31;
		return shuffle[index[idxCnt++ % index.length] % shuffle.length];
	}

	int testNumber = 50;

	Deque!(Pair!(Deque!(int), int)) save = new Deque!(Pair!(Deque!(int),int))
		(testNumber);
	
	Trie!(int,int) trie = new Trie!(int,int)();

	for(size_t i = 0; i < testNumber; i++) {
		Deque!(int) tmp = new Deque!(int)();
		int len = getNextLength();
		for(int j = 0; j < len; j++) {
			tmp.pushBack(getNextValue() % 100 + 1);
		}
		Pair!(Deque!(int),int) pair = Pair!(Deque!(int),int)(
			tmp, getNextValue());

		save.pushBack(pair);

		// if the insert didn't not succes we don't want to find it later
		if(!trie.insert(pair.first, pair.second)) {
			//log("%s", pair.first.toString());
			save.popBack();
		}
		assert(trie.getSize() == save.getSize(), format("%d != %d",
			trie.getSize(), save.getSize()));

		// test if all are present
		foreach(Pair!(Deque!(int),int) it; save) {
			assert(trie.contains(it.first), format("%s\n\n%s", 
				it.first.toString(),
				trie.toString()));
			assert(trie.find(it.first) == it.second, 
				format("%d != %d\n%s\n\n%s", it.second, trie.find(it.first),
				it.first.toString(),
				trie.toString()));
		}
	}
	//println(trie.toString());
	//println(trie.getSize());
}

version(staging) {
void main() {
}
}
