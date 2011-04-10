module hurt.container.dlst;

import hurt.conv.conv;

import std.stdio;

public class DLinkedList(T) {
	private class Elem(T) {
		private T store;
		private Elem!(T) prev;
		private Elem!(T) next;

		public this(T store, Elem!(T) prev) {
			this.store = store;
			this.prev = prev;
		}

		public void setPrev(Elem!(T) prev) {
			this.prev = prev;
		}

		public void setNext(Elem!(T) next) {
			this.next = next;
		}

		public Elem!(T) getPrev() {
			return this.prev;
		}

		public Elem!(T) getNext() {
			return this.next;
		}

		public T getStore() {
			return this.store;
		}
	}

	private Elem!(T) head;
	private Elem!(T) tail;
	private ulong size;

	public this() {
		this.head = null;
		this.tail = null;
		this.size = 0L;
	}

	public this(DLinkedList!(T) toCopy) {
		this.head = null;
		this.tail = null;
		this.size = 0L;
		foreach(it; toCopy) {
			this.pushBack(it);
		}
	}

	public void pushBack(T store) {
		if(this.size == 0L) {
			this.head = new DLinkedList.Elem!(T)(store, null);
			this.tail = head;
		} else {
			Elem!(T) tmp = new DLinkedList.Elem!(T)(store, this.tail);
			this.tail.setNext(tmp);
			this.tail = tmp;
		}
		this.size++;
	}

	public void pushFront(T store) {
		if(this.size == 0) {	
			this.head = new DLinkedList.Elem!(T)(store, null);
			this.tail = head;
		} else {
			Elem!(T) tmp = new DLinkedList.Elem!(T)(store, null);
			tmp.setNext(this.head);
			this.head.setPrev(tmp);
			this.head = tmp;
		}
		this.size++;
	}

	public T popBack() {
		if(this.size > 1) {
			Elem!(T) tmp = this.tail;
			this.tail = tail.getPrev();
			this.tail.setNext(null);
			this.size--;
			return tmp.getStore();
		} else if(this.size == 0) {
			assert(0);
		} else {
			Elem!(T) tmp = this.tail;
			this.head = this.tail = null;
			this.size--;
			return tmp.getStore();
		}	
	}	

	public T popFront() {
		if(this.size > 1) {
			Elem!(T) tmp = this.head;
			this.head = head.getNext();
			this.head.setPrev(null);
			this.size--;
			return tmp.getStore();
		} else if(this.size == 0) {
			assert(0);
		} else if(this.size == 1) {
			assert(this.head is this.tail, "head and tail should be the same");
			assert(this.head !is null);
			T tmp = this.head.getStore();
			this.head = null;
			this.tail = null;
			this.size--;
			return tmp;
		}	
		assert(0);
	}

	public int opApply(scope int delegate(ref T) dg) {
		for(Elem!(T) e = this.head; e; e = e.getNext()) {
			T s = e.getStore();
			if(int r = dg(s)) {
				return r;
			}
		}
		return 0;
	}
	
	public ulong getSize() {
		return this.size;
	}	

	public bool contains(T value) {
		for(Elem!(T) e = this.head; e is this.tail; e = e.getNext()) {
			if(e.getStore() == value) {
				return true;
			}
		}
		if(this.tail.getStore() == value) {
			return true;
		}
		return false;	
	}

	public T remove(size_t idx) {
		if(idx > this.size-1) {
			assert(0, "index out of bound");
		}

		if(idx == 0L) {
			return this.popFront();
		} else if(idx == this.size-1) {
			return this.popBack();
		} else {
			Elem!(T) tmp = this.head;
			size_t it = 0;
			while(it < idx) {
				tmp = tmp.getNext();
				assert(tmp !is null, "tmp should not be null here. it = " ~ conv!(size_t,string)(it));
				it++;
			}
			Elem!(T) prev = tmp.getPrev();
			Elem!(T) next = tmp.getNext();
			prev.setNext(next);
			next.setPrev(prev);
			this.size--;
			return tmp.getStore();
		}
	}

	public T get(ulong idx) {
		if(idx > this.size) {
			assert(0, "index out of bound");
		}

		if(this.size - idx < idx) {
			Elem!(T) tmp = this.tail;
			ulong it = this.size - 1u;
			while(it > idx) {
				tmp = tmp.getPrev();
				it--;
			}
			return tmp.getStore();
		} else {
			Elem!(T) tmp = this.head;
			ulong it = 0u;
			while(it < idx) {
				tmp = tmp.getNext();
				it--;
			}
			return tmp.getStore();
		}
	}

	public bool validate() {
		size_t itIdx = 0;
		Elem!(T) tmp = this.head;
		if(this.size == 0) {
			return true;
		}
		if(tmp.getNext() is null) {
			assert(this.tail is tmp, "head and tail should be the same");
		}
		while(tmp !is null) {
			Elem!(T) tmpNext = tmp.getNext();
			if(tmpNext !is null) {
				assert(tmpNext.getPrev() is tmp, "prev pointer is wrong for index " ~ conv!(size_t,string)(itIdx+1));	
			}
			if(tmpNext is null) {
				assert(tmp is this.tail, "the tail pointer is not set correctly"); 
			}
			itIdx++;
			tmp = tmpNext;
		}
		assert(itIdx == this.size, "size is not stored correctly");
		return true;
	}
}
