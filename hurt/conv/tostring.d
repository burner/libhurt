module hurt.conv.tostring;

import hurt.conv.numerictochar;

public pure string intToString(int src) {
	char[16] tmp;
	uint tmpptr = 0;
	bool sign = false;
	if(src < 0) {
		src = -src;
		sign = true;
		tmp[tmpptr++] = '-';
	}
	byte toConv;
	while(src) {
		toConv = cast(byte)(src % 10);	
		tmp[tmpptr++] = byteToCharBase10(toConv);
		src /= 10;
	}
	if(sign) {
		tmp[1..tmpptr].reverse;
		return tmp[0..tmpptr].idup;
	} else 
		return tmp[0..tmpptr].reverse.idup;
}

public pure string shortToString(short src) {
	char[8] tmp;
	uint tmpptr = 0;
	bool sign = false;
	if(src < 0) {
		src = -src;
		sign = true;
		tmp[tmpptr++] = '-';
	}
	byte toConv;
	while(src) {
		toConv = cast(byte)(src % 10);	
		tmp[tmpptr++] = byteToCharBase10(toConv);
		src /= 10;
	}
	if(sign) {
		tmp[1..tmpptr].reverse;
		return tmp[0..tmpptr].idup;
	} else 
		return tmp[0..tmpptr].reverse.idup;
}
