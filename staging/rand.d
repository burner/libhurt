import hurt.util.random.random;
import hurt.util.random.engines.urandom;
import hurt.io.stdio;

void main() {
	Random rg = new Random();
	for(int i = 0; i < 10; i++) {
		println(rg.next(100));
		println(rg.uniform!(real)());
	}

	RandomG!(URandom) ur = new RandomG!(URandom)();
	for(int i = 0; i < 10; i++) {
		println(ur.next(100));
		println(ur.uniform!(real)());
	}
	return;
}
