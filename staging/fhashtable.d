module hurt.container.fhashtable;

import hurt.container.isr;
import hurt.container.stack;
import hurt.conv.conv;
import hurt.util.slog;
import hurt.string.formatter;

import std.stdio;

class Iterator(T) : ISRIterator!(T) {
	private size_t oIdx; 
	private size_t tIdx; 
	private size_t backCnt;
	private FHashTable!(T) table;

	this(FHashTable!(T) table, size_t tIdx, size_t oIdx) {
		this.table = table;
		this.tIdx = tIdx;
		this.oIdx = oIdx;
		this.backCnt = 0;
	}

	public override Iterator!(T) dup() {
		return new Iterator!(T)(this.table, this.tIdx, this.oIdx);
	}

	override void increment() {
		if(this.table.table[tIdx].isValid() && this.oIdx == 0 &&
				this.table.table[tIdx].vPtr > 1) {
			this.oIdx = this.table.table[tIdx].vPtr;
		} else if(this.table.table[tIdx].isValid() && this.oIdx == 0 &&
				this.table.table[tIdx].vPtr == 1) {
			this.tIdx++;
			while(this.tIdx < this.table.table.length
					&& !this.table.table[tIdx].isValid()) {
				this.tIdx++;
			}
			this.oIdx = 0;
			return;
		} else if(this.table.table[tIdx].isValid() && this.oIdx > 1 &&
				this.table.overflow[this.oIdx].isValid()) {
			this.oIdx = this.table.overflow[this.oIdx].next;
			if(!this.table.overflow[this.oIdx].isValid()) {
				while(this.tIdx < this.table.table.length
						&& !this.table.table[this.tIdx].isValid()) {
					tIdx++;	
				}
				this.oIdx = 0;
			}
			return;
		} else if(this.table.table[this.tIdx].isValid() && this.oIdx == 1) {
			while(this.tIdx < this.table.table.length
					&& !this.table.table[this.tIdx].isValid()) {
				tIdx++;	
			}
			this.oIdx = 0;
			return;	
		} else {
			assert(false, format("Bad stuff just happend tIdx %d oIdx %d", 
				tIdx, oIdx));
		}
	}

	override void decrement() {
	}

	//public T opUnary(string s)() if(s == "*") {
	override T getData() {
		if(this.oIdx > 1) {
			return this.table.overflow[this.oIdx].data;
		} else if(this.oIdx <= 1 && this.table.table[this.tIdx].isValid()) {
			return this.table.table[this.tIdx].data;
		} else {
			assert(false, format("This Iterator was invalid. oIdx %d tIdx %d",
				this.oIdx, this.tIdx));
		}
	}

	public override bool isValid() const {
		if(this.tIdx == size_t.max || this.tIdx >= this.table.table.length) {
			return false;
		} else if(this.oIdx > 1) {
			return this.table.table[this.tIdx].isValid() && 
				this.table.overflow[this.oIdx].isValid();
		} else {
			return this.table.table[this.tIdx].isValid();
		}
	}
}

struct Node(T) {
	T data;
	size_t vPtr; /* 0 means not set, 1 means set but no list, everything
		else there is a list */

	this(T data, size_t vPtr = 1) {
		this.data = data;
		this.vPtr = vPtr;
	}

	T getData() {
		return this.data;
	}

	public size_t remove() {
		size_t ret = this.vPtr;
		this.vPtr = 0;
		return ret;
	}

	bool isValid() const @trusted {
		return this.vPtr != 0;
	}
}

struct NodeList(T) {
	T data;
	long next; 
	long prev;
	bool valid;

	this(T data, long next) {
		this.data = data;
		this.next = next;
		this.prev = 0;
		this.valid = true;
	}

	T getData() {
		return this.data;
	}

	public long remove() {
		this.valid = false;
		return this.next;
	}

	bool isValid() const @trusted {
		return this.valid;
	}
}

class FHashTable(T) {
	package Node!(T)[] table;
	private size_t function(T data) hashFunc;
	private size_t size;

	private size_t tail;
	private NodeList!(T)[] overflow;
	private Stack!(size_t) free;

	static size_t defaultHashFunc(T data) {
		static if(is(T : long) || is(T : int) || is(T : byte) || is(T : char)) {
			return cast(size_t)data;
		} else static if(is(T : long[]) || is(T : int[]) || is(T : byte[])
				|| is(T : char[]) || is(T : immutable(char)[])) {
			size_t ret;
			foreach(it;data) {
				ret = it + (ret << 6) + (ret << 16) - ret;
			}
			return ret;
		} else {
			assert(0);
		}
	}

	/*T[] values() {
		T[] ret = new T[this.size];
		size_t ptr = 0;
		foreach(it; this.table) {
			while(it !is null) {
				ret[ptr++] = it.data;
				it = it.next;
			}
		}
		return ret;
	}*/

	Iterator!(T) begin() {
		for(size_t i = 0; i < this.table.length; i++) {
			if(this.table[i].isValid()) {
				return new Iterator!(T)(this, i, 0);
			}
		}
		return new Iterator!(T)(this, size_t.max, 0);
	}

	Iterator!(T) end() {
		/*size_t idx = this.table.length-1;
		if(this.table.length == 0)
			return new Iterator!(T)(this,0,null);
		while(idx >= 0 && this.table.length > idx && this.table[idx] is null)
			idx--;
		if(idx >= this.table.length) 
			return new Iterator!(T)(this,0,null);

		Node!(T) end = this.table[idx];
		while(end.next !is null)
			end = end.next;*/
		
		//return new Iterator!(T)(this, idx, end);
		return null;
	}

	this(size_t function(T toHash) hashFunc = &defaultHashFunc) {
		this.hashFunc = hashFunc;
		this.table = new Node!(T)[128];
		this.overflow = new NodeList!(T)[32];
		this.free = new Stack!(size_t)();
		this.tail = 2;
	}

	public bool contains(T data) const {
		return this.search(data).isValid();
	}

	const Node!(T) search(T data) const {
		size_t hash = this.hashFunc(data) % this.table.length;
		size_t it = hash;
		if(this.table[it].isValid()) {
			if(this.table[it].data == data) {
				return this.table[it];	
			} else {
				size_t vPtr = this.table[it].vPtr;
				while(this.overflow[vPtr].isValid()) {
					if(this.overflow[vPtr].data == data) {
						return Node!(T)(this.overflow[vPtr].data, 
							this.overflow[vPtr].next);
					}
					vPtr = this.overflow[vPtr].next;
				}
			}
		}
		return Node!(T)();
	}

	/*ISRIterator!(T) searchIt(T data) {
		size_t hash = this.hashFunc(data) % this.table.length;
		Node!(T) it = this.table[hash];
		while(it !is null) {
			if(it.data == data)
				break;
			it = it.next;
		}
		return new Iterator!(T)(this,hash,this.search(data));
	}*/

	Node!(T) search(T data) {
		size_t hash = this.hashFunc(data) % this.table.length;
		size_t it = hash;
		if(this.table[it].isValid()) {
			if(this.table[it].data == data) {
				return this.table[it];	
			} else {
				size_t vPtr = this.table[it].vPtr;
				while(this.overflow[vPtr].isValid()) {
					if(this.overflow[vPtr].data == data) {
						return Node!(T)(this.overflow[vPtr].data, 
							this.overflow[vPtr].next);
					}
					vPtr = this.overflow[vPtr].next;
				}
			}
		}
		return Node!(T)();
	}

	/*public bool remove(ISRIterator!(T) it, bool dir = true) {
		if(it.isValid()) {
			T value = *it;
			if(dir)
				it++;
			else
				it--;
			return this.remove(value);
		} else {
			return false;
		}
	}*/

	bool remove(T data) {
		size_t hash = this.hashFunc(data) % this.table.length;

		// the head is what we search for
		if(this.table[hash].isValid() && this.table[hash].data == data) {
			if(this.table[hash].vPtr > 1) {
				size_t vPtrTmp = this.table[hash].vPtr;
				this.table[hash].data = this.overflow[vPtrTmp].data;
				this.table[hash].vPtr = this.overflow[vPtrTmp].next;
				this.releasePtr(vPtrTmp);
			} else if(this.table[hash].vPtr == 1) {
				this.table[hash].vPtr = 0;
			}
			this.size--;
			return true;

		// the first item in the overflow list is the item to remove
		} else if(this.table[hash].isValid() && this.table[hash].data != data &&
				this.table[hash].vPtr > 1 && 
				this.overflow[this.table[hash].vPtr].data == data) {
			size_t next = this.overflow[this.table[hash].vPtr].next;
			this.releasePtr(this.table[hash].vPtr);
			this.table[hash].vPtr = next;
			this.size--;
			return true;

		// remove a item in the overflow list
		} else if(this.table[hash].isValid() && this.table[hash].vPtr > 1) {
			size_t ne = this.overflow[this.table[hash].vPtr].next;
			while(this.overflow[ne].isValid()) {
				if(this.overflow[ne].data == data) {
					//this.overflow[ne].next = this.overflow[nene].next;
					long prev = this.overflow[ne].prev;
					long next = this.overflow[ne].next;
					this.overflow[prev].next = next;
					this.overflow[next].prev = prev;
					this.releasePtr(ne);
					this.size--;
					return true;
				}
				ne = this.overflow[ne].next;
			}
		}
		return false;
	}

	private void grow() {
		Node!(T)[] nTable = new Node!(T)[this.table.length*2];
		NodeList!(T)[] nOverflow = new NodeList!(T)[this.overflow.length*2];
		auto it = this.begin();
		for(; it.isValid(); it++) {
			this.insert(nTable, nOverflow, this.hashFunc(*it) % nTable.length, 
				*it);
		}
		this.table = nTable;
		this.overflow = nOverflow;
	}

	/*package Node!(T) getNode(size_t idx) {
		if(idx < this.table.length) {
			return this.table[idx];
		} else {
			return No;
		}
	}*/

	package size_t getTableSize() const {
		return this.table.length;
	}

	private void insert(Node!(T)[] t, NodeList!(T)[] overflow, size_t hash, 
			T data) {
		if(!t[hash].isValid()) {
			t[hash] = Node!(T)(data);
			return;
		} else {
			size_t oldNext = t[hash].vPtr;
			size_t nextPtr = this.nextPtr();
			log("%d %d", nextPtr, overflow.length);
			overflow[nextPtr] = NodeList!(T)(data, oldNext);
			log("%d %d", hash, t.length);
			t[hash].vPtr = nextPtr;
		}
	}

	bool insert(T data) {
		size_t filllevel = cast(size_t)(this.table.length*0.7);
		if(this.size + 1 > filllevel) {
			this.grow();
		}
		size_t hash = this.hashFunc(data) % table.length;
		insert(this.table, this.overflow, hash, data);
		this.size++;
		
		return true;
	}

	private void releasePtr(size_t ptr) {
		this.overflow[ptr].next = 0;
		this.overflow[ptr].prev = 0;
		this.overflow[ptr].valid = false;

		if(ptr + 1 == this.tail) {
			this.tail--;
		} else {
			this.free.push(ptr);
		}
	}

	private size_t nextPtr() {
		if(!this.free.isEmpty()) {
			return this.free.pop();
		} else if(this.tail == this.overflow.length) {
			this.overflow.length = this.overflow.length * 2;
			return this.tail++;
		} else {
			return this.tail++;
		}
	}

	public size_t getSize() const {
		return this.size;
	}

	public bool isEmpty() const {
		return this.size == 0;
	}
}

version(staging) {
void main() {
	return;
}
}

unittest {
	FHashTable!(int) fht = new FHashTable!(int)();
	fht.insert(66);
	assert(fht.begin().isValid());
	assert(fht.begin().getData() == 66);
	fht.insert(67);
	assert(fht.contains(66));
	assert(fht.contains(67));
	auto it = fht.begin();
	assert(it.isValid());
	int last = *it;
	assert(*it == 66 || *it == 67);
	it++;
	assert(it.isValid());
	assert((*it == 66 || *it == 67) && *it != last);
	assert(fht.remove(66));
	assert(!fht.contains(66));
}

unittest {
	int[][] lot = [[2811, 1089, 3909, 3593, 1980, 2863, 676, 258, 2499, 3147,
	3321, 3532, 3009, 1526, 2474, 1609, 518, 1451, 796, 2147, 56, 414, 3740,
	2476, 3297, 487, 1397, 973, 2287, 2516, 543, 3784, 916, 2642, 312, 1130,
	756, 210, 170, 3510, 987], [0,1,2,3,4,5,6,7,8,9,10],
	[10,9,8,7,6,5,4,3,2,1,0],[10,9,8,7,6,5,4,3,2,1,0,11],
	[0,1,2,3,4,5,6,7,8,9,10,-1],[11,1,2,3,4,5,6,7,8,0]];
	foreach(it; lot) {
		FHashTable!(int) ht = new FHashTable!(int)();
		assert(ht.getSize() == 0);
		foreach(idx,jt; it) {
			assert(ht.insert(jt));
			assert(ht.getSize() == idx+1);
			foreach(kt; it[0..idx+1]) {
				assert(ht.contains(kt));
				assert(ht.search(kt).isValid());
			}
			foreach(kt; it[idx+1..$]) {
				assert(!ht.contains(kt));
				assert(!ht.search(kt).isValid());
			}
		}
		foreach(idx,jt; it) {
			assert(ht.remove(jt));
			assert(ht.getSize() + idx + 1 == it.length);
			foreach(kt; it[0..idx]) {
				assert(!ht.contains(kt));
				assert(!ht.search(kt).isValid());
			}
			foreach(kt; it[idx+1..$]) {
				assert(ht.contains(kt));
				assert(ht.search(kt).isValid());
			}
		}
		assert(ht.getSize() == 0, conv!(size_t,string)(ht.getSize()));
	}
}

unittest {
	string[] words = [
"abbreviation","abbreviations","abettor","abettors","abilities","ability"
"abrasion","abrasions","abrasive","abrasives","absence","absences","abuse"
"abuser","abusers","abuses","acceleration","accelerations","acceptance"
"amperage","amperages","ampere","amperes","amplifier","amplifiers","amplitude"
"amplitudes","amusement","amusements","analog","analogs","analyses","analysis"
"analyst","analysts","analyzer","analyzers","anchor","anchors","angle","angles"
"animal","animals","annex","annexs","answer","answers","antenna","antennas"
"anthem","anthems","anticipation","apostrophe","apostrophes","apparatus"
"apparatuses","appeal","appeals","appearance","appearances","appellate","apple"
"apples","applicant","applicants","application","applications","apportionment"
"apportionments","appraisal","appraisals","apprehension","apprehensions"
"apprenticeship","apprenticeships","approach","approaches","appropriation"
"appropriations","approval","approvals","april","apron","aprons","aptitude"
"aptitudes","arc","arch","arches","architecture","arcs","area","areas"
"argument","arguments","arithmetic","arm","armament","armaments","armful"
"basements","bases","basics","basin","basins","basis","basket","baskets","bat"
"batch","batches","bath","bather","baths","bats","batteries","battery","battle"
"battles","battleship","battleships","baud","bauds","bay","bays","beach"
"beaches","beacon","beacons","bead","beads","beam","beams","bean","beans"
"bear","bearings","bears","beat","beats","bed","beds","beginner","beginners"
"behavior","behaviors","being","beings","belief","beliefs","bell","bells"
"belt","belts","bench","benches","bend","bends","benefit","benefits","berries"
"berry","berth","berthings","berths","bet","bets","bias","biases","bigamies"
"bigamy","bilge","bill","billet","billets","bills","bin","binder","binders"
"binoculars","bins","birth","births","bit","bite","bites","bits","blackboard"
"blackboards","blade","blades","blank","blanket","blankets","blanks","blast"
"blasts","blaze","blazes","blindfold","blindfolds","blink","blinks","block"
"butters","button","buttons","butts","buy","buys","buzz","buzzer","buzzers"
"buzzes","bypass","bypasses","byte","bytes","cab","cabinet","cabinets","cable"
"cables","cabs","cage","cages","cake","cakes","calculation","calculations"
"calculator","calculators","calendar","calendars","caliber","calibers"
"calibration","calibrations","call","calls","calorie","calories","cam","camera"
"cameras","camp","camps","cams","canal","canals","candidate","candidates"
"candle","candles","cane","canister","canisters","cannon","cannons","cans"
"canvas","canvases","canyon","canyons","cap","capabilities","capability"
"capacitance","capacitances","capacities","capacitor","capacitors","capacity"
"cape","capes","capital","capitals","caps","capstan","capstans","captain"
"captains","capture","captures","car","carbon","carbons","carburetor"
"carburetors","card","cardboard","cards","care","career","careers"
"cups","cure","cures","curl","curls","currencies","currency","currents"
"curtain","curtains","curvature","curvatures","curve","curves","cushion"
"cushions","custodian","custodians","custody","custom","customer","customers"
"customs","cuts","cycle","cycles","cylinder","cylinders","dab","dabs","dam"
"damage","damages","dams","danger","dangers","dare","dares","dart","darts"
"dash","data","date","dates","daughter","daughters","davit","davits","dawn"
"dawns","day","daybreak","days","daytime","deal","dealer","dealers","deals"
"dears","death","deaths","debit","debits","debris","debt","debts","decay"
"december","decibel","decibels","decimals","decision","decisions","deck"
"decks","decoder","decoders","decontamination","decoration","decorations"
"decrease","decreases","decrement","decrements","dedication","dedications"
"deduction","deductions","deed","deeds","default","defaults","defeat","defeats"
"defect","defection","defections","defects","defense","defenses","deficiencies"
"definition","definitions","deflector","deflectors","degree","degrees","delay"
"delays","delegate","delegates","deletion","deletions","delight","delights"
"delimiter","delimiters","deliveries","delivery","democracies","democracy"
"demonstration","demonstrations","densities","density","dent","dents"
"department","departments","departure","departures","dependence","dependencies"
"dependents","depletion","depletions","deployment","deployments","deposit"
"deposition","depositions","deposits","depot","depots","depth","depths"
"discontinuation","discontinuations","discount","discounts","discoveries"
"discovery","discrepancies","discrepancy","discretion","discrimination"
"discriminations","discussion","discussions","disease","diseases","disgust"
"dish","dishes","disk","disks","dispatch","dispatcher","dispatchers"
"dispatches","displacement","displacements","display","displays","disposal"
"dissemination","dissipation","distance","distances","distortion","distortions"
"distress","distresses","distribution","distributions","distributor"
"distributors","district","districts","ditch","ditches","ditto","dittos","dive"
"diver","divers","dives","divider","dividers","division","divisions","dock"
"dockings","docks","document","documentation","documentations","documents"
"dollar","dollars","dollies","dolly","dominion","dominions","donor","donors"
"door","doorknob","doorknobs","doors","doorstep","doorsteps","dope","dopes"
"dose","doses","dot","dots","doubt","downgrade","downgrades","dozen","dozens"
"draft","drafts","drag","drags","drain","drainage","drainer","drainers"
"drains","drawer","drawers","drawings","dress","dresses","drift","drifts"
"drill","driller","drillers","drills","drink","drinks","drip","drips","drive"
"driver","drivers","drives","drop","drops","drug","drugs","drum","drums"
"drunkeness","drunks","drydock","drydocks","dump","duplicate","duplicates"
"durability","duration","duress","dust","dusts","duties","duty","dwell","dye"
"dyes","dynamics","dynamometer","dynamometers","ear","ears","earth","ease"
"eases","east","echelon","echelons","echo","echoes","economies","economy"
"eddies","eddy","edge","edges","editor","editors","education","educator"
"educators","effect","effectiveness","effects","efficiencies","efficiency"
"expenditures","expense","expenses","experience","experiences","expert"
"experts","expiration","explanation","explanations","explosion","explosions"
"explosives","exposure","exposures","extension","extensions","extent"
"extenuation","extenuations","exterior","exteriors","extras","eye","eyes"
"fabrication","fabrications","face","facepiece","facepieces","faces"
"facilitation","facilities","facility","fact","factor","factories","factors"
"factory","facts","failure","failures","fake","fakes","fall","fallout","falls"
"families","family","fan","fans","fantail","fantails","farad","farads","fare"
"fares","farm","farms","fashion","fashions","fastener","fasteners","father"
"fathers","fathom","fathoms","fatigue","fatigues","fats","fault","faults"
"glossaries","glossary","glove","gloves","glow","glows","glue","glues","goal"
"goals","goggles","gold","goods","government","governments","governor"
"governors","grade","grades","grain","grains","gram","grams","grant","grants"
"graph","graphs","grasp","grasps","grass","grasses","gravel","gravity","grease"
"greases","greenwich","grid","grids","grinder","grinders","grip","grips"
"groan","groans","groceries","groom","grooms","groove","grooves","gross"
"grounds","group","groups","grove","groves","growth","growths","guard","guards"
"guess","guesses","guest","guests","guidance","guide","guideline","guidelines"
"guides","guilt","gulf","gulfs","gum","gums","gun","gunfire","gunnery"
"gunpowder","guns","guy","guys","gyro","gyros","gyroscope","gyroscopes","habit"
"habits","hail","hair","hairpin","hairpins","hairs","half","hall","halls"
"halt","halts","halves","halyard","halyards","hammer","hammers","hand"
"handful","handfuls","handle","handler","handlers","handles","hands"
"handwriting","hangar","hangars","harbor","harbors","hardcopies","hardcopy"
"hardness","hardship","hardships","hardware","harm","harmonies","harmony"
"harness","harnesses","harpoon","harpoons","hashmark","hashmarks","haste","hat"
"hatch","hatches","hatchet","hatchets","hate","hats","haul","hauls","hazard"
"hazards","head","header","headers","headings","headquarters","heads","headset"
"hydrometers","hygiene","hyphen","hyphens","ice","ices","icing","idea","ideal"
"ideals","ideas","identification","ignition","ignitions","illustration"
"illustrations","image","images","impact","impedance","implantation"
"implantations","implement","implementation","implementations","implements"
"importance","improvement","improvements","impulse","impulses","incentive"
"incentives","inception","inceptions","inch","inches","inclination"
"inclinations","incline","inclines","income","incomes","increase","increases"
"increment","increments","independence","index","indexes","indicate"
"indication","indications","indicator","indicators","individuals","inductance"
"industries","industry","infection","infections","inference","inferences"
"influence","influences","information","ingredient","ingredients","initial"
"initials","initiator","initiators","injection","injections","injector"
"injectors","injuries","injury","ink","inlet","inlets","input","inquiries"
"inquiry","insanities","insanity","insertion","insertions","insignia"
"insignias","inspection","inspections","installation","installations"
"lists","liter","liters","litre","litres","liver","livers","lives","load"
"loads","loaf","loan","loans","loaves","location","locations","lock","locker"
"lockers","locks","locomotive","locomotives","log","logic","logistics","logs"
"longitude","longitudes","look","lookout","lookouts","looks","loop","loops"
"loran","loss","losses","lot","lots","loudspeaker","loudspeakers","love"
"lubricant","lubricants","lubrication","lumber","lump","lumps","lung","lungs"
"machine","machinery","machines","macro","macros","magazine","magazines"
"magnesium","magnet","magneto","magnetos","magnets","magnitude","mail"
"mailbox","mailboxes","maintainability","maintenance","major","majorities"
"majority","majors","make","makes","makeup","male","males","malfunction"
"malfunctions","man","management","managements","manager","managers","maneuver"
"maneuvers","manifest","manifests","manner","manners","manpower","manual"
"manuals","manufacturer","manufacturers","map","maples","maps","marble"
"marbles","march","marches","margin","margins","marines","mark","market"
"meridians","mess","message","messages","messenger","messengers","messes"
"metal","metals","meter","meters","method","methodology","methods","metrics"
"microphone","microphones","midnight","midwatch","midwatches","mile","miles"
"milestone","milestones","military","milk","milks","mill","milligram"
"milligrams","milliliter","milliliters","millimeter","millimeters","million"
"millions","mills","mind","minds","mine","miner","mineral","minerals","miners"
"mines","minimum","minimums","minority","mint","mints","minuses","minute"
"minutes","mirror","mirrors","misalignment","misalignments","misalinement"
"misalinements","misconduct","misfit","misfits","misleads","miss","misses"
"missile","missiles","mission","missions","mist","mistake","mistakes"
"mistrial","mistrials","mists","mitt","mitten","mittens","mitts","mix","mixes"
"mixture","mixtures","mode","model","models","modem","modes","modification"
"modifications","module","modules","moisture","moistures","molecule"
"molecules","moment","moments","monday","mondays","money","moneys","monitor"
"monitors","monolith","monoliths","month","months","moon","moonlight","moons"
"mop","mops","morale","morals","morning","mornings","morphine","moss","mosses"
"motel","motels","mother","mothers","motion","motions","motor","motors","mount"
"mountain","mountains","mounts","mouth","mouths","move","movement","movements"
"mover","movers","moves","much","mud","mug","mugs","mule","mules","multimeter"
"multimeters","multiplex","multiplication","multiplications","multisystem"
"multisystems","multitask","multitasks","muscle","muscles","music","mustard"
"people","percent","percentage","percentages","percents","perfect"
"perforation","perforations","perforator","perforators","performance"
"performances","period","periods","permission","permit","permits","person"
"personalities","personality","personnel","persons","petition","petitions"
"petroleum","phase","phases","photo","photodiode","photodiodes","photograph"
"photographs","photos","physics","pick","picks","picture","pictures","piece"
"pieces","pier","piers","pile","piles","pilot","pilots","pin","pine","pines"
"pink","pins","pint","pints","pipe","pipes","pistol","pistols","piston"
"pistons","pit","pitch","pitches","pits","place","places","plan","plane"
"planes","plans","plant","plants","plastic","plastics","plate","plates"
"platform","platforms","plating","platter","platters","play","plays","plead"
"pleads","pleasure","plexiglass","plot","plots","plow","plug","plugs","pocket"
"pockets","point","pointer","pointers","points","poison","poisons","poke"
"pokes","polarities","polarity","pole","poles","police","polices","policies"
"policy","polish","polisher","polishers","polishes","poll","polls","pond"
"puddles","puff","puffs","pull","pulls","pulse","pulses","pump","pumps","punch"
"punches","puncture","punctures","punishment","punishments","pupil","pupils"
"purchase","purchaser","purchasers","purchases","purge","purges","purpose"
"purposes","push","pushdown","pushdowns","pushes","pushup","pushups","pyramid"
"pyramids","qualification","qualifications","qualifier","qualifiers"
"qualities","quality","quantities","quantity","quart","quarter","quarterdeck"
"quarterdecks","quartermaster","quartermasters","quarters","quarts","question"
"retention","retirement","retractor","retractors","retrieval","retrievals"
"return","returns","reveille","reverse","review","reviews","revision"
"revisions","revolution","revolutions","reward","rewards","rheostat"
"rheostats","rhythm","rhythms","rib","ribbon","ribbons","ribs","rice","riddle"
"riddles","ride","rides","riding","rifle","rifles","rifling","rig","rights"
"rigs","rim","rims","ringing","rings","rinse","rinses","river","rivers","road"
"roads","roadside","roar","roars","rock","rocket","rockets","rocks","rod"
"rods","roll","roller","rollers","rollout","rollouts","rolls","roof","roofs"
"room","rooms","root","roots","rope","ropes","rose","rotation","rotations"
"rotor","rotors","round","rounds","route","routes","routine","routines"
"rowboat","rowboats","rower","rowers","rubber","rubbish","rudder","rudders"
"rug","rugs","rule","rules","rumble","rumbles","run","runaway","runaways"
"runner","runners","runoff","runoffs","runout","runouts","runs","runway"
"runways","rush","rushes","rust","sabotage","sack","sacks","saddle","saddles"
"safeguard","safeguards","safety","sail","sailor","sailors","sails","sale"
"sales","salt","salts","salute","salutes","salvage","salvages","sample"
"samples","sand","sanitation","sap","saps","sash","sashes","satellite"
"satellites","saturday","saturdays","saving","savings","saying","scab","scabs"
"services","servo","servos","session","sessions","sets","setting","settings"
"settlement","settlements","setup","setups","sevens","sevenths","seventies"
"sewage","sewer","sewers","sex","sexes","shade","shades","shadow","shadows"
"shaft","shafts","shame","shape","shapes","share","shares","sharpener"
"sharpeners","shave","shaves","shears","sheds","sheet","sheeting","sheets"
"shelf","shell","shells","shelter","shelters","shelves","shield","shields"
"sunset","sunshine","superintendent","superlatives","supermarket"
"sweeps","swell","swells","swim","swimmer","swimmers","swims","swing","swings"
"switch","switches","swivel","swivels","sword","swords","symbol","symbols"
"symptom","symptoms","syntax","synthetics","system","systems","tab","table"
"tables","tablespoon","tablespoons","tablet","tablets","tabs","tabulation"
"tabulations","tachometer","tachometers","tack","tackle","tackles","tacks"
"tactic","tactics","tag","tags","tail","tailor","tailors","tails","takeoff"
"takeoffs","talk","talker","talkers","talks","tan","tank","tanks","tap","tape"
"threader","threaders","threads","threat","threats","threes","threshold"
"trunk","trunks","trust","trusts","truth","truths","try","tub","tube","tubes"
"tubing","tubs","tuesday","tuesdays","tug","tugs","tuition","tumble","tumbles"
"tune","tunes","tunnel","tunnels","turbine","turbines","turbulence","turn"
"turnaround","turnarounds","turns","turpitude","twenties","twig","twigs","twin"
"twine","twins","twirl","twirls","twist","twists","twos","type","types"
"typewriter","typewriters","typist","typists","umbrella","umbrellas"
"uncertainties","uncertainty","uniform","uniforms","union","unions","unit"
"units","universe","update","updates","upside","usage","usages","use","user"
"wonder","wonders","wood","woods","wool","wools","word","words","work"
"workbook","workbooks","workings","workload","workloads","workman","workmen"
"works","worksheet","worksheets","world","worlds","worm","worms","worries"
"worry","worth","wounds","wrap","wraps","wreck","wrecks","wrench","wrenches"
"wrist","wrists","writer","writers","writing","writings","yard","yards","yarn"
"yarns","yaw","yaws","year","years","yell","yells","yield","yields","yolk"
"yolks","zero","zeros","zip","zips","zone","zones","can","may","accounting"
"bearing","bracing","briefing","coupling","damping","ending","engineering"
"feeling","heading","meaning","rating","rigging","ring","schooling","sizing"
"sling","winding","inaction","nonavailability","nothing","broadcast","cast"
"cost","cut","drunk","felt","forecast","ground","hit","lent","offset","set"
"shed","shot","slit","thought","wound"];

	FHashTable!(string) st = new FHashTable!(string)();
	foreach(idx,word;words) {
		st.insert(word);
		foreach(kt; words[0..idx+1]) {
			assert(st.contains(kt));
		}
		foreach(kt; words[idx+1..$])
			assert(!st.contains(kt));
		assert(idx+1 == st.getSize(), conv!(size_t,string)(idx+1) ~
			" " ~ conv!(size_t,string)(st.getSize()));
		
		/*Iterator!(string) it = st.begin();
		size_t cnt = 0;
		while(it.isValid()) {
			assert(st.contains(*it));
			it++;
			cnt++;
		}
		assert(cnt == st.getSize(), conv!(size_t,string)(cnt) ~
			" " ~ conv!(size_t,string)(st.getSize()));

		it = st.end();
		cnt = 0;
		//writeln();
		while(it.isValid()) {
			//writeln(*it);
			assert(st.search(*it));
			it--;
			cnt++;
		}
		assert(cnt == st.getSize(), conv!(size_t,string)(cnt) ~
			" " ~ conv!(size_t,string)(st.getSize()));
		*/
	}
}/*

	foreach(idx,jt; words) {
		assert(st.remove(jt));
		foreach(kt; words[0..idx])
			assert(!st.search(kt));
		foreach(kt; words[idx+1..$])
			assert(st.search(kt));

		Iterator!(string) it = st.begin();
		size_t cnt = 0;
		while(it.isValid()) {
			assert(st.search(*it));
			it++;
			cnt++;
		}
		assert(cnt == st.getSize(), conv!(size_t,string)(cnt) ~
			" " ~ conv!(size_t,string)(st.getSize()));

		it = st.end();
		cnt = 0;
		while(it.isValid()) {
			assert(st.search(*it));
			it--;
			cnt++;
		}
		assert(cnt == st.getSize(), conv!(size_t,string)(cnt) ~
			" " ~ conv!(size_t,string)(st.getSize()));
	}

	for(int i = 0; i < lot[0].length; i++) {
		HashTable!(int) itT = new HashTable!(int)();
		foreach(it; lot[0]) {
			itT.insert(it);
		}
		assert(itT.getSize() == lot[0].length);
		Iterator!(int) be = itT.begin();
		while(be.isValid())
			assert(itT.remove(be, true));
		assert(itT.getSize() == 0);
	}

	for(int i = 0; i < lot[0].length; i++) {
		HashTable!(int) itT = new HashTable!(int)();
		foreach(it; lot[0]) {
			itT.insert(it);
		}
		assert(itT.getSize() == lot[0].length);
		Iterator!(int) be = itT.end();
		while(be.isValid())
			assert(itT.remove(be, false));
		assert(itT.getSize() == 0);
	}*/
