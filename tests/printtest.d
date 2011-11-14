import hurt.io.stdio;
import hurt.string.formatter;

private class Tmp {
	int i;
}

void main() {
	println("hello world", 4);
	println("hello world", 4);
	println(new Tmp());
	assert("hello" == format!(char,char)("hello"));
	assert("hello5" == format!(char,char)("hello%d", 5), format!(char,char)("hello%d", 5));
	assert("hello  5" == format!(char,char)("hello%*d", 3, 5), format!(char,char)("hello%*d", 3, 5));
	assert("hello+5" == format!(char,char)("hello%+d", 5), format!(char,char)("hello%+d", 5));
	assert("hello+5" == format!(char,char)("hello%+o", 5), format!(char,char)("hello%+o", 5));
	assert("hello+05" == format!(char,char)("hello%#+o", 5), format!(char,char)("hello%#+o", 5));
	assert("hello+5" == format!(char,char)("hello%+X", 5), format!(char,char)("hello%+X", 5));
	assert("hello+5" == format!(char,char)("hello%+x", 5), format!(char,char)("hello%+x", 5));
	assert("hello+A" == format!(char,char)("hello%+X", 10), format!(char,char)("hello%+X", 10));
	assert("hello+a" == format!(char,char)("hello%+x", 10), format!(char,char)("hello%+x", 10));
	assert("hello+0XA" == format!(char,char)("hello%#+X", 10), format!(char,char)("hello%#+X", 10));
	assert("hello+0xa" == format!(char,char)("hello%#+x", 10), format!(char,char)("hello%#+x", 10));
	assert("hello10" == format!(char,char)("hello%o", 8), format!(char,char)("hello%o", 8));
	assert("hello 10" == format!(char,char)("hello %o", 8), format!(char,char)("hello %o", 8));
	assert("hello10.0" == format!(char,char)("hello%.1f", 10.0), format!(char,char)("hello%.1f", 10.0));
	assert("hello 10.00" == format!(char,char)("hello %.2f", 10.0), format!(char,char)("hello %.2f", 10.0));
	assert("hello   10.00" == format!(char,char)("hello %7.2f", 10.0), format!(char,char)("hello %7.2f", 10.0));
	assert("hello 0010.00" == format!(char,char)("hello %07.2f", 10.0), format!(char,char)("hello %07.2f", 10.0));
	assert("hello 10.00  " == format!(char,char)("hello %-7.2f", 10.0), format!(char,char)("hello %-7.2f", 10.0));
	assert("hello 5.000" == format!(char,char)("hello%*.*f", 6, 3, 5.0), format!(char,char)("hello%*.*f", 6, 3, 5.0));
	assert("hello   5.000" == format!(char,char)("hello%*.*f", 8, 3, 5.0), format!(char,char)("hello%*.*f", 8, 3, 5.0));
	assert("hello 5.0e0" == format!(char,char)("hello %.1e", 5.0), format!(char,char)("hello %.1e", 5.0));
	assert("hello 5.0E0" == format!(char,char)("hello %.1E", 5.0), format!(char,char)("hello %.1E", 5.0));
}
