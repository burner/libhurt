import std.stdio;

class HashTable(T) {
	class Node(T) {
		Node!(T) next;
		T data;

		this(T data) {
			this.data = data;
		}
	}

	private Node!(T)[] table;
	private size_t function(T data) hashFunc;
	private size_t size;
	private bool duplication;

	static size_t defaultHashFunc(T data) {
		return cast(size_t)data;
	}


	this(bool duplication = true, 
			size_t function(T toHash) hashFunc = &defaultHashFunc) {
		this.duplication = duplication;
		this.hashFunc = hashFunc;
	}

	Node!(T) search(const T data) {
		size_t hash = this.hashFunc(data) % this.table.length;
		Node!(T) it = this.table[hash];
		while(it !is null) {
			if(it.data == data)
				break;
			it = it.next;
		}
		return it;
	}

	private void grow() {
		Node!(T)[] nTable = new Node!(T)[this.table.length*2];
		foreach(it; this.table) {
			if(it !is null) {
				Node!(T) i = it;
				Node!(T) j = i.next;
				size_t hash;
				while(i !is null) {
					hash = this.hashFunc(i.data) % nTable.length;
					insert(nTable, hash, i);
					i = j;
					if(i !is null)
						j = i.next;	
				}
			}
		}
		this.table = nTable;
	}

	private static void insert(Node!(T)[] t, size_t hash, Node!(T) node) {
		Node!(T) old = t[hash];
		t[hash] = node;
		t[hash].next = old;
	}

	bool insert(T data) {
		if(!this.duplication) {
			Node!(T) check = this.search(data);
			if(check !is null) {
				return false;
			}
		}
		if(this.size + 1 > this.table.length*0.7) {
			this.grow();
		}
		size_t hash = this.hashFunc(data) % table.length;
		insert(this.table, hash, new Node!(T)(data));
		return true;
	}
}

void main() {
	int[][] lot = [[2811, 1089, 3909, 3593, 1980, 2863, 676, 258, 2499, 3147,
	3321, 3532, 3009, 1526, 2474, 1609, 518, 1451, 796, 2147, 56, 414, 3740,
	2476, 3297, 487, 1397, 973, 2287, 2516, 543, 3784, 916, 2642, 312, 1130,
	756, 210, 170, 3510, 987], [0,1,2,3,4,5,6,7,8,9,10],
	[10,9,8,7,6,5,4,3,2,1,0],[10,9,8,7,6,5,4,3,2,1,0,11],
	[0,1,2,3,4,5,6,7,8,9,10,-1],[11,1,2,3,4,5,6,7,8,0]];
	foreach(it; lot) {
		HashTable!(int) ht = new HashTable!(int)(false);
		foreach(jt; it)
			assert(ht.insert(jt));
	}
}
