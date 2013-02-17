import hurt.container.deque;
import hurt.time.stopwatch;
import hurt.io.stdio;
import core.memory;

Deque!(snode) nodes;
Deque!(size_t) childs;

int maxDeep = 0;

struct snode {
	byte[60] payload;

	size_t childstart;
	size_t numchilds;
	size_t deep;

	this(size_t deep) {
		this.deep = deep;
	}

	this(size_t childstart, size_t numchilds, size_t deep) {
		this.childstart = childstart;
		this.numchilds = numchilds;
		this.deep = deep;
	}
}

size_t makesnodes(size_t deep) {
	if(deep > maxDeep) {
		return size_t.max;
	} else {
		nodes.pushBack(snode(deep));
		size_t a = nodes.getSize()-1;
		nodes.pushBack(snode(deep));
		size_t b = nodes.getSize()-1;

		size_t ac = makesnodes(deep+1);
		size_t bc = makesnodes(deep+1);
		size_t acs = childs.getSize();
		childs.pushBack(ac);
		childs.pushBack(ac+1);
		nodes[a] = snode(acs, 2, deep);
		size_t bcs = childs.getSize();
		childs.pushBack(bc);
		childs.pushBack(bc+1);
		nodes[b] = snode(bcs, 2, deep);

		return a;
	}
}

class cnode {
	byte[60] payload;

	cnode l, r;
	size_t deep;

	this(size_t deep) {
		if(deep > maxDeep) {
			return;
		} else {
			l = new cnode(deep+1);
			r = new cnode(deep+1);
		}
	}
}

void main() {
	immutable runs = 18;
	immutable steps = 1024;
	float[steps][runs] a;
	float[steps][runs] b;
	for(int i = 1; i <= runs; i++) {
		for(int j = 0; j < steps; j++) {
			maxDeep = i;
			StopWatch s;
			s.start();
			nodes = new Deque!(snode)();
			childs = new Deque!(size_t)();
			makesnodes(0);
			a[i-1][j] = s.stop();

			s.start();
			auto n = new cnode(0);
			b[i-1][j] = s.stop();
		}
		GC.collect();
		GC.minimize();
	}
	for(int i = 0; i < runs; i++) {
		double sa = 0.0;
		foreach(it; a[i]) {
			sa += it;
		}
		printf("%d:%d; %f : ", i+1, a[i].length, sa/ runs);
		sa = 0.0;
		foreach(it; b[i]) {
			sa += it;
		}
		printfln("%f", sa/ runs);
	}
}
