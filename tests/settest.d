import hurt.container.set;
import hurt.conv.conv;
import oldset;

import std.stdio;

void print(OldSet!(int) old, Set!(int) ne) {
	write("old: ");
	foreach(it;old.values()) {
		write(it, " ");
	}
	writeln();	
	write("new: ");
	foreach(it;ne) {
		write(it, " ");
	}
	writeln();	
}

bool same(OldSet!(int) old, Set!(int) ne) {
	if(old.getSize() != ne.getSize()) {
		return false;
	}
	int runsOld = 0;
	foreach(it;old.values()) {
		if(!ne.contains(it)) {
			return false;
		}
		runsOld++;
	}
	outer: foreach(it;old.values()) {
		foreach(jt; ne) {
			if(it == jt) {
				continue outer;
			}
		}
		print(old, ne);
		return false;
	}
	int runsNew = 0;
	foreach(it;ne) {
		if(!ne.contains(it)) {
			return false;
		}
		runsNew++;
	}
	if(runsOld != runsNew) {
		return false;
	}
	return true;
}

bool containsFor(Set!(int) a) {
	foreach(it; a) {
		if(!a.contains(it)) {
			return false;
		}
	}
	return true;
}

void main() {
	Set!(int) a = new Set!(int);
	a.insert(0);
	assert(a.contains(0));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(containsFor(a));
	a.insert(13);
	assert(a.contains(0));
	assert(a.contains(13));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(containsFor(a));
	a.insert(11);
	assert(a.contains(0)); 
	assert(a.contains(13));
	assert(a.contains(11));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(containsFor(a));
	a.clear();
	a.insert(0);
	assert(a.contains(0));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(containsFor(a));
	a.insert(11);
	assert(a.contains(0) && a.contains(11));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(containsFor(a));
	a.insert(13);
	assert(a.contains(0) && a.contains(13) && a.contains(11));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(a.getSize() == 3);
	assert(containsFor(a));
	a.clear();
	a.insert(11);
	assert(a.contains(11));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(containsFor(a));
	a.insert(0);
	assert(a.contains(0) && a.contains(11));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(containsFor(a));
	a.insert(13);
	assert(a.contains(0) && a.contains(13) && a.contains(11));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(a.getSize() == 3);
	assert(containsFor(a));
	a.clear();
	a.insert(11);
	assert(a.contains(11));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(containsFor(a));
	a.insert(13);
	assert(a.contains(13) && a.contains(11));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(containsFor(a));
	a.insert(0);
	assert(a.contains(0) && a.contains(13) && a.contains(11));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(a.getSize() == 3);
	assert(containsFor(a));
	a.clear();
	a.insert(13);
	assert(a.contains(13));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(containsFor(a));
	a.insert(11);
	assert(a.contains(13) && a.contains(11));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(containsFor(a));
	a.insert(0);
	assert(a.contains(0) && a.contains(13) && a.contains(11));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(a.getSize() == 3);
	assert(containsFor(a));
	a.clear();
	a.insert(13);
	assert(a.contains(13));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(containsFor(a));
	a.insert(0);
	assert(a.contains(13) && a.contains(0));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(containsFor(a));
	a.insert(11);
	assert(a.contains(0) && a.contains(13) && a.contains(11));
	assert(a.contains(**a.end()));
	assert(a.contains(**a.begin()));
	assert(a.getSize() == 3);
	assert(containsFor(a));


	int[] st1 = [0,1,2,3,4,5,6,7,8,9,10];
	Set!(int) st = new Set!(int);
	OldSet!(int) sto = new OldSet!(int);
	foreach(idx,it;st1) {
		st.insert(it);
		sto.insert(it);
		assert(containsFor(st));
		assert(st.contains(**st.end()));
		assert(st.contains(**st.begin()));
		assert(same(sto, st), "shoule hold the same values");
		foreach(jt;st1[0..idx]) {
			assert(st.contains(jt));
		}
		foreach(jt;st1[idx+1..$]) {
			assert(!st.contains(jt));
		}
	}
	foreach(idx,it;st1) {
		st.remove(it);
		sto.remove(it);
		assert(containsFor(st));
		assert(same(sto, st), "shoule hold the same values");
		foreach(jt;st1[0..idx]) {
			assert(!st.contains(jt));
		}
		foreach(jt;st1[idx+1..$]) {
			assert(st.contains(jt));
		}
	}
	int[] st2 = [10,9,8,7,6,5,4,3,2,1,0];
	Set!(int) stt = new Set!(int);
	OldSet!(int) stto = new OldSet!(int);
	foreach(idx,it;st2) {
		stt.insert(it);
		stto.insert(it);
		assert(containsFor(stt));
		assert(stt.contains(**stt.end()));
		assert(stt.contains(**stt.begin()));
		assert(same(stto, stt), "shoule hold the same values");
		foreach(jt;st2[0..idx]) {
			assert(stt.contains(jt));
		}
		foreach(jt;st2[idx+1..$]) {
			assert(!stt.contains(jt));
		}
	}
	foreach(idx,it;st2) {
		stt.remove(it);
		stto.remove(it);
		assert(containsFor(stt));
		assert(same(stto, stt), "shoule hold the same values");
		foreach(jt;st2[0..idx]) {
			assert(!stt.contains(jt));
		}
		foreach(jt;st2[idx+1..$]) {
			assert(stt.contains(jt));
		}
	}
	OldSet!(int) intTest = new OldSet!(int)();
	OldSet!(int) intTestCopy = intTest.dup();
	Set!(int) intTestNew = new Set!(int);
	Set!(int) intTestNewCopy = new Set!(int);

	assert(intTest == intTestCopy, "should be the same");
	assert(same(intTest, intTestNew), "shoule hold the same values");
	assert(intTestNew == intTestNewCopy, "should be the same");
	int[] t = [123,13,5345,752,12,3,1,654,22];

	foreach(idx,it;t) {
		assert(intTest.insert(it));
		assert(it == *intTestNew.insert(it));
		assert(same(intTest, intTestNew), "shoule hold the same values");
		assert(containsFor(intTestNew));
		foreach(jt;t[0..idx]) {
			assert(intTest.contains(jt));
			assert(intTestNew.contains(jt));
		}
		assert(intTest != intTestCopy, "should not be the same");
		assert(intTestNew != intTestNewCopy, "should not be the same");
		intTestCopy = intTest.dup();
		intTestNewCopy = intTestNew.dup();
		assert(intTest == intTestCopy, "should be the same");
		assert(intTestNew == intTestNewCopy, "should be the same");
		assert(containsFor(intTestNewCopy));
		foreach(jt;t[idx+1..$]) {
			assert(!intTest.contains(jt));
			assert(!intTestNew.contains(jt));
		}
	}

	foreach(idx,it;t) {
		assert(!intTest.insert(it), conv!(int,string)(it));
		assert(intTest.contains(it), conv!(int,string)(it));
		assert(intTestNew.contains(it), conv!(int,string)(it));
		assert(same(intTest, intTestNew), "shoule hold the same values");
		intTestCopy = intTest.dup();
		intTestNewCopy = intTestNew.dup();
		assert(intTest == intTestCopy, "should be the same");
		assert(intTestNew == intTestNewCopy, "should be the same");
	}

	foreach(idx,it;t) {
		assert(intTest.remove(it), conv!(int,string)(it));
		intTestNew.remove(it);
		assert(same(intTest, intTestNew), "shoule hold the same values");
		assert(!intTest.contains(it), conv!(int,string)(it));
		assert(!intTestNew.contains(it), conv!(int,string)(it));
		foreach(jt;t[0..idx]) {
			assert(!intTest.contains(jt));
			assert(!intTestNew.contains(jt));
		}
		foreach(jt;t[idx+1..$]) {
			assert(intTest.contains(jt));
			assert(intTestNew.contains(jt));
		}
		intTestCopy = intTest.dup();
		intTestNewCopy = intTestNew.dup();
		assert(intTest == intTestCopy, "should be the same");
		assert(intTestNew == intTestNewCopy, "should be the same");
		assert(same(intTestCopy, intTestNewCopy), 
			"shoule hold the same values");
	}
	int[] lots = [2811, 1089, 3909, 3593, 1980, 2863, 676, 258, 2499, 3147, 3321, 3532, 3009,
	1526, 2474, 1609, 518, 1451, 796, 2147, 56, 414, 3740, 2476, 3297, 487, 1397,
	973, 2287, 2516, 543, 3784, 916, 2642, 312, 1130, 756, 210, 170, 3510, 987,
	3833, 1396, 3395, 2571, 1881, 1621, 2565, 3689, 1286, 3636, 824, 775, 1412,
	530, 2891, 2602, 1614, 241, 1489, 1938, 1035, 1161, 2795, 817, 1105, 931, 3220,
	186, 1542, 2624, 520, 1703, 3879, 3400, 162, 2052, 889, 2954, 474, 1663, 1971,
	2057, 3485, 2113, 2294, 743, 2680, 2174, 2142, 2986, 1942, 3167, 2336, 521,
	1734, 2968, 446, 2656, 3738, 1245, 2152, 933, 240, 766, 3753, 3772, 1370, 3050,
	3080, 610, 269, 3145, 3524, 1465, 2735, 1638, 2211, 2351, 428, 2848, 257, 412,
	2852, 2402, 1428, 3258, 3958, 1944, 2701, 2355, 1042, 2892, 120, 2066, 2682,
	3921, 1261, 3755, 752, 3852, 2667, 444, 3106, 161, 3174, 1431, 14, 2117, 2844,
	119, 2267, 3944, 3924, 1782, 2230, 2943, 3952, 3969, 3561, 3504, 2183, 3381,
	2056, 2034, 724, 1545, 886, 1480, 2280, 3959, 3214, 2475, 1724, 2699, 3574,
	1746, 105, 1900, 2876, 2187, 3353, 2430, 2584, 2482, 1625, 720, 1475, 2772,
	2757, 2432, 918, 3615, 3876, 786, 2139, 2815, 1544, 1263, 1264, 2993, 3328,
	1761, 2107, 727, 1941, 141, 2895, 3840, 3581, 3248, 1067, 3667, 292, 1832, 924,
	2619, 2816, 2724, 1797, 706, 959, 1326, 3881, 710, 3735, 385, 3655, 2006, 1538,
	1647, 1865, 3945, 3462, 366, 398, 1445, 2510, 3920, 1254, 3720, 2897, 582,
	3437, 3998, 781, 2706, 1830, 1010, 977, 3569, 3761, 1550, 1420, 2610, 2750,
	2665, 2290, 330, 3171, 609, 1549, 2364, 314, 134, 958, 3355, 1979, 2207, 1736,
	1384, 2693, 2550, 504, 361, 3281, 2240, 189, 893, 1323, 3769, 2744, 1288, 3201,
	1162, 2960, 3272, 3930, 1727, 297, 2098, 2579, 282, 2257, 615, 1681, 3211, 382,
	3413, 2887, 2083, 2168, 1373, 1918, 2368, 2204, 3766, 1897, 3525, 1154, 153,
	98, 2949, 3315, 3436, 3823, 694, 2800, 2133, 2586, 1046, 1191, 91, 3418, 2546,
	2473, 1906, 49, 2564, 2721, 1273, 2260, 1276, 89, 725, 1140, 678, 3347, 3467,
	547, 1555, 1217, 2123, 2544, 1180, 1786, 1922, 850, 3110, 2472, 666, 669, 699,
	17, 1845, 985, 3843, 3444, 892, 1976, 291, 2901, 2697, 1259, 376, 1997, 1812,
	6, 1641, 2079, 1999, 715, 3229, 2910, 961, 1513, 3700, 3537, 3717, 2996, 2990,
	656, 3767, 2237, 1996, 3318, 169, 1810, 963, 2830, 1716, 2383, 1498, 3814,
	1155, 951, 3702, 772, 1551, 3385, 1357, 3157, 425, 3880, 3042, 1054, 1298,
	3408, 771, 903, 968, 2011, 454, 707, 972, 1206, 93, 1393, 1085, 932, 598, 2691,
	2041, 2492, 947, 256, 681, 2421, 861, 719, 2792, 313, 2390, 1205, 2456, 419,
	2958, 2557, 1890, 2467, 1951, 2457, 3973, 2531, 1157, 3168, 136, 842, 2705,
	1382, 3642, 3051, 566, 1315, 3894, 592, 1311, 1472, 3137, 409, 603, 3573, 946,
	2073, 2310, 3965, 851, 3107, 3841, 2718, 1578, 3926, 1732, 1588, 3097, 1359,
	3608, 3163, 2513, 2278, 3295, 3098, 2268, 76, 799, 1098, 488, 952, 2630, 3604,
	3889, 20, 966, 2974, 2770, 1998, 983, 1499, 1833, 277, 1235, 3270, 2794, 3465,
	115, 3298, 915, 1965, 3096, 1800, 750, 3651, 1368, 31, 144, 198, 825, 2807,
	349, 420, 1283, 2137, 2633, 1671, 3483, 1569, 1372, 264, 1693, 1898, 2415,
	3943, 1940, 3150, 2214, 51, 2365, 2580, 3977, 2234, 805, 3555, 1455, 1313,
	2877, 112, 1345, 554, 3971, 1139, 1461, 2403, 2664, 3002, 2120, 1102, 3723,
	747, 3030, 626, 499, 2980, 2587, 2702, 478, 506, 2498, 906, 294, 2873, 107,
	1566, 2478, 3680, 1025, 1985, 3371, 1910, 3116, 1827, 2143, 8, 1122, 1552,
	1189, 2804, 2354, 870, 3156, 254, 2726, 2652, 1799, 1763, 2019, 3329, 32, 472,
	3666, 3384, 1306, 3698, 373, 3390, 3927, 3570, 1709, 2163, 2304, 935, 549,
	1834, 1004, 668, 637, 1891, 1593, 3942, 1458, 896, 84, 183, 2603, 1631, 2452,
	3311, 1403, 2686, 1249, 1720, 2781, 3070, 3737, 1636, 3487, 2496, 145, 3559,
	156, 2458, 2425, 459, 564, 3665, 672, 713, 995, 285, 3803, 2538, 3162, 2002,
	1912, 2529, 3980, 2554, 3730, 1266, 1882, 3277, 1896, 3506, 2192, 255, 3805,
	3993, 3039, 3988, 300, 2846, 3913, 2106, 2604, 1874, 1192, 3529, 468, 3758,
	2063, 3491, 2598, 928, 2870, 3332, 3512, 443, 1332, 2195, 2817, 1501, 2045,
	2219, 1774, 1338, 1328, 575, 3634, 2577, 1108, 406, 2521, 1020, 482, 1523, 64,
	3853, 867, 3523, 1421, 3314, 408, 3018, 559, 212, 787, 2039, 2157, 177, 375,
	2821, 2939, 3792, 2380, 1300, 2722, 3476, 3244, 3431, 2978, 1547, 2964, 3256,
	3950, 2948, 3773, 73, 4, 3035, 2015, 339, 2560, 1305, 1090, 449, 1837, 324,
	180, 1764, 2687, 3874, 962, 3648, 2266, 3471, 3259, 452, 588, 2692, 1770, 3011,
	3538, 2839, 3426, 2203, 2443, 3323, 1201, 3748, 2559, 1277, 2431, 2335, 230,
	2217, 1603, 2882, 1879, 2698, 555, 1690, 567, 3902, 195, 749, 276, 3857, 2749,
	1150, 2549, 3904, 2031, 563, 921, 2556, 3712, 3825, 644, 1628, 279, 3212, 2194,
	265, 3864, 3661, 273, 1654, 1362, 1257, 1469, 1869, 1565, 109, 1811, 2738,
	1187, 869, 1281, 2110, 2360, 3324, 2831, 2539, 599, 3149, 1204, 3028, 868,
	3657, 3505, 437, 3266, 61, 2884, 3686, 3361, 2146, 2224, 1601, 3319, 3754,
	1279, 1543, 1340, 2323, 1835, 3155, 3563, 194, 1349, 2574, 1438, 2683, 3709,
	96, 798, 1801, 2828];
	Set!(int) big = new Set!(int)();
	foreach(idx,it; lots) {
		big.insert(it);
		assert(containsFor(big));
		assert(big.contains(**big.end()));
		assert(big.contains(**big.begin()));
		foreach(jt; lots[0..idx]) {
			assert(big.contains(jt));
		}
		foreach(jt; lots[idx+1..$]) {
			assert(!big.contains(jt));
		}
	}

	writeln("set compare test done");
}
