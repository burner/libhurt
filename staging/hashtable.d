module hashtable;

import isr;

import std.stdio;

import hurt.conv.conv;

class Iterator(T) : ISRIterator!(T) {
	private size_t idx; 
	private Node!(T) curNode;
	private HashTable!(T) table;

	this(HashTable!(T) table, size_t idx, Node!(T) curNode) {
		this.table = table;
		this.idx = idx;
		this.curNode = curNode;
	}

	public void opUnary(string s)() if(s == "++") {

	}

	public void opUnary(string s)() if(s == "--") {

	}

	public T opUnary(string s)() if(s == "*") {
		if(this.isValid())
			return this.curNode.getData();
		else
			assert(0, "Iterator was not valid");
	}

	public bool isValid() const {
		return this.curNode !is null;
	}
}

class Node(T) : ISRNode!(T) {
	Node!(T) next;
	T data;

	this(T data) {
		this.data = data;
	}

	T getData() {
		return this.data;
	}
}


class HashTable(T) : ISR!(T) {
	private Node!(T)[] table;
	private size_t function(T data) hashFunc;
	private size_t size;
	private bool duplication;

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
		} else static if(is(T : Object)) {
			return cast(size_t)data.toHash();
		} else {
			assert(0);
		}
	}

	T[] values() {
		T[] ret = new T[this.size];
		size_t ptr = 0;
		foreach(it; this.table) {
			while(it !is null) {
				ret[ptr++] = it.data;
				it = it.next;
			}
		}
		return ret;
	}

	Iterator!(T) begin() {
		size_t idx = 0;
		while(this.table[idx] is null && idx < this.table.length)
			idx++;
		return new Iterator!(T)(this, idx, this.table[idx]);
	}

	Iterator!(T) end() {
		size_t idx = this.table.length-1;
		while(this.table[idx] is null && idx >= 0)
			idx--;
		return new Iterator!(T)(this, idx, this.table[idx]);
	}

	this(bool duplication = true, 
			size_t function(T toHash) hashFunc = &defaultHashFunc) {
		this.duplication = duplication;
		this.hashFunc = hashFunc;
		this.table = new Node!(T)[16];
	}

	Node!(T) search(const T data) {
		size_t hash = this.hashFunc(data) % this.table.length;
		Node!(T) it = this.table[hash];
		while(it !is null) {
			if(it.data == data)
				break;
			it = it.next;
		}
		return it;
	}

	bool remove(T data) {
		size_t hash = this.hashFunc(data) % this.table.length;
		Node!(T) it = this.table[hash];
		if(it.data == data) {
			this.table[hash] = it.next;
			this.size--;
			return true;
		}
		while(it.next !is null) {
			if(it.next.data == data) {
				it.next = it.next.next;
				this.size--;
				return true;
			}
			it = it.next;
		}
		return false;
	}

	private void grow() {
		Node!(T)[] nTable = new Node!(T)[this.table.length*2];
		foreach(it; this.table) {
			if(it !is null) {
				Node!(T) i = it;
				Node!(T) j = i.next;
				size_t hash;
				while(i !is null) {
					hash = this.hashFunc(i.data) % nTable.length;
					insert(nTable, hash, i);
					i = j;
					if(i !is null)
						j = i.next;	
				}
			}
		}
		this.table = nTable;
	}

	package Node!(T) getNode(size_t idx) {
		if(idx < this.table.length) {
			return this.table[idx];
		} else {
			return null;
		}
	}

	private static void insert(Node!(T)[] t, size_t hash, Node!(T) node) {
		Node!(T) old = t[hash];
		t[hash] = node;
		t[hash].next = old;
	}

	bool insert(T data) {
		if(!this.duplication) {
			Node!(T) check = this.search(data);
			if(check !is null) {
				return false;
			}
		}
		size_t filllevel = cast(size_t)(this.table.length*0.7);
		if(this.size + 1 > filllevel) {
			this.grow();
		}
		size_t hash = this.hashFunc(data) % table.length;
		insert(this.table, hash, new Node!(T)(data));
		this.size++;
		
		return true;
	}

	public size_t getSize() const {
		return this.size;
	}
}

unittest {
	int[][] lot = [[2811, 1089, 3909, 3593, 1980, 2863, 676, 258, 2499, 3147,
	3321, 3532, 3009, 1526, 2474, 1609, 518, 1451, 796, 2147, 56, 414, 3740,
	2476, 3297, 487, 1397, 973, 2287, 2516, 543, 3784, 916, 2642, 312, 1130,
	756, 210, 170, 3510, 987], [0,1,2,3,4,5,6,7,8,9,10],
	[10,9,8,7,6,5,4,3,2,1,0],[10,9,8,7,6,5,4,3,2,1,0,11],
	[0,1,2,3,4,5,6,7,8,9,10,-1],[11,1,2,3,4,5,6,7,8,0]];
	foreach(it; lot) {
		HashTable!(int) ht = new HashTable!(int)(false);
		assert(ht.getSize() == 0);
		foreach(idx,jt; it) {
			assert(ht.insert(jt));
			assert(ht.getSize() == idx+1);
			foreach(kt; it[0..idx])
				assert(ht.search(kt));
			foreach(kt; it[idx+1..$])
				assert(!ht.search(kt));
		}
		foreach(idx,jt; it) {
			assert(ht.remove(jt));
			assert(ht.getSize() + idx + 1 == it.length);
			foreach(kt; it[0..idx])
				assert(!ht.search(kt));
			foreach(kt; it[idx+1..$])
				assert(ht.search(kt));
		}
		assert(ht.getSize() == 0, conv!(size_t,string)(ht.getSize()));
	}
	string[] words = [
"abbreviation","abbreviations","abettor","abettors","abilities","ability"
"abrasion","abrasions","abrasive","abrasives","absence","absences","abuse"
"abuser","abusers","abuses","acceleration","accelerations","acceptance"
"acceptances","acceptor","acceptors","access","accesses","accessories"
"accessory","accident","accidents","accommodation","accomplishment"
"accomplishments","accord","accordance","account","accountabilities"
"accountability","accounts","accrual","accruals","accruement","accumulation"
"accumulations","accuracy","accusation","accusations","acid","acids"
"acquisition","acquisitions","acquittal","acquittals","acre","acres","acronym"
"acronyms","act","action","actions","activities","activity","acts","adaption"
"adaptions","addition","additions","additive","additives","address","addressee"
"addressees","addresses","adherence","adherences","adhesive","adhesives"
"adjective","adjectives","adjustment","adjustments","administration"
"administrations","administrator","administrators","admiral","admirals"
"admiralties","admiralty","admission","admissions","advance","advancement"
"advancements","advances","advantage","advantages","adverb","adverbs"
"advertisement","advertisements","adviser","advisers","affair","affairs"
"affiant","affiants","afternoon","afternoons","age","agent","agents","ages"
"aggravation","aggravations","agreement","agreements","aid","aids","aim","aims"
"air","aircraft","airfield","airfields","airplane","airplanes","airport"
"airports","airs","airship","airships","airspeed","airspeeds","alarm","alarms"
"alcohol","alcoholic","alcoholics","alcoholism","alcohols","alert","alerts"
"algebra","algorithm","algorithms","alias","aliases","alibi","alibis"
"alignment","alignments","alkalinity","allegation","allegations","alley"
"alleys","allies","allocation","allocations","allotment","allotments"
"allowance","allowances","alloy","alloys","ally","alphabet","alphabets"
"alternate","alternates","alternation","alternations","alternative"
"alternatives","altimeter","altimeters","altitude","altitudes","aluminum"
"aluminums","ambiguity","americans","ammonia","ammunition","amount","amounts"
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
"armfuls","armies","armor","armories","armors","armory","arms","army"
"arraignment","arraignments","arrangement","arrangements","array","arrays"
"arrest","arrests","arrival","arrivals","arrow","arrows","art","article"
"articles","artilleries","artillery","arts","assault","assaults","assemblies"
"assembly","assignment","assignments","assistance","assistant","assistants"
"associate","associates","asterisk","asterisks","athwartship","atmosphere"
"atmospheres","atom","atoms","attachment","attachments","attack","attacker"
"attackers","attempt","attempts","attention","attesting","attitude","attitudes"
"attorney","attorneys","attraction","attractions","attribute","attributes"
"audit","auditor","auditors","audits","augmentation","augmentations","august"
"authorities","authority","authorization","authorizations","auto","automation"
"automobile","automobiles","autos","auxiliaries","average","averages"
"aviation","award","awards","ax","axes","axis","azimuth","azimuths","babies"
"baby","back","background","backgrounds","backs","backup","backups","badge"
"badges","bag","bags","bail","bailing","bails","balance","balances","ball"
"ballast","balloon","balloons","balls","band","bandage","bandages","bands"
"bang","bangs","bank","banks","bar","barge","barges","barometer","barometers"
"barrel","barrels","barrier","barriers","bars","base","baseline","basement"
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
"blocks","blood","blot","blots","blow","blower","blowers","blows","blueprint"
"blueprints","blur","blurs","board","boards","boat","boats","boatswain"
"boatswains","bodies","body","boil","boiler","boilers","boils","bolt","bolts"
"bomb","bombs","bond","bonds","bone","bones","book","books","boom","booms"
"boost","boosts","boot","boots","bore","boresight","boresights","bottle"
"bottles","bottom","bottoms","bow","bowl","bowls","bows","box","boxcar"
"boxcars","boxes","boy","boys","brace","braces","bracket","brackets","braid"
"braids","brain","brains","brake","brakes","branch","branches","brass","breach"
"breaches","bread","breads","break","breakdown","breakdowns","breaks","breast"
"breasts","breath","breaths","breeze","breezes","brick","bricks","bridge"
"bridges","briefings","brightness","bristle","bristles","broadcasts","bronze"
"brook","brooks","broom","brooms","brother","brothers","brush","brushes"
"bubble","bubbles","bucket","buckets","buckle","buckles","bud","budget"
"budgets","buds","buffer","buffers","builder","builders","building","buildings"
"bulb","bulbs","bulk","bulkhead","bulkheads","bullet","bullets","bump","bumps"
"bunch","bunches","bundle","bundles","bunk","bunks","buoy","buoys","bureau"
"bureaus","burglaries","burglary","burn","burns","bus","buses","bush","bushel"
"bushels","bushes","bushing","bushings","business","businesses","butt","butter"
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
"carelessness","cares","cargo","cargoes","carload","carloads","carpet"
"carpets","carriage","carriages","carrier","carriers","cars","cart","cartridge"
"cartridges","carts","case","cases","cash","cashier","cashiers","casts"
"casualties","casualty","catalog","catalogs","catch","catcher","catchers"
"catches","categories","category","cathode","cathodes","cause","causes"
"caution","cautions","cave","caves","cavities","cavity","ceiling","ceilings"
"cell","cellar","cellars","cells","cement","cements","cent","center"
"centerline","centerlines","centers","centimeter","centimeters","cents"
"ceramics","ceremonies","ceremony","certificate","certificates","certification"
"certifications","chain","chains","chair","chairman","chairmen","chairperson"
"chairpersons","chairs","chairwoman","chairwomen","chalk","chalks","challenge"
"challenges","chamber","chambers","chance","chances","change","changes"
"channel","channels","chaplain","chaplains","chapter","chapters","character"
"characteristic","characteristics","characters","charge","charges","chart"
"charts","chase","chases","chattel","chattels","chatter","cheat","cheater"
"cheaters","cheats","check","checker","checkers","checkout","checkouts"
"checkpoint","checkpoints","checks","cheek","cheeks","cheese","cheeses"
"chemical","chemicals","chemistry","chest","chests","chief","chiefs","child"
"children","chill","chills","chimney","chimneys","chin","chins","chip","chips"
"chit","chits","chock","chocks","choice","choices","choke","chokes","church"
"churches","churn","churns","circle","circles","circuit","circuitries"
"circuitry","circuits","circulation","circulations","circumference"
"circumferences","circumstance","circumstances","cities","citizen","citizens"
"city","civilian","civilians","claim","claims","clamp","clamps","clang"
"clangs","clap","claps","class","classes","classification","classifications"
"classroom","classrooms","claw","claws","clay","cleanliness","cleanser"
"cleansers","clearance","clearances","cleat","cleats","clericals","clerk"
"clerks","click","clicks","cliff","cliffs","clip","clips","clock","clocks"
"closure","closures","cloth","clothes","clothing","cloths","cloud","cloudiness"
"clouds","club","clubs","clump","clumps","coal","coals","coast","coasts","coat"
"coating","coats","cockpit","cockpits","code","coder","coders","codes","coil"
"coils","coin","coins","colds","collar","collars","collection","collections"
"collector","collectors","college","colleges","collision","collisions","colon"
"colons","color","colors","column","columns","comb","combat","combatant"
"combatants","combination","combinations","combs","combustion","comfort"
"comforts","comma","command","commander","commanders","commands","commas"
"commendation","commendations","comment","comments","commission","commissions"
"commitment","commitments","committee","committees","communication"
"communications","communities","community","companies","company","comparison"
"comparisons","compartment","compartments","compass","compasses","compensation"
"compensations","competition","competitions","compiler","compilers","complaint"
"complaints","complement","complements","completion","completions","complexes"
"compliance","compliances","component","components","composites","composition"
"compositions","compounds","compress","compresses","compression","compressions"
"compressor","compressors","compromise","compromises","computation"
"computations","computer","computers","concentration","concentrations"
"concept","concepts","concern","concerns","concurrence","condensation"
"condensations","condenser","condensers","condition","conditions","conduct"
"conductor","conductors","conducts","cone","cones","conference","conferences"
"confession","confessions","confidence","confidences","configuration"
"configurations","confinement","confinements","conflict","conflicts"
"confusion","confusions","congress","conjecture","conjectures","conjunction"
"conjunctions","conn","connection","connections","consequence","consequences"
"consideration","console","consoles","consolidation","conspiracies"
"conspiracy","constitution","construction","contact","contacts","container"
"containers","contamination","contempt","content","contention","contents"
"continuity","contraband","contract","contracts","contrast","contrasts"
"contribution","contributions","control","controls","convenience"
"conveniences","convention","conventions","conversion","conversions"
"convulsion","convulsions","coordinate","coordinates","coordination"
"coordinations","coordinator","coordinators","copies","copper","copy","cord"
"cords","core","cores","cork","corks","corner","corners","corps","correction"
"corrections","correlation","correlations","correspondence","corrosion","cosal"
"cosals","costs","cot","cots","cotton","cottons","cough","coughs","counsel"
"counselor","counselors","counsels","count","counter","countermeasure"
"countermeasures","counters","countries","country","counts","couple","couples"
"couplings","course","courses","court","courtesies","courtesy","courts","cover"
"coxswain","coxswains","crack","cracks","cradle","cradles","craft","crafts"
"cramp","cramps","crank","cranks","crash","crashes","crawl","credibility"
"credit","credits","creek","creeks","crew","crewmember","crewmembers","crews"
"cries","crime","crimes","crop","crops","cross","crosses","crowd","crowds"
"crown","crowns","cruise","cruiser","cruisers","cruises","crust","crusts","cry"
"crystal","crystals","cube","cubes","cuff","cuffs","cup","cupful","cupfuls"
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
"deputies","deputy","dereliction","description","descriptions","desert"
"deserter","deserters","desertion","desertions","deserts","designation"
"designations","designator","designators","desire","desires","desk","desks"
"destination","destinations","destroyer","destroyers","destruction"
"detachment","detachments","detail","details","detection","detent","detention"
"detentions","detents","detonation","detonations","development","developments"
"deviation","deviations","device","devices","dew","diagnoses","diagnosis"
"diagnostics","diagonals","diagram","diagrams","dial","dials","diameter"
"diameters","diamond","diamonds","diaphragm","diaphragms","diaries","diary"
"dictionaries","dictionary","diesel","diesels","difference","differences"
"difficulties","difficulty","digestion","digit","digits","dimension"
"dimensions","diode","diodes","dioxide","dioxides","dip","dips","direction"
"directions","directive","directives","directories","directory","dirt"
"disabilities","disability","disadvantage","disadvantages","disassemblies"
"disassembly","disaster","disasters","discard","discards","discharge"
"discharges","discipline","disciplines","discontinuance","discontinuances"
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
"effort","efforts","egg","eggs","eighths","eighties","eights","ejection"
"elapse","elapses","elbow","elbows","election","elections","electrician"
"electricians","electricity","electrode","electrodes","electrolyte"
"electrolytes","electron","electronics","electrons","element","elements"
"elevation","eleven","eligibility","elimination","eliminator","eliminators"
"embosses","emergencies","emergency","emitter","emitters","employee"
"employees","enclosure","enclosures","encounter","encounters","end","endeavor"
"endeavors","endings","ends","enemies","enemy","energies","energizer"
"energizers","energy","engine","engineer","engineers","engines","enlistment"
"enlistments","ensign","ensigns","entrance","entrances","entrapment"
"entrapments","entries","entry","envelope","envelopes","environment"
"environments","equation","equations","equator","equipment","equivalent"
"equivalents","eraser","erasers","error","errors","escape","escapes","escort"
"escorts","establishment","establishments","evacuation","evacuations"
"evaluation","evaluations","evaporation","eve","evening","evenings","event"
"events","eves","evidence","examination","examinations","example","examples"
"exception","exceptions","excess","excesses","exchange","exchanger"
"exchangers","exchanges","excuse","excuses","execution","executions"
"executive","executives","exercise","exercises","exhaust","exhausts","exhibit"
"exhibits","existence","exit","exits","expansion","expansions","expenditure"
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
"fear","fears","feather","feathers","feature","features","february","fee"
"feed","feedback","feeder","feeders","feeds","feelings","fees","feet","fellow"
"fellows","fence","fences","fetch","fetches","fiber","fibers","fiction","field"
"fields","fifteen","fifths","fifties","fifty","fight","fighter","fighters"
"fighting","fights","figure","figures","file","files","filler","fillers","film"
"films","filter","filters","fines","finger","fingers","finish","finishes"
"fire","firearm","firearms","fireball","fireballs","firefighting","fireplug"
"fireplugs","firer","firers","fires","firings","firmware","fish","fishes"
"fist","fists","fits","fittings","fives","fixture","flag","flags","flake"
"flakes","flame","flames","flange","flanges","flap","flaps","flare","flares"
"flash","flashes","flashlight","flashlights","fleet","fleets","flesh","flicker"
"flickers","flight","flights","float","floats","flood","floods","floor"
"floors","flow","flowchart","flower","flowers","fluid","fluids","flush","foam"
"focus","focuses","fog","fogs","fold","folder","folders","folds","food","foods"
"foot","footing","footings","force","forces","forearm","forearms","forecastle"
"forecastles","forecasts","foreground","forehead","foreheads","forest"
"forests","fork","forks","form","format","formation","formations","formats"
"forms","formula","formulas","fort","forties","forts","forty","fountain"
"fountains","fours","fourths","fraction","fractions","fracture","fractures"
"frame","frames","freedom","freeze","freezes","freight","freights"
"frequencies","frequency","freshwater","friction","friday","fridays","friend"
"friends","frigate","frigates","front","fronts","frost","frosts","fruit"
"fruits","fuel","fuels","fumes","function","functions","fund","funding","funds"
"fur","furnace","furnaces","furs","fuse","fuses","future","futures","gage"
"gages","galley","galleys","gallon","gallons","gallows","game","games","gang"
"gangs","gangway","gangways","gap","gaps","garage","garages","garden","gardens"
"gas","gases","gasket","gaskets","gasoline","gasolines","gate","gates","gear"
"gears","generals","generation","generations","generator","generators"
"geography","giant","giants","girl","girls","glance","glances","gland","glands"
"glass","glasses","glaze","glazes","gleam","gleams","glide","glides"
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
"headsets","health","heap","heaps","heart","hearts","heat","heater","heaters"
"heats","heel","heels","height","heights","helicopter","helicopters","hello"
"helm","helmet","helmets","helms","helmsman","helmsmen","help","hem","hems"
"henry","henrys","here","hertz","hickories","hickory","hierarchies","hierarchy"
"highline","highlines","highway","highways","hill","hills","hillside"
"hillsides","hilltop","hilltops","hinge","hinges","hint","hints","hip","hips"
"hiss","hisses","histories","history","hitch","hitches","hits","hoist","hoists"
"hold","holddown","holddowns","holder","holders","holds","hole","holes","home"
"homes","honk","honks","honor","honors","hood","hoods","hoof","hoofs","hook"
"hooks","hoop","hoops","hope","hopes","horizon","horizons","horn","horns"
"horsepower","hose","hoses","hospital","hospitals","hotel","hotels","hour"
"hours","house","housefall","housefalls","houses","housing","housings","howl"
"howls","hub","hubs","hug","hugs","hull","hulls","hum","human","humans"
"humidity","humor","hump","humps","hums","hundred","hundreds","hunk","hunks"
"hunt","hunts","hush","hushes","hut","huts","hydraulics","hydrometer"
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
"instance","instances","instruction","instructions","instructor","instructors"
"instrument","instrumentation","instruments","insulation","insurance","intake"
"intakes","integer","integers","integrity","intelligence","intelligences"
"intensities","intensity","intent","intents","interaction","interactions"
"interchange","interchanges","intercom","intercoms","interest","interests"
"interface","interfaces","interference","interior","interiors","interpreter"
"interpreters","interrelation","interruption","interruptions","interval"
"intervals","interview","interviewer","interviewers","interviews"
"introduction","introductions","invention","inventions","inventories"
"inventory","investigation","investigations","investigator","investigators"
"investment","investments","invoice","invoices","iron","irons","island"
"islands","isolation","issue","issues","item","items","itineraries","itinerary"
"ivory","jack","jackbox","jackboxes","jacket","jackets","jacks","jail","jails"
"jam","jams","january","jar","jars","jaw","jaws","jellies","jelly","jeopardies"
"jeopardy","jets","jewel","jewels","jig","jigs","job","jobs","joint","joints"
"journal","journals","journey","journeys","judge","judges","judgment","jug"
"jugs","july","jump","jumper","jumpers","jumps","junction","junctions","june"
"junk","juries","jurisdiction","jurisdictions","jury","justice","keel","keels"
"kettle","kettles","key","keyboard","keyboards","keys","keyword","keywords"
"kick","kicks","kill","kills","kilogram","kilograms","kiloliter","kiloliters"
"kilometer","kilometers","kinds","kiss","kisses","kit","kite","kites","kits"
"knee","knees","knife","knives","knob","knobs","knock","knocks","knot","knots"
"knowledge","label","labels","labor","laboratories","laboratory","labors"
"lace","laces","lack","ladder","ladders","lake","lakes","lamp","lamps","land"
"landings","lands","lane","lanes","language","languages","lantern","lanterns"
"lap","laps","lapse","lapses","lard","laser","lasers","lash","lashes","latch"
"latches","latitude","latitudes","laugh","laughs","launch","launcher"
"launchers","launches","laundries","laundry","law","laws","layer","layers"
"lead","leader","leaders","leadership","leads","leaf","leak","leakage"
"leakages","leaks","leap","leaper","leapers","leaps","learning","leather"
"leathers","leave","leaves","leaving","lee","lees","leg","legend","legends"
"legging","leggings","legislation","legs","lender","lenders","length","lengths"
"lens","lenses","lesson","lessons","letter","letterhead","letterheads"
"lettering","letters","levels","lever","levers","liberties","liberty"
"libraries","library","license","licenses","lick","licks","lid","lids"
"lieutenant","lieutenants","life","lifeboat","lifeboats","lifetime","lifetimes"
"lift","lifts","light","lighter","lighters","lightning","lights","limb","limbs"
"lime","limes","limit","limitation","limitations","limits","limp","limps"
"line","linen","linens","lines","lining","link","linkage","linkages","links"
"lint","lints","lip","lips","liquor","liquors","list","listing","listings"
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
"markets","marks","mask","masks","mass","massed","masses","mast","master"
"masters","masts","mat","match","matches","mate","material","materials","mates"
"math","mathematics","mats","matter","matters","mattress","mattresses"
"maximum","maximums","meal","meals","meanings","means","measure","measurement"
"measurements","measures","meat","meats","mechanic","mechanics","mechanism"
"mechanisms","medal","medals","medicine","medicines","medium","mediums","meet"
"meeting","meetings","meets","member","members","membrane","membranes"
"memorandum","memorandums","memories","memory","men","mention","mentions"
"menu","menus","merchandise","merchant","merchants","mercury","meridian"
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
"nail","nails","name","nameplate","nameplates","names","narcotics","nation"
"nations","nature","nausea","navies","navigation","navigations","navigator"
"navigators","navy","neck","necks","need","needle","needles","needs","neglect"
"negligence","nerve","nerves","nest","nests","net","nets","network","networks"
"neutron","neutrons","news","nickel","nickels","night","nights","nines"
"nineties","nod","nods","noise","noises","nomenclature","nomenclatures"
"nonavailabilities","noon","north","nose","noses","notation","note","notes"
"notice","notices","noun","nouns","november","nozzle","nozzles","null","nulls"
"number","numbers","numeral","numerals","nurse","nurses","nut","nuts","nylon"
"nylons","oak","oaks","oar","oars","object","objective","objectives","objects"
"obligation","obligations","observation","observations","observer","observers"
"occasion","occasions","occurrence","occurrences","ocean","oceans","october"
"octobers","odds","odor","odors","offender","offenders","offense","offenses"
"offer","offering","offers","office","officer","officers","offices","official"
"officials","offsets","ohm","ohms","oil","oils","okays","ones","openings"
"operabilities","operability","operand","operands","operation","operations"
"operator","operators","opinion","opinions","opportunities","opportunity"
"opposites","option","options","orange","oranges","order","orders","ordnance"
"ore","ores","organ","organization","organizations","organs","orifice"
"orifices","origin","originals","originator","originators","origins","ornament"
"ornaments","oscillation","oscillations","oscillator","oscillators","others"
"ounce","ounces","outboards","outfit","outfits","outing","outlet","outlets"
"outline","outlines","output","oven","ovens","overalls","overcoat","overcoats"
"overcurrent","overcurrents","overflow","overlay","overlays","overload"
"overloads","overtime","overvoltage","overvoltages","owner","owners","oxide"
"oxides","oxygen","oxygens","pace","paces","pacific","pack","package"
"packages","packs","pad","pads","page","pages","pail","pails","pain","paint"
"painter","painters","painting","paintings","paints","pair","pairs","pan"
"pane","panel","paneling","panels","panes","pans","paper","papers","parachute"
"parachutes","paragraph","paragraphs","parallels","parameter","parameters"
"parcel","parcels","parentheses","parenthesis","parities","parity","park"
"parks","part","participation","participations","particle","particles"
"parties","partition","partitions","partner","partners","parts","party"
"pascal","pass","passage","passages","passbook","passbooks","passenger"
"passengers","passes","passivation","passivations","password","passwords"
"paste","pastes","pat","patch","patches","path","paths","patient","patients"
"patrol","patrols","pats","patter","pattern","patterns","pavement","paw","paws"
"pay","paygrade","paygrades","payment","payments","payroll","pea","peace"
"peacetime","peak","peaks","pear","pears","peas","peck","pecks","pedal"
"pedals","peg","pegs","pen","pencil","pencils","pennant","pennants","pens"
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
"ponds","pool","pools","pop","pops","population","port","porter","porters"
"portion","portions","ports","position","positions","possession","possessions"
"possibilities","possibility","post","posts","pot","potato","potatos","pots"
"pound","pounds","powder","powders","power","powers","practice","practices"
"precaution","precautions","precedence","precision","preference","preferences"
"prefix","prefixes","preliminaries","preparation","preparations","preposition"
"prepositions","prerequisite","presence","presences","present","presentation"
"presentations","presents","preservation","preserver","preservers","president"
"presidents","press","presses","pressure","pressures","presumption"
"presumptions","prevention","preventions","price","prices","prime","primes"
"primitives","principal","principals","principle","principles","print"
"printout","printouts","prints","priorities","priority","prism","prisms"
"prison","prisoner","prisoners","prisons","privates","privilege","privileges"
"probabilities","probability","probe","probes","problem","problems","procedure"
"procedures","process","processes","processor","processors","procurement"
"procurements","produce","product","products","profession","professionalism"
"professionals","professions","proficiencies","proficiency","profile"
"profiles","profit","profits","program","programmer","programmers","programs"
"progress","project","projectile","projectiles","projects","promotion"
"promotions","prompts","pronoun","pronouns","proof","proofs","prop","propeller"
"propellers","properties","property","proportion","proportions","propose"
"proposes","props","propulsion","propulsions","protection","protest","protests"
"provision","provisions","public","publication","publications","puddle"
"puddles","puff","puffs","pull","pulls","pulse","pulses","pump","pumps","punch"
"punches","puncture","punctures","punishment","punishments","pupil","pupils"
"purchase","purchaser","purchasers","purchases","purge","purges","purpose"
"purposes","push","pushdown","pushdowns","pushes","pushup","pushups","pyramid"
"pyramids","qualification","qualifications","qualifier","qualifiers"
"qualities","quality","quantities","quantity","quart","quarter","quarterdeck"
"quarterdecks","quartermaster","quartermasters","quarters","quarts","question"
"questions","quiet","quiets","quota","quotas","race","races","rack","racks"
"radar","radars","radian","radians","radiation","radiator","radiators","radio"
"radios","radius","radiuses","rag","rags","rail","railroad","railroads","rails"
"railway","railways","rain","rainbow","rainbows","raincoat","raincoats","rains"
"raise","raises","rake","rakes","ram","ramp","ramps","rams","range","ranges"
"rank","ranks","rap","raps","rate","rates","ratings","ratio","ration","rations"
"ratios","rattle","rattles","ray","rays","reach","reaches","reactance"
"reaction","reactions","reactor","reactors","reader","readers","readiness"
"reading","readings","realignment","realignments","realinement","realinements"
"ream","reams","rear","reason","reasons","rebound","rebounds","recapitulation"
"recapitulations","receipt","receipts","receiver","receivers","receptacle"
"receptacles","recess","recesses","recipient","recipients","recognition"
"recognitions","recombination","recombinations","recommendation"
"recommendations","reconfiguration","reconfigurations","record","recording"
"recordkeeping","records","recoveries","recovery","recruit","recruiter"
"recruiters","recruits","reduction","reductions","reel","reels","reenlistment"
"reenlistments","reference","references","refrigerator","refrigerators"
"refund","refunds","refurbishment","refuse","region","regions","register"
"registers","regret","regrets","regulation","regulations","regulator"
"regulators","rehabilitation","reinforcement","reinforcements","rejection"
"rejections","relation","relations","relationship","relationships","relay"
"relays","release","releases","reliabilities","reliability","relief","religion"
"religions","relocation","relocations","reluctance","remainder","remainders"
"remains","remedies","remedy","removal","removals","repair","repairs"
"replacement","replacements","replenishment","replenishments","report"
"reports","representative","representatives","reproduction","reproductions"
"request","requests","requirement","requirements","requisition","requisitions"
"rescue","rescuer","rescuers","rescues","research","researcher","researchers"
"reserve","reserves","reservist","reservists","reservoir","reservoirs"
"resident","residents","residue","residues","resistance","resistances"
"resistor","resistors","resolution","resource","resources","respect","respects"
"respiration","respirations","response","responses","responsibilities"
"responsibility","rest","restaurant","restaurants","restraint","restraints"
"restriction","restrictions","result","results","retailer","retailers"
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
"scale","scales","scene","scenes","schedule","scheduler","schedulers"
"schedules","schematics","school","schoolhouse","schoolhouses","schoolroom"
"schoolrooms","schools","science","sciences","scissors","scope","scopes"
"score","scores","scrap","scraps","scratch","scratches","scratchpad"
"scratchpads","scream","screams","screen","screens","screw","screwdriver"
"screwdrivers","screws","sea","seal","seals","seam","seaman","seamanship"
"seamen","seams","search","searches","searchlight","searchlights","seas"
"season","seasoning","seasons","seat","seats","seawater","second","seconds"
"secret","secretaries","secretary","secrets","section","sections","sector"
"sectors","securities","security","sediment","sediments","seed","seeds"
"seesaw","seesaws","segment","segments","selection","selections","selector"
"selectors","self","selves","semaphore","semaphores","semicolon","semicolons"
"semiconductor","semiconductors","sense","senses","sentence","sentences"
"sentries","sentry","separation","separations","september","sequence"
"sequences","serial","serials","series","servant","servants","service"
"services","servo","servos","session","sessions","sets","setting","settings"
"settlement","settlements","setup","setups","sevens","sevenths","seventies"
"sewage","sewer","sewers","sex","sexes","shade","shades","shadow","shadows"
"shaft","shafts","shame","shape","shapes","share","shares","sharpener"
"sharpeners","shave","shaves","shears","sheds","sheet","sheeting","sheets"
"shelf","shell","shells","shelter","shelters","shelves","shield","shields"
"shift","shifts","ship","shipmate","shipmates","shipment","shipments"
"shipping","ships","shirt","shirts","shock","shocks","shoe","shoes","shop"
"shops","shore","shores","shortage","shortages","shotline","shotlines","shots"
"shoulder","shoulders","shout","shouts","shovel","shovels","show","shower"
"showers","shows","side","sides","sidewalk","sidewalks","sight","sights","sign"
"signal","signaler","signalers","signalman","signalmen","signals","signature"
"signatures","significance","signs","silence","silences","silicon","silk"
"silks","sill","sills","silver","similarities","similarity","sink","sinks"
"sip","sips","sir","siren","sirens","sirs","sister","sisters","site","sites"
"situation","situations","sixes","sixths","sixties","size","sizes","skew"
"skies","skill","skills","skin","skins","skip","skips","skirt","skirts","sky"
"slap","slaps","slash","slashes","slate","slates","slave","slaves","sled"
"sleds","sleep","sleeve","sleeves","slice","slices","slide","slides","slinging"
"slings","slits","slope","slopes","slot","slots","smash","smashes","smell"
"smells","smile","smiles","smoke","smokes","snap","snaps","sneeze","sneezes"
"snow","snows","soap","soaps","societies","society","sock","socket","sockets"
"socks","sod","software","soil","soils","solder","solders","soldier","soldiers"
"sole","solenoid","solenoids","soles","solids","solution","solutions","solvent"
"solvents","son","sonar","sonars","song","songs","sons","sort","sorts","sound"
"sounds","soup","soups","source","sources","south","space","spacer","spacers"
"spaces","spade","spades","span","spans","spar","spare","spares","spark"
"sparks","spars","speaker","speakers","spear","spears","specialist"
"specialists","specialization","specializations","specialties","specialty"
"specification","specifications","speech","speeches","speed","speeder"
"speeders","speeds","spike","spikes","spill","spills","spindle","spindles"
"spins","spiral","spirals","splash","splashes","splice","splicer","splicers"
"splices","splint","splints","splitter","splitters","spoke","spokes","sponge"
"sponges","sponsor","sponsors","spool","spools","spoon","spoons","sport"
"sports","spot","spots","spray","sprayer","sprayers","sprays","spring"
"springs","squadron","squadrons","square","squares","squeak","squeaks"
"stability","stabilization","stack","stacks","staff","staffs","stage","stages"
"stair","stairs","stake","stakes","stall","stalls","stamp","stamps","stand"
"standard","standardization","standardizations","standards","standing","stands"
"staple","stapler","staplers","staples","star","starboard","stare","stares"
"stars","start","starts","state","statement","statements","states","station"
"stationery","stations","stator","stators","status","steam","steamer"
"steamers","steams","steel","steels","steeple","steeples","stem","stems"
"stencil","stencils","step","steps","sterilizer","sterilizers","stern","stick"
"sticks","sting","stings","stitch","stitches","stock","stocking","stocks"
"stomach","stomachs","stone","stones","stool","stools","stop","stopper"
"stoppered","stoppering","stoppers","storage","store","stores","stories"
"storm","storms","story","stove","stoves","stowage","straightener"
"straighteners","strain","strains","strand","strands","strap","straps","straw"
"straws","streak","streaks","stream","streams","street","streets","strength"
"strengths","stress","stresses","stretch","stretcher","stretchers","stretches"
"strike","striker","strikers","strikes","string","strings","strip","stripe"
"stripes","strips","strobe","strobes","stroke","strokes","structure"
"structures","strut","struts","stub","stubs","student","students","studies"
"study","stuff","stuffing","stump","stumps","subdivision","subdivisions"
"subfunction","subfunctions","subject","subjects","submarine","submarined"
"submarines","submarining","submission","submissions","subordinate"
"subordinates","subprogram","subprograms","subroutine","subroutines"
"substance","substances","substitute","substitutes","subsystem","subsystems"
"subtask","subtasks","subtotal","subtotals","success","successes","suction"
"sugar","suggestion","suggestions","suit","suits","sum","summaries","summary"
"summer","summers","sums","sun","sunday","sundays","sunlight","sunrise","suns"
"sunset","sunshine","superintendent","superlatives","supermarket"
"supermarkets","superstructure","superstructures","supervision","supervisor"
"supervisors","supplies","supply","suppression","suppressions","surface"
"surfaces","surge","surges","surplus","surpluses","surprise","surprises"
"surrender","surrenders","surveillance","survey","surveyor","surveyors"
"surveys","survival","survivals","suspect","suspects","swab","swabs","swallow"
"swallows","swamp","swamps","swap","swaps","sweep","sweeper","sweepers"
"sweeps","swell","swells","swim","swimmer","swimmers","swims","swing","swings"
"switch","switches","swivel","swivels","sword","swords","symbol","symbols"
"symptom","symptoms","syntax","synthetics","system","systems","tab","table"
"tables","tablespoon","tablespoons","tablet","tablets","tabs","tabulation"
"tabulations","tachometer","tachometers","tack","tackle","tackles","tacks"
"tactic","tactics","tag","tags","tail","tailor","tailors","tails","takeoff"
"takeoffs","talk","talker","talkers","talks","tan","tank","tanks","tap","tape"
"taper","tapers","tapes","taps","tar","target","targets","tars","task","tasks"
"taste","tastes","tax","taxes","taxi","taxis","teaching","teachings","team"
"teams","tear","tears","teaspoon","teaspoons","technician","technicians"
"technique","techniques","technology","teeth","telecommunication"
"telecommunications","telephone","telephones","television","televisions"
"teller","tellers","temper","temperature","temperatures","tempers","tendencies"
"tendency","tender","tenders","tens","tension","tensions","tent","tenth"
"tenths","tents","term","terminals","termination","terminations","terminator"
"terminators","terminologies","terminology","terms","terrain","terrains","test"
"tests","text","texts","thanks","theories","theory","thermals","thermocouple"
"thermocouples","thermometer","thermometers","thickness","thicknesses"
"thimble","thimbles","thin","thing","things","thins","thirds","thirteen"
"thirteens","thirties","thirty","thoughts","thousand","thousands","thread"
"threader","threaders","threads","threat","threats","threes","threshold"
"thresholds","throat","throats","throttle","throttles","thumb","thumbs"
"thunder","thursday","thursdays","thyristor","thyristors","tick","ticket"
"tickets","ticks","tide","tides","tie","till","tilling","tills","time","timer"
"timers","times","tin","tip","tips","tire","tires","tissue","tissues","title"
"titles","today","toe","toes","tolerance","tolerances","tomorrow","tomorrows"
"ton","tone","tones","tongue","tongues","tons","tool","toolbox","toolboxes"
"tools","tooth","toothpick","toothpicks","top","topic","topping","tops"
"topside","torpedo","torpedoes","torque","torques","toss","tosses","total"
"totals","touch","touches","tour","tourniquet","tourniquets","tours","towel"
"towels","tower","towers","town","towns","trace","traces","track","tracker"
"trackers","tracks","tractor","tractors","trade","trades","traffic","trail"
"trailer","trailers","trails","train","trainer","trainers","training","trains"
"transaction","transactions","transfer","transfers","transformer"
"transformers","transistor","transistors","transit","transiting","transits"
"translator","translators","transmission","transmissions","transmittal"
"transmittals","transmitter","transmitters","transport","transportation","trap"
"traps","trash","travel","travels","tray","trays","treatment","treatments"
"tree","trees","trial","trials","triangle","triangles","trick","tricks","tries"
"trigger","triggers","trim","trims","trip","trips","troop","troops","trouble"
"troubles","troubleshooter","troubleshooters","trousers","truck","trucks"
"trunk","trunks","trust","trusts","truth","truths","try","tub","tube","tubes"
"tubing","tubs","tuesday","tuesdays","tug","tugs","tuition","tumble","tumbles"
"tune","tunes","tunnel","tunnels","turbine","turbines","turbulence","turn"
"turnaround","turnarounds","turns","turpitude","twenties","twig","twigs","twin"
"twine","twins","twirl","twirls","twist","twists","twos","type","types"
"typewriter","typewriters","typist","typists","umbrella","umbrellas"
"uncertainties","uncertainty","uniform","uniforms","union","unions","unit"
"units","universe","update","updates","upside","usage","usages","use","user"
"users","uses","utilities","utility","utilization","utilizations","vacuum"
"vacuums","validation","validations","valley","valleys","value","values"
"valve","valves","vapor","vapors","varactor","varactors","variables"
"variation","variations","varieties","variety","vector","vectors","vehicle"
"vehicles","velocities","velocity","vendor","vendors","vent","ventilation"
"ventilations","ventilators","vents","verb","verbs","verification","verse"
"verses","version","versions","vessel","vessels","veteran","veterans"
"vibration","vibrations","vice","vices","vicinities","vicinity","victim"
"victims","video","videos","view","views","village","villages","vine","vines"
"violation","violations","violet","visibilities","visibility","vision"
"visions","visit","visitor","visitors","visits","voice","voices","voids","vol."
"volt","voltage","voltages","volts","volume","volumes","vomit","voucher"
"vouchers","wafer","wafers","wage","wages","wagon","wagons","waist","waists"
"wait","wake","walk","walks","wall","walls","want","war","wardroom","wardrooms"
"warehouse","warehouses","warfare","warning","warnings","warranties","warranty"
"wars","warship","warships","wartime","wash","washer","washers","washes"
"washing","washtub","washtubs","waste","wastes","watch","watches"
"watchstanding","water","waterline","waterlines","waters","watt","watts","wave"
"waves","wax","waxes","way","ways","wayside","weapon","weapons","wear"
"weather","weathers","weave","weaves","web","webs","wedding","weddings","weed"
"weeds","week","weeks","weight","weights","weld","welder","welders","weldings"
"welds","wells","west","wheel","wheels","whip","whips","whirl","whirls"
"whisper","whispers","whistle","whistles","wholesale","wholesales","width"
"widths","wiggle","wiggles","wills","win","winch","winches","wind","windings"
"windlass","windlasses","window","windows","winds","wine","wines","wing"
"wingnut","wingnuts","wings","wins","winter","winters","wire","wires","wish"
"wishes","withdrawal","withdrawals","witness","witnesses","woman","women"
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

	HashTable!(string) st = new HashTable!(string)(false);
	st.insert("foo");
	assert(st.search("foo"));
	foreach(idx,word;words) {
		st.insert(word);
		foreach(kt; words[0..idx])
			assert(st.search(kt));
		foreach(kt; words[idx+1..$])
			assert(!st.search(kt));
	}
	foreach(idx,jt; words) {
		assert(st.remove(jt));
		foreach(kt; words[0..idx])
			assert(!st.search(kt));
		foreach(kt; words[idx+1..$])
			assert(st.search(kt));
	}
	
}
