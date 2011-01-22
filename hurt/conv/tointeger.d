module hurt.conv.tointeger;

import hurt.conv.convutil;
import hurt.conv.chartonumeric;

public pure int stringToInt(in string str) {
	int ret = 0;
	int mul = 1;	
	int tmp;
		
	foreach_reverse(it; str) {
		// ignore underscores
		if(it == '_') continue;

		// panic if char isn't a digit
		if(!isDigit(it)) {
			assert(0, "is not digit");
		}

		// construct the number
		tmp = chartobase10(it) * mul;	
		ret += tmp;
		mul *= 10;
	}
	return ret;
}
