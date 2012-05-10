module hurt.string.spell;

import hurt.container.set;
import hurt.container.deque;
import hurt.math.mathutil;
import hurt.io.stdio;
import hurt.util.pair;

private Set!(string) permutate(string word) {
	immutable string perm = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

	static assert(perm.length == 52);
	Set!(string) result = new Set!(string)();
	for(int i=0; i < word.length; ++i) {
		result.insert(word[0 .. i] ~ word[i+1 .. $]);
	}

	for(int i=0; i < word.length-1; ++i) {
		result.insert(word[0 .. i] ~ word[i+1 .. i+2] ~ word[i .. i+1] ~ word[i+2 .. $]);
	}

	for(int i=0; i < word.length; ++i) {
		foreach(char c; perm) {
			result.insert(word[0 .. i] ~ c ~ word[i+1 .. $]);
		}
	}
	for(int i=0; i <= word.length; ++i) {
		foreach(char c; perm) {
			result.insert(word[0 .. i] ~ c ~ word[i .. $]);
		}
	}
	return result;
}

private Set!(string) perm2(string word) {
	immutable string perm = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	bool whereNull = false;

	auto ret = new Set!(string)();

	Deque!(Pair!(string,string)) splits = new Deque!(Pair!(string,string))();	
	// split
	for(int i = 0; i <= word.length; i++) {
		splits.pushBack(Pair!(string,string)(word[0 .. i], word[i .. $]));
	}

	foreach(it; splits) {
		if(it.second.length == 0) {
			continue;
		}
		ret.insert(it.first ~ it.second[1 .. $]);
		if(it.second.length > 1) {
			ret.insert(it.first ~ it.second[1] ~ it.second[0] ~ it.second[2 .. $]);
		}

		foreach(jt; perm) {
			ret.insert(it.first ~ jt ~ it.second[1 .. $]);
			ret.insert(it.first ~ jt ~ it.second);
		}
	}
	
	return ret;
}

private pure int minimum(int a, int b, int c) { 
	return min(min(a, b), c); 
}

public pure int levenshteinDistance(string str1, string str2) {
	int[][] distance = new int[][](str1.length + 1,str2.length + 1);

	for(int i = 0; i <= str1.length; i++) { 
		distance[i][0] = i; 
	} 
	
	for(int j = 0; j <= str2.length; j++) {
		distance[0][j] = j;
	}

	for (int i = 1; i <= str1.length; i++) {
		for (int j = 1; j <= str2.length; j++) {
			distance[i][j] = minimum( distance[i - 1][j] +
				1, distance[i][j - 1] + 1, distance[i - 1][j - 1] + 
				((str1[i-1] == str2[j - 1]) ? 0 : 1));
		}
	}

	return distance[str1.length][str2.length];
}

version(staging) {
void main() {
	return;
}
}
