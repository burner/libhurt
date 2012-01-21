module hurt.util.random;

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

struct Twister
{
	 private enum : uint {
		  // Period parameters
		  N			 = 624,
		  M			 = 397,
		  MATRIX_A	= 0x9908b0df,		  // constant vector a 
		  UPPER_MASK = 0x80000000,		  //  most significant w-r bits 
		  LOWER_MASK = 0x7fffffff,		  // least significant r bits
	 }
	 enum int canCheckpoint=true;
	 enum int canSeed=true;

	 private uint[N] mt;							// the array for the state vector  
	 private uint mti=mt.length+1;			  // mti==mt.length+1 means mt[] is not initialized 

	this(uint s) {
		this.seed(delegate() {
			Time no = WallClock.now();
			return cast(uint)no.ticks() + s;
			});
	}
	 
	 /// returns a random uint
	 uint next() {
		  uint y;
		  static uint mag01[2] =[0, MATRIX_A];

		  if (mti >= mt.length) { 
				int kk;

				for (kk=0;kk<mt.length-M;kk++)
				{
					 y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
					 mt[kk] = mt[kk+M] ^ (y >> 1) ^ mag01[y & 1U];
				}
				for (;kk<mt.length-1;kk++) {
					 y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
					 mt[kk] = mt[kk+(M-mt.length)] ^ (y >> 1) ^ mag01[y & 1U];
				}
				y = (mt[mt.length-1]&UPPER_MASK)|(mt[0]&LOWER_MASK);
				mt[mt.length-1] = mt[M-1] ^ (y >> 1) ^ mag01[y & 1U];

				mti = 0;
		  }

		  y = mt[mti++];

		  y ^= (y >> 11);
		  y ^= (y << 7)  &  0x9d2c5680UL;
		  y ^= (y << 15) &  0xefc60000UL;
		  y ^= (y >> 18);

		  return y;
	 }
	 /// returns a random byte
	 ubyte nextB(){
		  return cast(ubyte)(next() & 0xFF);
	 }
	 /// returns a random long
	 ulong nextL(){
		  return ((cast(ulong)next)<<32)+cast(ulong)next;
	 }

	 void seed() {
		this.seed(delegate() {
			Time no = WallClock.now();
			return cast(uint)no.ticks();
			});
	 }
	 
	 /// initializes the generator with a uint as seed
	 void seed (uint s)
	 {
		  mt[0]= s & 0xffff_ffffU;  // this is very suspicious, was the previous line incorrectly translated from C???
		  for (mti=1; mti<mt.length; mti++){
				mt[mti] = cast(uint)(1812433253UL * (mt[mti-1] ^ (mt[mti-1] >> 30)) + mti);
				mt[mti] &= 0xffff_ffffUL; // this is very suspicious, was the previous line incorrectly translated from C???
		  }
	 }
	 /// adds entropy to the generator
	 void addEntropy(scope uint delegate() r){
		  int i, j, k;
		  i=1;
		  j=0;

		  for (k = mt.length; k; k--)	{
				mt[i] = cast(uint)((mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1664525UL))+ r() + j); 
				mt[i] &=  0xffff_ffffUL;  // this is very suspicious, was the previous line incorrectly translated from C???
				i++;
				j++;

				if (i >= mt.length){
						  mt[0] = mt[mt.length-1];
						  i=1;
				}
		  }

		  for (k=mt.length-1; k; k--)	  {
				mt[i] = cast(uint)((mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1566083941UL))- i); 
				mt[i] &=  0xffffffffUL;  // this is very suspicious, was the previous line incorrectly translated from C???
				i++;

				if (i>=mt.length){
						  mt[0] = mt[mt.length-1];
						  i=1;
				}
		  }
		  mt[0] |=  0x80000000UL; 
		  mti=0;
	 }
	 /// seeds the generator
	 void seed(scope uint delegate() r){
		  seed(19650218UL);
		  addEntropy(r);
	 }
}
