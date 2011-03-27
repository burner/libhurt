module hurt.container.pairlist;

import std.stdio;

// A HashMap replacement

class PairList(T,S) {
	private Pair!(T,S) root;
	private uint size;
	
	public this() {
		this.root = null;
		this.size = 0;
	}

	public PairList!(T,S) clear() {
		if(this.root !is null) {
			this.root.release();
		}	
		return this;
	}

	Pair!(T,S) find(K)(K search) if(is(K == T) || is(K == S)) {
		Pair!(T,S) tmp = root;
		while(tmp !is null) {
			if(search == tmp.get!(K)()) {
				return tmp;
			}
			tmp = tmp.getNext();	
		}
		return null;
	}

	Pair!(T,S) remove(K)(K search) if(is(K == T) || is(K == S)) {
		Pair!(T,S) tmp;
		Pair!(T,S) rs;
		if(root !is null && search == root.get!(K)()) {
			rs = root;
			this.root = root.getNext();
			this.size--;
			return rs;
		} else {
			tmp = this.root;
			while(tmp !is null) {
				if(tmp.getNext() !is null && tmp.getNext().get!(K)() == search) {
					rs = tmp.getNext();
					tmp.setNext(rs.getNext());
					this.size--;
					return rs;
				}
				tmp = tmp.getNext();
			}
		}	
		return null;
	}

	PairList!(T,S) insert(Pair!(T,S) toIn) {
		if(root is null) {
			this.root = toIn;
			this.size++;
			return this;
		}
		toIn.setNext(this.root);
		this.root = toIn;
		this.size++;
		return this;
	}

	public uint getSize() const {
		return this.size;
	}

	int opApply(int delegate(ref Pair!(T,S)) dg) {
		int result = 0;
		Pair!(T,S) it = root;
		while(it !is null) {
			result = dg(it);
			if(result)
				break;

			it = it.getNext();
		}
		return result;
	}
}

class Pair(T,S) {
	private T first;
	private S second;
	
	private Pair!(T,S) next;

	public this(T first, S second) {
		this.first = first;
		this.second = second;
	}

	public Pair!(T,S) getNext() {
		return this.next;
	}

	public Pair!(T,S) setNext(Pair!(T,S) next) {
		this.next = next;
		return this.next;
	}

	public T getFirst() {
		return this.first;
	}

	public S getSecond() {
		return this.second;
	}

	public K get(K)() if(is(K == T) || is(K == S)) {
		static if(is(K == T)) {
			return this.first;
		} else {
			return this.second;
		}	
	}

	public void release() {
		if(this.next !is null) {	
			this.next.release();
			this.next = null;
		}
	}
}
