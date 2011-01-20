module hurt.conv.tointeger;

import hurt.conv.convutil;
import hurt.conv.chartonumeric;

int stringToInt(in string str) {
	int ret = 0;
	int mul = 1;	
	int tmp;
		
	foreach(it; str) {
		if(!isDigit(it)) {
			assert(0, "is not digit");
		}
		tmp = chartobase10(it) * mul;	
		ret += tmp;
		mul *= 10;
	}
	return ret;
}
