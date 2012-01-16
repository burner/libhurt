module hurt.container.stack;

final class Stack(T) {
	private T[] stack;
	version(X86) {
		private int stptr;
	} else {
		private long stptr;
	}
	private size_t growthrate;

	this(size_t size = 128, size_t growthrate = 2) {
		if(growthrate < 2) {
			this.growthrate = 2;
		} else {
			this.growthrate = growthrate;
		}
		this.stack = new T[size];
		this.stptr = -1;
	}

	Stack!(T) push(T elem) {
		if(this.stptr+1 == stack.length) {
			this.stack.length = this.stack.length*this.growthrate;
		}
		this.stack[++this.stptr] = elem;
		return this;
	}

	T pop() {
		if(this.stptr < 0) {
			assert(0);
		}
		return this.stack[this.stptr--];
	}

	bool empty() const {
		return this.stptr < 0 ? true : false;
	}

	bool isEmpty() const {
		return this.empty();
	}

	T top() {
		if(this.stptr < 0) {
			assert(0);
		}
		return this.stack[this.stptr];
	}

	T[] values() {
		return this.stack[0..this.stptr+1];
	}

	size_t getSize() const {
		return this.stptr+1;
	}

	size_t getCapazity() const {
		return this.stack.length;
	}

	T elementAt(in size_t idx) {
		if(idx >= this.stptr) {
			assert(0, "Index to big");
		}
		return this.stack[idx];
	}

	Stack!(T) setCapazity(in size_t nSize) {
		if(this.stack.length >= nSize) {
			return this;
		} else {
			this.stack.length = nSize;
			return this;
		}
	}

	void clear() {
		this.stptr = -1;	
	}
}
