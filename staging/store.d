module hurt.container.store;

struct strPtr(T) {
	Store!T store;

	size_t base;
	size_t length;

	this(Store!T store, size_t base, size_t length) {
		this.store = store;
		this.base = base;
		this.length = length;
	}
}

class Store(T) {
	T[] store;

	MultiSet!(Pair!(size_t,strPtr!(T))) storeObjOfSize;
	Set!(strPtr!(T)) storePointer;

	/*
		When freeing a strPtr it is inserted into storePointer.
		If the freed strPtr base plus its length equals the base of the next
		strPtr in the set both are removed, combined and reinserted.
		Nothing happends if they are not equal. In either case the strPtr
		is placed in the multiset grouped by their size.
	*/

		
}
