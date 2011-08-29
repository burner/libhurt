module hurt.util.datetime;

public struct timeval {
	long tv_sec;
	long tv_usec;
}

extern(C) public long getMilli();
extern(C) public int gettimeofday(timeval*, void*);

alias long c_long;

version( Win32 )
{
	struct tm
	{
		int	 tm_sec;	 // seconds after the minute - [0, 60]
		int	 tm_min;	 // minutes after the hour - [0, 59]
		int	 tm_hour;	// hours since midnight - [0, 23]
		int	 tm_mday;	// day of the month - [1, 31]
		int	 tm_mon;	 // months since January - [0, 11]
		int	 tm_year;	// years since 1900
		int	 tm_wday;	// days since Sunday - [0, 6]
		int	 tm_yday;	// days since January 1 - [0, 365]
		int	 tm_isdst;   // Daylight Saving Time flag
	}
}
else
{
	struct tm
	{
		int	 tm_sec;	 // seconds after the minute [0-60]
		int	 tm_min;	 // minutes after the hour [0-59]
		int	 tm_hour;	// hours since midnight [0-23]
		int	 tm_mday;	// day of the month [1-31]
		int	 tm_mon;	 // months since January [0-11]
		int	 tm_year;	// years since 1900
		int	 tm_wday;	// days since Sunday [0-6]
		int	 tm_yday;	// days since January 1 [0-365]
		int	 tm_isdst;   // Daylight Savings Time flag
		c_long  tm_gmtoff;  // offset from CUT in seconds
		char*   tm_zone;	// timezone abbreviation
	}
}

alias c_long time_t;
alias c_long clock_t;

version(Win32) {
	enum:clock_t {CLOCKS_PER_SEC = 1000}
} else version(darwin) {
	enum:clock_t {CLOCKS_PER_SEC = 100}
} else version(freebsd) {
	enum:clock_t {CLOCKS_PER_SEC = 128}
} else version(solaris) {
	enum:clock_t {CLOCKS_PER_SEC = 1000000}
} else {
	enum:clock_t {CLOCKS_PER_SEC = 1000000}
}

extern(C) clock_t clock();
extern(C) double  difftime(time_t time1, time_t time0);
extern(C) time_t  mktime(tm* timeptr);
extern(C) time_t  time(time_t* timer);
extern(C) char*   asctime(in tm* timeptr);
extern(C) char*   ctime(in time_t* timer);
extern(C) tm*	 gmtime(in time_t* timer);
extern(C) tm*	 localtime(in time_t* timer);

/*
size_t  strftime(char* s, size_t maxsize, in char* format, in tm* timeptr);
size_t  wcsftime(wchar_t* s, size_t maxsize, in wchar_t* format, 
	in tm* timeptr);
*/

version(Win32) {
	void  tzset();
	void  _tzset();
	char* _strdate(char* s);
	char* _strtime(char* s);

	wchar_t* _wasctime(tm*);
	wchar_t* _wctime(time_t*);
	wchar_t* _wstrdate(wchar_t*);
	wchar_t* _wstrtime(wchar_t*);
} else version( darwin ) {
	void tzset();
} else version( linux ) {
	extern(C) void tzset();
} else version( freebsd ) {
	void tzset();
} else version( solaris ) {
	void tzset();
}

version( linux ) {
	extern(C) char* asctime_r(in tm*, char*);
	extern(C) char* ctime_r(in time_t*, char*);
	extern(C) tm*   gmtime_r(in time_t*, tm*);
	extern(C) tm*   localtime_r(in time_t*, tm*);
} else version( darwin ) {
	char* asctime_r(in tm*, char*);
	char* ctime_r(in time_t*, char*);
	tm*   gmtime_r(in time_t*, tm*);
	tm*   localtime_r(in time_t*, tm*);
} else version( freebsd ) {
	char* asctime_r(in tm*, char*);
	char* ctime_r(in time_t*, char*);
	tm*   gmtime_r(in time_t*, tm*);
	tm*   localtime_r(in time_t*, tm*);
} else version( solaris ) {
	char* asctime_r(in tm*, char*);
	char* ctime_r(in time_t*, char*);
	tm*   gmtime_r(in time_t*, tm*);
	tm*   localtime_r(in time_t*, tm*);
}

version( linux ) {
	extern(C) time_t timegm(tm*); // non-standard
} else version( darwin ) {
	time_t timegm(tm*); // non-standard
} else version( freebsd ) {
	time_t timegm(tm*); // non-standard
}

version( linux ) {
	extern __gshared int	  daylight;
	extern __gshared c_long   timezone;

	extern(C) tm*   getdate(in char*);
	extern(C) char* strptime(in char*, in char*, tm*);
} else version( darwin ) {
	extern __gshared c_long timezone;

	tm*   getdate(in char*);
	char* strptime(in char*, in char*, tm*);
} else version( freebsd ) {
	extern __gshared c_long timezone;

	//tm*   getdate(in char*);
	char* strptime(in char*, in char*, tm*);
} else version( solaris ) {
	extern __gshared c_long timezone;

	tm*   getdate(in char*);
	char* strptime(in char*, in char*, tm*);
}
