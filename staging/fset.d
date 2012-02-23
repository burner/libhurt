import hurt.container.vector;
import hurt.algo.binaryrangesearch;
import hurt.algo.sorting;

public class FSet(T) {
	private Vector!(T) data;

	this(size_t size = 64) {
		this.data = new Vector!(T)(size);
	}

	this(FSet!(T) toCopy) {
		this.data = toCopy.getData().clone();
	}

	public size_t getSize() const { 
		return this.data.getSize(); 
	}

	public size_t isEmpty() const { 
		return this.data.empty(); 
	}

	public size_t getCapacity() const {
		return this.data.capacity();
	}

	public Vector!(T) getData() {
		return this.data;
	}

	bool contains(T key) {
		bool found = false;
		static if(is(T : Object)) {
			binarySearch!(T)(this.data, key, null, found);
			return found;
		} else {
			binarySearch!(T)(this.data, key, T.init, found);
			return found;
		}
	}

	bool insert(T data) {
		if(this.contains(data)) {
			return false;
		} else if(this.data.getSize() == 0) {
			this.data.pushBack(data);
			return true;
		} else if(this.data.peekBack() < data) {
			this.data.pushBack(data);
			return true;
		} else {
			this.data.pushBack(data);
			sortVector!(T)(this.data, function(in T a, in T b) {
				return a < b;});
			return true;
		}
	}
}

version(staging) {
void main() {
	FSet!(int) fset = new FSet!(int)();
	fset.insert(10);
	assert(fset.contains(10));
	assert(!fset.contains(9));
}
}
