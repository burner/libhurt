import hurt.container.pairlist;

import std.stdio;

class Foo {
	int a;
	int f;
	string str;
	
	this(int a, int f, string str) {
		this.a = a;
		this.f = f;
		this.str = str;
	}

	override bool opEquals(Object o) {
		//if(is(Foo == o)) {
		if(is(o == Foo)) {
			return false;
		}
		Foo ftt = cast(Foo)o;
		if(this.a != ftt.a)
			return false;

		if(this.f != ftt.f)
			return false;

		if(this.str != ftt.str)
			return false;

		return true;
	}
}

void main() {
	PairList!(int, Foo) pl = new PairList!(int,Foo)();
	assert(null !is pl, "cound't create a pairlist");
	assert(null is pl.find!(int)(2));

	pl.insert(new Pair!(int,Foo)(1, new Foo(1,1,"one")));
	Pair!(int,Foo) f1 = pl.find!(Foo)(new Foo(1,1,"one"));	
	assert(f1 !is null, "cound find the first element in the list");
	pl.insert(new Pair!(int,Foo)(2, new Foo(2,2,"two")));

	Pair!(int,Foo) f2 = pl.find!(Foo)(new Foo(1,1,"one"));	
	assert(f2 !is null, "cound find the first element in the list");
	Pair!(int,Foo) f3 = pl.find!(int)(2);	
	assert(f3 !is null, "cound find the first element in the list");

	pl.insert(new Pair!(int,Foo)(3, new Foo(3,3,"three")));
	Pair!(int,Foo) f4 = pl.find!(int)(3);	
	Pair!(int,Foo) f5 = pl.find!(Foo)(new Foo(3,3,"three"));	
	assert(f4 is f5, "they should be the same");

	pl.insert(new Pair!(int,Foo)(4, new Foo(4,4,"four")));
	Pair!(int,Foo) f6 = pl.find!(int)(4);	

	Pair!(int,Foo) f7 = pl.remove!(int)(2);
	assert(f7 !is null, "is should not be null");

	Pair!(int,Foo) f8 = pl.find!(Foo)(new Foo(1,1,"one"));	
	assert(f8 !is null, "the list is broken");
	
	assert(3 == pl.getSize(), "wrong size");
	
}
