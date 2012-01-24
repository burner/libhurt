module hurt.util.random.random;

import hurt.time.time;
import hurt.time.wallclock;

int rand(int low = 0, int up = int.max) {
	immutable M = 2147483647;
	immutable A = 16807;
	static int seed = 1;

	seed = A * ( seed % (M/A) ) - (M%A) * ( seed / (M/A) );
	if(seed <= 0)
		seed += M;

	return (seed + low) % up;
}
