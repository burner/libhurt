module hurt.io.progressbar;

import hurt.io.stdio;

public void updateBar(int i, int n, int w = 60) {
	// Only update r times.
	if( i % (n/1000) != 0 ) 
		return;

	// Calculuate the ratio of complete-to-incomplete.
	float ratio = i/cast(float)n;
	int   c	 = cast(int)(ratio * w);
 
	// Show the percentage complete.
	printf("%3d%% [", cast(int)(ratio*100) );
 
	// Show the load bar.
	for(int x=0; x<c; x++) {
	   printf("=");
	}
 
	for(int x=c; x<w; x++) {
	   printf(" ");
	}
 
 	printf("]");
	// ANSI Control codes to go back to the
	// previous line and clear it.
	// printf("]\n33[F33[J");
	printf("\r"); // Move to the first column
	flushStdout();
}

public void barDone(int n, int w = 60) {
	float ratio = 100/99;
	int c = cast(int)(ratio * w);

	// Show the percentage complete.
	printf("%3d%% [", 100 );
 
	// Show the load bar.
	for (int x=0; x<c; x++) {
	   printf("=");
	}
 	printfln("]");
}

version(staging) {
void main() {
	int till = 1000;
	for(int i = 0; i < till; i++) {
		updateBar(i, till);
	}
	barDone(till);
}
}
