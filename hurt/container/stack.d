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

	this(Stack!(T) toCopy) {
		this.stack = toCopy.stack.dup;
		this.stptr = toCopy.stptr;
		this.growthrate = toCopy.growthrate;
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

	public override bool opEquals(Object o) {
		Stack!(T) s = cast(Stack!(T))o;
		if(this.stptr != s.stptr) {
			return false;
		}

		foreach(idx, it; this.stack[0 .. this.stptr+1]) {
			if(it != s.stack[idx]) {
				return false;
			}
		}

		return true;
	}

	void clear() {
		this.stptr = -1;	
	}
}

unittest {
	Stack!(int) i = new Stack!(int);
	i.push(44);
	assert(i.top() == 44);
	i.push(45);
	assert(i.pop() == 45);
	assert(i.pop() == 44);
	assert(i.empty());

	class Tmp {
		uint a = 44;
	}

	Stack!(Tmp) j = new Stack!(Tmp)(1, 4);
	j.push(new Tmp());
	j.top().a = 88;
	assert(j.top().a == 88);
	assert(j.getCapazity() == 1);
	j.push(new Tmp());
	assert(j.getCapazity() == 4);
	j.push(new Tmp());
	j.push(new Tmp());
	assert(j.getSize() == 4);
	j.setCapazity(992);
	assert(j.getCapazity() == 992);
	assert(j.getSize() == 4);
	j.setCapazity(33);
	assert(j.getCapazity() == 992);

	auto k = new Stack!(int)(i);
	assert(k == i);

	k.push(66);
	assert(k != i);

	i.push(55);
	auto n = new Stack!int(i);
	assert(n == i);
	n.push(77);
	assert(n != i);
}
