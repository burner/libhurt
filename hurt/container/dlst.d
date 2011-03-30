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
	private uint size;

	public this() {
		this.head = null;
		this.tail = null;
		this.size = 0;
	}

	public void pushBack(T store) {
		if(this.size == 0) {
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
	
	public uint getSize() {
		return this.size;
	}	
}
