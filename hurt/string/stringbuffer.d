module hurt.string.stringbuffer;

/** Authors: Robert "BuRnEr" Schadek, rburners.gmail.com
 * Data: 25.10.2010
 * Examples: See unittest
 *
 * This template class is used to concat any type of chars into a String.
 * This is needed in the Lexer. The idea is to push chars into it and than
 * check if it has a numeric (think holdsNumberChar()) and if not check
 * against a given keyword with StringBuffer.compare("your keyword").
 */
public template StringBuffer(T) {
	class StringBuffer {
		private T buffer[];
		private size_t initSize;
		version(X86_64) {
			private long bufferPointer;
		} else {
			private int bufferPointer;
		}
		private bool holdsNumber;
		private bool holdsOp;
		private bool firstCharIsNumber;

		public this(in size_t initSize = 16) {
			this.initSize = initSize;
			this.bufferPointer = 0;
			this.holdsNumber = false;
			this.holdsOp = false;
			this.firstCharIsNumber = false;
			this.buffer = new T[this.initSize];
		}

		public this(immutable(T)[] str) {
			this.initSize = str.length*2;
			this.bufferPointer = 0;
			this.holdsNumber = false;
			this.holdsOp = false;
			this.firstCharIsNumber = false;
			this.buffer = new T[this.initSize];
			foreach(it; str) {
				this.buffer[this.bufferPointer++] = it;
			}
		}

		public void clear() {
			this.bufferPointer = 0;
			this.holdsNumber = false;
			this.firstCharIsNumber = false;
			this.holdsOp = false;
		}

		public bool compare(in string against) {
			if(this.bufferPointer != against.length) return false;
			foreach(uint idx, char it; against) {
				if(it != this.buffer[idx]) return false;
			}
			return true;
		}

		public bool holdsNumberChar() const {
			return this.holdsNumber;
		}

		public bool firstIsNumber() const  {
			return this.firstCharIsNumber;
		}

		public bool holdsOperator() const {
			return this.holdsOp;
		}

		public StringBuffer!(T) pushBack(in T toAdd) {
			if(this.bufferPointer == initSize) {
				this.buffer.length = initSize * 2u;
				this.initSize *= 2u;
			}
			this.buffer[this.bufferPointer++] = toAdd;
			return this;
		}

		public StringBuffer!(T) pushBack(immutable(T)[] toAdd) {
			if(this.bufferPointer + toAdd.length >= this.initSize) {
				this.buffer.length += toAdd.length * 2u;
				this.initSize += toAdd.length * 2u;
			}
			foreach(it; toAdd) {
				this.buffer[this.bufferPointer++] = it;
			}
			return this;
		}

		public void pushBackOp(in T toAdd) {
			this.holdsOp = true;
			if(this.bufferPointer == initSize) {
				this.buffer.length = initSize * 2u;
				this.initSize *= 2u;
			}
			this.buffer[this.bufferPointer++] = toAdd;
		}

		public void pushBackNum(in T toAdd) {
			this.holdsNumber = true;
			if(this.bufferPointer == 0)
				this.firstCharIsNumber = true;
			if(this.bufferPointer == this.initSize) {
				this.buffer.length = this.initSize * 2u;
				this.initSize *= 2u;
			}
			this.buffer[this.bufferPointer++] = toAdd;
		}
		
		public T popBack() 
			in {
				assert(this.bufferPointer, 
					"Tryed to popBack empty StringBuffer");
			}
			out {this.bufferPointer--;}
			body {
				return this.buffer[this.bufferPointer-1];
			}

		public typeof(bufferPointer) getSize() const {
			return this.bufferPointer;
		}

		public T getLastChar() const {
			return this.buffer[this.bufferPointer-1];
		}

		public void removeLast() {
			this.bufferPointer--;
		}

		public immutable(T)[] getString() const {
			return this.buffer[0 .. this.bufferPointer].idup;
		}

		public T charAt(size_t idx) {
			if(idx > this.bufferPointer) {
				assert(0, "Index out of bound");
			}
			return this.buffer[idx];
		}
	}
}

unittest {
	StringBuffer!(char) sb = new StringBuffer!(char)(6);
	foreach(it; "Hello World") {
		sb.pushBack(it);
	}
	assert(!sb.compare("Hello WorlD"));
	sb.clear();
	//sb.popBack();
	foreach(it; "Hello") {
		sb.pushBack(it);
	}
	assert(sb.compare("Hello"));
	foreach(it; " World Hello World Hello World") {
		sb.pushBack(it);
	}
	assert(sb.compare("Hello World Hello World Hello World"));
}
