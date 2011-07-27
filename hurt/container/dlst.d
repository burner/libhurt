module hurt.container.dlst;

import hurt.conv.conv;
import hurt.container.iterator;
import hurt.exception.nullexception;
import hurt.exception.invaliditeratorexception;

import std.stdio;

public class Iterator(T) : hurt.container.iterator.Iterator!(T) {
	private DLinkedList!(T).Elem!(T) elem;

	public this(DLinkedList!(T).Elem!(T) elem) {
		this.elem = elem;
	}

	public T getValue() {
		if(elem is null) {
			throw new NullException("Iterator value is null");
		} else {
			return elem.getStore();
		}
	}

	public void opUnary(string s)() if(s == "++") {
		this.elem = elem.getNext();
	}

	public void opUnary(string s)() if(s == "--") {
		this.elem = elem.getPrev();
	}

	public T opUnary(string s)() if(s == "*") {
		return this.getValue();
	}

	public override bool opEquals(Object o) {
		Iterator!(T) it = cast(Iterator!(T))o;
		return this.elem.getStore() == it.getElem().getStore();
	}

	public bool isValid() const {
		return this.elem !is null;
	}

	public DLinkedList!(T).Elem!(T) getElem() {
		return this.elem;
	}

	public void setElem(DLinkedList!(T).Elem!(T) elem) {
		this.elem = elem;
	}
}

public class DLinkedList(T) {
	private class Elem(T) {
		private T store;
		private Elem!(T) prev;
		private Elem!(T) next;

		public this(T store) {
			this.store = store;
		}
	
		public this(T store, Elem!(T) prev) {
			this(store);
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

		public override bool opEquals(Object o) const {
			Elem!(T) t = cast(Elem!(T))o;
			return t.getStore() == this.store &&
				t.getPrev() is this.prev &&
				t.getNext() is this.next;
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

	public Iterator!(T) pushBack(T store) {
		if(this.size == 0) {
			this.head = new Elem!(T)(store, null);
			this.tail = head;
			this.size++;
			return new Iterator!(T)(this.head);
		} else {
			Elem!(T) tmp = new Elem!(T)(store, this.tail);
			this.tail.setNext(tmp);
			this.tail = tmp;
			this.size++;
			return new Iterator!(T)(tmp);
		}
	}

	public Iterator!(T) pushFront(T store) {
		if(this.size == 0) {	
			this.head = new Elem!(T)(store, null);
			this.tail = head;
			this.size++;
			return new Iterator!(T)(this.head);
		} else {
			Elem!(T) tmp = new Elem!(T)(store, null);
			tmp.setNext(this.head);
			this.head.setPrev(tmp);
			this.head = tmp;
			this.size++;
			return new Iterator!(T)(tmp);
		}
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

	public bool isEnd(Iterator!(T) tt) const {
		return tt.getElem() == this.tail;
	}

	public bool isBegin(Iterator!(T) tt) const {
		return tt.getElem() == this.head;
	}

	int opApply(int delegate(ref size_t,ref T) dg) {
		size_t cnt = 0;
		for(Elem!(T) e = this.head; e; e = e.getNext(), cnt++) {
			T s = e.getStore();
			if(int r = dg(cnt,s)) {
				return r;
			}
		}
		return 0;
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

	public void clean() {
		this.head = null;
		this.tail = null;
		this.size = 0;
	}

	public bool isEmpty() const {
		return this.size == 0;
	}
	
	public size_t getSize() const {
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

	public Iterator!(T) begin() {
		Iterator!(T) tmp = new Iterator!(T)(this.head);
		return tmp;
	}

	public Iterator!(T) end() {
		Iterator!(T) tmp = new Iterator!(T)(this.tail);
		return tmp;
	}

	public T remove(Iterator!(T) it) {
		if(!it.isValid()) {
			throw new InvalidIteratorException(__FILE__ ~ conv!(int,string)(__LINE__) ~ ": Iterator not valid");
		}
		if(it.getElem().getPrev() is null) {
			T tmp = this.popFront();
			it.setElem(this.head);	
			return tmp;
		} else if(it.getElem().getNext() is null) {
			T tmp = this.popBack();
			it.setElem(this.tail);	
			return tmp;
		} else {
			Elem!(T) prev = it.getElem().getPrev();
			Elem!(T) next = it.getElem().getNext();
			it.setElem(next);
			prev.setNext(next);
			next.setPrev(prev);
			this.size--;
			return it.getValue();
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

	public Iterator!(T) insert(Iterator!(T) it, T value, bool before = false) {
		if(it !is null && it.isValid()) {
			if(this.size == 0 || (this.head == it.getElem() && before)) {
				this.pushFront(value);
				return this.begin();
			}
			if(this.tail == it.getElem() && !before) {
				this.pushBack(value);
				return this.end();
			}
			if(before) {
				Elem!(T) tmp = it.getElem();
				Elem!(T) prev = tmp.getPrev();
				Elem!(T) tIn = new Elem!(T)(value);
				prev.setNext(tIn);
				tIn.setPrev(prev);
				tIn.setNext(tmp);
				tmp.setPrev(tIn);
				this.size++;
				return new Iterator!(T)(tIn);
			} else {
				Elem!(T) tmp = it.getElem();
				Elem!(T) next = tmp.getNext();
				Elem!(T) tIn = new Elem!(T)(value);
				next.setPrev(tIn);
				tIn.setNext(next);
				tIn.setPrev(tmp);
				tmp.setNext(tIn);
				this.size++;
				return new Iterator!(T)(tIn);
			}
		} else {
			throw new InvalidIteratorException(__FILE__ ~ conv!(int,string)(__LINE__) ~ ": Iterator not valid");
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
