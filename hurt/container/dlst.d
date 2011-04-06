module hurt.container.dlst;

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
		} else {
			Elem!(T) tmp = this.tail;
			this.head = this.tail = null;
			this.size--;
			return tmp.getStore();
		}	
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

	public T remove(ulong idx) {
		if(idx > this.size-1) {
			assert(0, "index out of bound");
		}

		if(idx == 0L) {
			writeln("popFront");
			return this.popFront();
		} else if(idx == this.size-1) {
			writeln("popBack");
			return this.popBack();
		} else {
			if(this.size - idx < idx) {
				writeln("other one");
				Elem!(T) tmp = this.tail;
				ulong it = this.size - 1u;
				while(it > idx) {
					tmp = tmp.getPrev();
					it--;
				}
				Elem!(T) prev = tmp.getPrev();
				Elem!(T) next = tmp.getNext();
				prev.setNext(next);
				next.setNext(prev);
				this.size--;
				return tmp.getStore();
			} else {
				Elem!(T) tmp = this.head;
				writeln("other two ", tmp is null);
				ulong it = 0u;
				while(it < idx) {
					tmp = tmp.getNext();
					assert(tmp !is null);
					it++;
				}
				writeln("other two it ", it);
				Elem!(T) prev = tmp.getPrev();
				Elem!(T) next = tmp.getNext();
				assert(prev !is null);
				assert(next !is null);
				prev.setNext(next);
				next.setNext(prev);
				this.size--;
				return tmp.getStore();
			}
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
}
