/datum/species/goblin
	name = "\improper Goblin"
	plural_form = "Goblins"
	id = SPECIES_GOBLIN
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	sexes = TRUE
	species_traits = list(
		MUTCOLORS,
	)
	inherent_traits = list(
		TRAIT_DWARF,
		TRAIT_QUICK_BUILD,
		TRAIT_EASILY_WOUNDED,
		TRAIT_NIGHT_VISION,
		// TRAIT_pickpocketing?
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID
	external_organs = list(
		/obj/item/organ/external/goblin_ears = "long",
		)
	meat = /obj/item/food/meat/steak
	disliked_food = VEGETABLES
	liked_food = GORE | MEAT | GROSS
	species_language_holder = /datum/language_holder/goblin
	maxhealthmod = 0.75
	stunmod = 1.2
	speedmod = -0.25
	payday_modifier = 1
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/goblin,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/goblin,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/goblin,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/goblin,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/goblin,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/goblin,
	)

/mob/living/carbon/human/species/goblin
    race = /datum/species/goblin

/datum/species/goblin/get_scream_sound(mob/living/carbon/human/human)
	if(human.gender == MALE)
		if(prob(1))
			return 'sound/voice/human/wilhelm_scream.ogg'
		return pick(
			'sound/voice/human/malescream_1.ogg',
			'sound/voice/human/malescream_2.ogg',
			'sound/voice/human/malescream_3.ogg',
			'sound/voice/human/malescream_4.ogg',
			'sound/voice/human/malescream_5.ogg',
			'sound/voice/human/malescream_6.ogg',
		)

	return pick(
		'sound/voice/human/femalescream_1.ogg',
		'sound/voice/human/femalescream_2.ogg',
		'sound/voice/human/femalescream_3.ogg',
		'sound/voice/human/femalescream_4.ogg',
		'sound/voice/human/femalescream_5.ogg',
	)

/datum/species/goblin/get_laugh_sound(mob/living/carbon/human/human)
	if(human.gender == MALE)
		return pick('sound/voice/human/manlaugh1.ogg', 'sound/voice/human/manlaugh2.ogg')
	else
		return 'sound/voice/human/womanlaugh.ogg'

/datum/language_holder/goblin
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/goblin = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/goblin = list(LANGUAGE_ATOM))

/datum/language/goblin
	name = "Gobbish"
	desc = "The language of goblins, pretty much 1 for 1 stolen from dwarves."
	space_chance = 100 // Each 'syllable' is its own word
	key = "G"

	syllables = list("kulet", "alak", "bidok", "nicol", "anam", "gatal", "mabdug", "zustash", "sedil", "ustos", "emr", "izeg", "beming", "gost", "ntak", "tosid", "feb", "berim", "ibruk", "ermis", "thoth", "thatthil", "gistang", "libash", "lakish", "asdos", "roder", "nel", "biban", "ugog", "ish", "robek", "olmul", "nokzam", "emuth", "fer", "uvel", "dolush", "ag^k", "ucat", "ng rak", "enir", "ugath", "lisig", "etg", "erong", "osed", "lanlar", "udir", "tarmid", "s krith", "nural", "bugsud", "okag", "nazush", "nashon", "ftrid", "en''r", "dstik", "kogan", "ingish", "dudgoth", "stalk*b", "themor", "murak", "altth", "osod", "thcekut", "cog", "selsten", "egdoth", "othsin", "idek", "st", "suthmam", "im", "okab", "onlnl", "gasol", "tegir", "nam...sh", "noval", "shalig", "shin", "lek", ",,kim", "kfkdal", "stum,,m", "alud", "olom", "%lot", "rozsed", "thos", "okon", "n<ng", "ostar", "rorul", "kovath", "tblel", "stal", "girtol", "kit<g", "lokast", "reked", "comnith", "sidos", "setnek", "ethbesh", "nug", "mokez", "c''s", "idos", "ogcek", "utheg", "tilgil", "ebsas", "lurak", "tobul", "ilush", "d%nush", "rimtar", "kun", ",s", "kiror", "nicat", "onshen", "r%rith", "mafol", "sid", "ntdn", "tilat", "cetat", "egot", "dib", "oril", "bukog", "atot", "imik", "sudir", "odshith", "rag", "dodck", "sinsot", "es", "dostob", "gast", ",lmeth", "romlam", "av,d", "dartl", "fn", "oddom", "z,gel", "og", "shatag", "om", "gis%k", "balad", "nekik", "dakas", "dolek", "sog", "rafar", "laltur", "cekeng", "dan", "ozsit", "dunan", "uling", "dcebesh", "berath", "zangin", "shadkik", "innok", "vukcas", "metul", "than", "gesul", "ustir", "torish", "memrut", "usal", "''m", "angrir", "cagith", "momuz", "zas", "deshlir", "astesh", "''fid", "mothram", "rit", "nolthag", "matul", "irtir", "unul", "urist", "umom", "d%m", "lodel", "kodor", "alod", "n''kor", "asen", "rtsh", "ursas", "vakun", "thol", "kizbiz", "uthg£r", "''nor", "gar", "terstum", "zagith", "noshtath", "ub", "k", "amur", "minran", "idar", "rodnul", "nuggad", "okbod", "tun", "mtmgoz", "fak", "ogon", "r%mrit", "stidest", "zag", "kosak", "sub", "shegum", "addor", "talin", "zin", "tmmeb", "sakub", "tig", "edir", "tath", "vesh", "etest", "atir", "lors<th", "rir", "em", "deb", "shuthraz", "Sshgor", "rkal", "ac''b", "okir", "arngish", "zilir", "im", "<ssun", "ilus", "gedor", "ramtak", "sombith", "ker", "lcenem", "umid", "seth", "sogdol", "shis", "er", "odroz", "urem", "nist", "cdad", "lithrush", "zotir", "zikel", "zikfth", "stagshil", "at''l", "ck", "ziril", "uthar", "tatlosh", "ngitkar", "dur", "keshan", "ned", "eststek", "ar", "%tul", "ltluth", "totmon", "bem", "fenglel", "gigin", "atham", "amug", "cabnul", "nog", "fotthor", "nltang", "dumed", "geshud", "inglaz", ",zneth", "tiklom", "<sir", "eshim", "lumash", "gishdist", "thcedas", "enog", "dozeb", "muz", "fst", "dushig", "bakat", "shistat", "goral", "kSbmak", "inod", "zisur", "list", "olon", "%rtong", "ngotol", "kolad", "egen", "r£bal", "gintar", "figul", "fikod", "bebmal", "bavast", "kttdir", ",thes", "igest", "reg", "ubur", "belbez", "n*m", "bunsoth", "limul", "kurig", "ugzol", "erib", "cegam", "mas", "zugob", "mashus", "isin", "mond-l", "siz", "sar...m", "dal", "omer", "sumun", "gommuk", "usith", "nerrid", "z god", "mithmis", "enol", "munSst", "bol", "-z", "btl", "sitheb", "duthnur", "ilbtd", "rurast", "suton", "nuglush", "ulthush", "razes", "bist''k", "Szum", "nil", "nil", "otad", "oddet", "thetdel", "golud", "-d", "kadol", "lur", "dumur", "akn-n", "otel", "ser", "zanor", "ur", "bokbon", "Sfim", "shash", "zon", "obur", "banik", "seb<r", "lirlez", "erlin", "inen", "tmft", "goster", "kunon", "tarag", "kiron", "lilum", "oggez", "bom", "stet r", "sikel", "unnos", "kisul", "ikus", "sheget", "famthut", "rorung", "idor", "enur", "kur", "fok sh", "vostaz", "ushil", "gumr", "ular", "enen", "goshcest", "fzkob", "meb", "likot", "st%tnin", "zarut", "nelzur", "datan", "tabmik", "rinal", "ebgok", "soshosh", "bukshon", "stcegil", "lumen", "maton", "abol", "cim", "egath", "imketh", "ilned", "zuden", "emtan", "ed%m", "noscem", "vag£sh", "alis", "etar", "inshot", "zasit", "arzes", ",bor", "oth", "vakist", "ner", "bul", "nddor", "onam", "ulol", "toral", "omoth", "erar", "govos", "orab", "dalkam", "subol", "gomath", "cerol", "mingkil", "detthost", "rerik", "lolor", "os", "istam", "giken", "od", "mengmad", "fmid", "bungek", "zedot", "thak", "tetcth", "romek", "utir", "<lul", "uleng", "sosmil", "aval", "lush*b", "asin", "vunom", "vurtib", "gukil", "dimol", "lelgas", "nethg''n", "itur", "avan", "mingus", "aroth", "udos", "imust", "sh...mman", "rinmol", "muzish", "k''n", "stul", "thash", "kenis", "fathkal", "inob", "igril", "an", "unob", "nalthish", "ost%sh", "kel", "eddaz", "ekur", "arfl", "shar", "rimuk", "ottan", "shagul", "*nul", "egeth", "s''d", "dusak", "ovus", "gom*k", "stesok", "vanktb", "<lon", "od^s", "alen", "bobrur", "stoling", "dum", "zagstok", "ol", "gatis", "udler", "adesh", "usfn", "kavud", "kirun", "shasad", "shoveth", "lathon", "um", "thubil", "egom", "ugith", "ngutug", "kez", "l,rim", "ik-l", "semtom", "kib", "rotik", "ir", "stos^th", "kezol", "anan", "disuth", "rcethol", "tezul", "irol", "otam", "rod<m", "nunok", "umel", "ishlum", "kin", "mebzuth", "usib", "nar", "migrur", "egar", "dakon", "lod", "nir", "an''n", "muved", "am", "vab''k", " g", "ritas", "udril", "shigcs", "d thnes", "fgez", "m''rul", "zulash", "logem", "abal", "kulin", "lerom", "gatin", "ul", "monom", "biscl", "ginok", "rumred", "ugeth", "thuveg", "gor", "damol", "elcur", "erok", "tok", "cem", "rSt", "shoner", "inrus", "mist^m", "midor", "nilgin", "merir", "nikuz", "kamuk", "enal", "zSler", "stibbom", "vildang", "arkoth", "lash%d", "kasith", "ngathsesh", "tashem", "besmar", "furgig", "n''nub", "rushrul", "megob", "uvir", "shrir", "esrel", "bukSt", "nimak", "lestus", "fullut", "arkim", "imsal", "led", "unib", "ron", "udar", "borush", "detes", "umoz", "serkib", "vudthar", "razot", "atem", "ezuk", "vozbel", "toltot", "n,r", "stukos", "ang", "nuden", "ikud", "memad", "eshik", "emgash", "tirist", "athel", "seng", "osdin", "ethram", "kamut", "locun", "selor", "ig%r", "id", "astts", "fbir", "mosus", "omthel", "odur", "istbar", "zodost", "dumat", "relon", "notlith", "suthtn", "ilid", "tithleth", "kezar", "ast", "fath", "t''l£n", "nabid", "sibrek", "thining", "gasns", "noglesh", "aroz", "tfmol", "nanul", "urr<th", "kik%s", "askak", "kes", "abshoth", "ubas", "angish", "allas", "gembish", "urvad", "fel", "ingul", "nekut", "genlath", "shulmik", "lenod", "abras", "asol", "shethel", "urn-t", "zursul", "othsal", "shedim", "arak", "tiz''t", "taran", "bithit", "otik", "kerlceg", "l^ned", "sodel", "''nam", "zuglar", "keskal", "ntst", "uvcth", "mcevid", ",th", "kaffsh", "ngumrash", "zokun", "eshom", "nesteth", "thebil", "ammesh", "ral", "reksas", "gesis", "osal", "anir", "nabreth", "dak,l", "rungak", "nekol", "anriz", "kosh", "noth", "tharnas", "gansit", "b...goz", "bim", "themthir", "sakil", "tekmok", "rasuk", "g,zot", "toz''r", "tob", "kal", "eshtfn", "mezum", "umar", "zeber", "geles", "therleth", "tinan", "zekrim", "magel", "adur", "ezar", "bonun", "b-nem", "egur", "unol", "vod", "lal", "debish", "bushos", "lokum", "thortith", "omft", "sethal", "soshor", "thocit", "esesh", "l-rit", "ubal", "*stob", "lashid", "usur", "kob", "kigok", "bekom", "magak", "v%s", "estrith", "gongith", "dugud", "zat", "nomal", "oltud", "savot", "vcer", "dustcek", "shnstsak", "risid", "deler", "aztong", "g<non", "sholil", "ecut", "m%tin", "lam", "togal", "mot", "nceles", "nefast", "atith", "r^g", "emen", ",kig", "abod", "sat", "timad", "ibas", "othob", "f-beg", "tunur", "idgag", "eb", "omshit", "ibes", "oceg", "akuth", "isram", "ad", "imgoz", "nis", "stot", "''gred", "sined", "tec...k", "subet", "urmim", "obash", "dastot", "udib", "enkos", "kesh", "kidet", "ob", "thils,g", "asteb", "akmesh", "vim", "angzak", "gakit", "r%cus", "kurik", "unkil", "mez", "erith", "kalur", "arros", "amud", "nobgost", "tan", "l<d", "ashok", "nod", "nin", "rakust", "melbil", "nol", "raz", "dostust", "tat", "st<vut", "sigun", "urdim", "k,l n", "shelret", "<ggal", "r%dreg", "idr,th", "datlad", "ilral", "borik", "meden", "vafig", "tizen", "dizesh", "kobem", "cavor", "shilr...r", "segun", "messog", "bukith", "bufut", "nilim", "ingtak", "damor", "gim", "nob", "eknar", "mengib", "isrir", "ish%m", "ticek", "mer", "othfsh", "k''kdath", "distat", "nirur", "kiret", "thisrid", "vucar", "kizab", "tudrug", "s^gam", "amluth", "nozush", "mirstal", "zamoth", "bomik", "munsog", "razmer", "liruk", "geget", "zenon", "okol", "torir", "stodir", "''ggon", "tikis", "unos", "legon", "alnis", "<kor", "tathtak", "lidod", "azin", "isden", "uker", "kussad", "nilun", "bamg-s", "adril", "koshmot", "fl", "umgush", "senel", "sital", "kil", "kol", "bomrek", "boket", "atil", "iklist", "volal", "lish", "omrist", "ud", "fesh", "akath", "lim", "damced", "anur", "kulal", "lolum", "ducim", "vesrul", "urosh", "akith", "l^rush", "ethir", "ced", "budam", "inol", "okang", "ging", "rilem", "kizest", "keb''sh", "shesam", "ber", "zan", "zust", "enshal", "nastid", "ultSr", "ag", "zareth", "tislam", "doren", "rcth", "ntzom", "akrul", "gusil", "kilrud", "lolok", "lemlor", "ivom", "fikuk", "gulgun", "kast", "usir", "sodzul", "st*k<d", "etas", "otil", "sosad", "n<r", "anban", "dithbish", "ekir", "onol", "godum", "lcelar", "ib", "etur", "rithul", "cboth", "al", "zimkel", "bimmon", ",kil", "tezad", "lfven", "sashas", "sezuk", "saneb", "kik", "dasnast", "it^g", "okil", "esis", "buris", "ecem", "kekath", "nas", "nursher", "limfr", "sostet", "ken", "estil", "oram", "galthor", "nefek", "gabet", "idok", "tetthush", "ukath", "igang", "ushul", "sil", "kar", "thur", "nitom", "azzin", "selen", "gadan", "osor", "thalal", "onesh", "guz", "^sik", "thestar", "astis", "''tthat", "lisid", "nalish", "ozor", "ceshfot", "dok", "edos", "anzish", "l-k", "semor", "multsh", "fm", "kutam", "eges", "fimshel", "egul", "tesum", "cubor", "enseb", "idith", "edim", "vetek", "g,rig", "lecad", "sterus", "umtm", "anil", "nobang", "at^sh", "umril", "milol", "rig*th", "Srith", "thazor", "gashcoz", "bor", "f''ker", "megid", "elik", "tekkud", "olin", "nrlom", "stemel", "inem", "lulfr", "zolak", "g,rem", "gidur", "aban", "neb<n", "zasgim", "thclthod", "iden", "''ssek", "amkol", "l''bor", "shrrat", "k^dnath", "titthal", "stistr,s", "tetist", "riras", "t''ras", "gekur", "gudos", "durad", "z^vut", "adil", "ngesg,s", "stettad", "shos^l", "udil", "litast", "arel", "otin", "vel", "avuz", "rithlut", "tomus", "dugan", "kalal", "shoshin", "eser", "cebmat", "kebul", "asiz", "alm''sh", "rur", "rutod", "vumom", "orrun", "taron", "s rek", "ugosh", "esmul", "kisat", "il", "rinul", "mukar", "amkin", "mosos", "rith", "t*m", "bugud", "otung", "zoz", "umshad", "das%l", "lames", "lavath", "ozur", "zotthol", "nan", "rorash", "nguteg", "''sust", "um,m", "instol", "kesting", "ebbus", "bobet", "ong", "zokgen", "r,duk", "zunek", "kezat", "kad,n", "sar", "^lbem", "ertal", "rfmol", "girust", "nabas", "lozlok", "ongos", "shusug", "tongus", "tustzal", "kgneb", "gamil", "gingim", "arin", "gov-l", "vetor", "sharsid", "nakis", "lanir", "ikl", "nakbab", "nimem", "numol", "urol", "atul", "deg", "onul", ",gash", "bogsosh", "ushang", "emal", "ethzuth", "gathil", "kebon", "sutung", "nizdast", "mimkot", "vir", "tumam", "osstam", "kulsim", "gemis", "^r", "fenok", "igrish", "urus", "rodem", "zengod", "ister", "luskal", "knrar", "ilas", "an-z", "angen", "desis", "damSl", "assog", "usen", "babin", "tustem", "debben", "kabat", "ftast", "ebal", "lanzil", "belar", "solam", "cr", "nucam", "letom", "mengthul", "th^mnol", "lin*n", "vuthil", "rerscer", "oltar", "domas", "asmel", "nish", "mamot", "nakuth", "udist", "ost", "shadust", "morus", "akrel", "kith", "bomel", "orngim", "ngubmul", "mat", "nulom", "ustan", "buzat", "thob", "tilesh", "gecast", "aran", "st%lmith", "dolil", "amem", "kasben", "fashuk", "-bom", "mostod", "mangr*d", "keng", "odkish", "roduk", "eggut", "bumal", "kurel", "kithnn", "nurom", "shomad", "doshet", "ltl", "lun", "kugik", "tulon", "zoden", "nang^s", "rifot", "kastar", "zefon", "kovest", "madush", "ttrem", "shSrel", "goden", "birut", "shorast", "meng", "olthez", "litez", "miz^s", "nonshut", "ltrul", "tusung", "ullung", "minbaz", "zethruk", "k-buk", "kivish", "rithog", "rabed", "rusest", "omtug", "stektob", "zimun", "num", "oslan", "mis", "salul", "langgud", "mugshith", "l*r", "mishthem", "sibnir", "zansong", "or", "est", "thistus", "bot", "aned", "absam", "vuzded", "emet", "luzat", "duthal", "cugshil", "shasar", "emdush", "shungmag", "zar", "luror", "manthul", "sholkik", "sankest", "othud", "ngithol", "udesh", "afen", "dast", "nothis", "cem,z", "sosh", "zalud", "geth", "udiz", "nitig", "ziksis", "midrim", "urthaz", "vuknud", "s<sal", "thum", "ar''sh", "guthstak", "as%n", "neshast", "tenshed", "catten", "l^gan", "...lil", "nukad", "rakas", "bibar", "nitem", "vanel", "som", "gutid", "ros", "sestan", "ganad", "ardes", "tobot", "niral", "zavaz", "tellist", "umgan", "kesham", "azmol", "thokdeg", "dolok", "detgash", "zocuk", "gulnas", "arek", "rath", "ngot-n", "zocol", "evost", "lotol", "farash", "ruken", "enas", "isul", "miroth", "mor", ",srath", "shed", "tabar", "lush-t", "tm", "sut", "saruth", ",rged", "aral", "solon", "zulban", "stan<r", "lorbam", "stkzul", "kat", "teskom", "r,m", "koshosh", "moldath", "-losh", "k£d", "masos", "fastam", "isan", "betan", "thibam", "elol", "uvar", "rul", "zaled", "esar", "k...s", "znzcun", "vathem", "m<shak", "dubmen", "akam", "osram", "kuthd^ng", "assar", "shizek", "mingtuth", "rafum", "omet", "merseth", "cs", "itnet", "g<sstir", "dalem", "<dath", "gemsit", "ashzos", "enten", "nomes", "birir", "kukon", "fgoth", " gesh", "dalzat", "tad", "m%list", "ison", "rokel", "arceth", "rimad", "shigin", "kastol", "ruzos", "sharul", "omt,l", "eren", "sobnr", "noram", "dSg", "neth", "okin", "maskir", "dugal", "shagog", "shazak", "tin''th", "thir", "necak", "ital", "nulral", "nnal", "gomcm", "vumshar", "borlon", "ngobol", "gireth", "okun", "rovol", "thulom", "kanzud", "l*rtm", "rosat", "ottem", "duthtish", "thestkig", "thabost", "v£sh", "cugg n", "obok", "muthir", "rovod", "uzar", "kor", "amas", "ashm''n", "bisek", "zaneg", "gcsmer", "zimesh", "bothon", "losis", "ildom", "azuz", "golast", "edn...d", "evon", "arom", "ninur", "conngim", "fongbez", "arrug", "av-sh", "rimis", "thokit", "agseth", "sharast", "bardum", "givel", "tm", "nikot", "arist", "sheced", "stin", "zoluth", "mestthos", "ineth", "amost", "oklit", "deduk", "m-thkat", "kosoth", "cegbit", "oshgft", "tazuk", "imbit", "b%r-l", "sarvesh", "zuntcer", "sazir", "ekast", "desgir", "stfkud", "gonggash", "uzol", "moshn£n", "urir", "geshak", "lektad", "akir", "zalns", "teshkad", "kudust", "sastres", "becor", "nob''t", "tokthat", "gishgil", "lfndar", "karas", "etom", "thomal", "emad", "tangath", "ezost", "vath", "zakgol", "stibmer", "mnshos", "teling", "lased", "rintor", "cestlig", "tcerdug", "bab", "stingbol", "gethust", "maram", "nid*st", "bashnom", "ekzong", "thusest", "bocash", "dedros", "akur", "cecum", "etvuth", "t''mud", "datur", "tishis", "lir", "dard", "nugreth", "zim", "avum", "ishash", "tel", "ilrom", "unfl", "cilob", "<ngiz", "dakost", "kobel", "sheshek", "tolis", "gothum", "adek", "ibel", "lesast", ",tol", "adas", "custith", "minkot", "ceton", "sholSb", "deg%l", "uvash", "kumil", "fidgam", "lar", "stinth,d", "kemsor", "onrel", "sefol", "edzul", "nisgak", "dotir", "k...lreth", "alek", "resil", "umstiz", "k^shshak", "sirab", "shaketh", "tatek", "isos", "occeg", "atzul", "sebs£r", "odom", "arust", "g''tom", "sulus", "lensham", "geb", "ozon", "ngegdol", "storlut", "bekar", "gan", "zamnuth", "edt-l", "nol^th", "thabum", "astod", "ruth''sh", "lisat", "zagug", "gudas", "sesh", "osh,b", "olil", "ustuth", "tholtig", "medtob", "asob", "gtk<z", "shem", "nadak", "nirmek", "imush", "kogsak", "<teb", "dceshmab", "atces", "t''sed", "kikrost", "ngal k", "takth", "nunr", "vukrig", "rerras", "ar''l", "sosas", "r-l", "tholest", "tishak", "tharith", "vutram", "shotom", "<lun", "rfluk", "vosut", "s-bil", "ifin", "okosh", "zafal", "rulush", "gikut", "rem", "thikthog", "idash", "tathtat", "mesir", "lir,r", "celkeb", "adag", "isak", "kekim", "bfsen", "koman", "imesh", "shetb^th", "ultb", "dogik", "rodim", "kathil", "''ndin", "mekur", "enoz", "satneng", "rotig", "sof-sh", "asrer", "ozleb", "etath", "rumad", "es,st", "suvas", "bal", "oshot", "stelid", "med", "inir", "scebosh", "lunrud", "olum", "shuk", "''ler", "stizash", "gusgash", "<tsas", "edan", "ked", "ungSg", "merrang", "gudid", "kashez", "amal", "athncer", "shithath", "istik", "akmam", "timn,r", "elis", "kan", "lelum", "othil", "oth''s", "nentuk", "dural", "salir", "kulbet", "fazis", "thik,n", "-lmush", "mishar", "tastrod", "tod''r", "ostath", "thasdoth", "belal", "ston", "ribar", "tunom", "kudar", "g,bar", "nothok", "libad", "gemur", "elbel", "ennol", "amnek", "soloz", "mus''d", "samam", "ethad", "eshon", "etcm", "Srnam", "kethil", "enam", "inush", "atol", "''sir", "vathez", "fur...t", "kegeth", "cud<st", "laz", "kttfk", "thedak", "lumnum", "''sed", "orshar", "thad", "shan", "ellest", "odg£b", "inash", "steg%th", "zithis", "lerteth", "stistmig", "luslem", "sherik", "zukthist", "artob", "n%las", "zes", "n^cik", "-thir", "othlest", "ibesh", "fash", "anist", "*rdir", "rab", "orshet", "uzlir", "ginet", "eral", "ilash", "etn...r", "tom^m", "ins,l", "riril", "thimshur", "nokgol", "m''zir", "igath", "gasir", "bubnus", "<thod", "uthmik", "uben", "adbok", "ronush", "rikkir", "thiz", "lak...l", "r''ber", "egast", "akgos", "zatam", "sholid", "akest", "thun", "gidthur", "immast", "sanreb", "m<kstal", "vudnis", "estun", "ozkak", "tkum", "kacoth", "etost", "arban", "kurol", "agsal", "rethal", "oshur", "vathsith", "biths^st", "kezkig", "kir", "shadmal", " dol", "ablish", "shislug", "zutshosh", "ogtum", "bat''k", "izkil", "ireg", "ushlub", "deleth", "thetust", "stigaz", "ethab", "em,th", "konad", "shukar", "idrom", "gubel", "egeb", "astel", "boshut", "uzan", "ranzar", "rcesen", "nakas", "gatiz", "erush", "shameb", "ushesh", "katthir", "ikthag", "rnthar", "sizir", "tost", "al-th", "ator", "kad''l", "istrath", "shos", "ulzest", "kastaz", "kod", "etes", "nosing", "merig", "fushur", "avog", "oth''r", "midil", "fevil", "itt s", "bakust", "b%mbul", "duz", "zeg", "edcl", "kifed", "thet", "ostuk", "endok", "ushat", "ukosh", "lebes", "lim£r", "cd", "desor", "amith", "ilir", "ishol", "otsus", "mogshum", "ishen", "kiddir", "meban", "g£r", "rodum", "monang", "thosbut", "at^k", "edod", "astan", "tangak", "sacat", "d''bar", "komut", "dimshas", "olnen", "tathur", "evud", "oshosh", "orstist", "kab", "talul", "sokan", "nanir", "irid", "t''gum", "asd-g", "mes", "nasod", "lemis", "stukcn", "nanoth", "kokeb", "cruk", "zursl", "mozib", "gorroth", "egsttk", "as...s", "zalstom", "ikal", "esdor", "rilbet", "dezrem", "sebshos", "neb,l", "gethor", "ralfth", "baros", "iseth", "cen,th", "leshal", "san d", "rithzfm", "kordam", "roldeth", "ugut", "arbost", "sedish", "tadar", "azoth", "osresh", "eddud", "artum", "dallith", "siknug", "vashzud", "ngilok", "ilon", "nlud", "gemesh", "rashgur", "mothdast", "d k", "thukkan", "alron", "ung*b", "£tost", "bel", "sanus", "kith,l", "theb", "konos", "neb", "itred", "ecosh", "cegol", "luthoz", "thastith", "remang", "athser", "ngusham", "gingik", "rangab", "kontuth", "letmos", "mishim", "losush", "othbem", "b^ngeng", "lasgan", "utal", "sedur", "engig", "sunggor", "thistun", "k''shdes", "ngefel", "umer", "uleb", "n shas", "r''mab", "sezom", "shashdon", "m%bnith", "k n", "gitnuk", "daros", "nokim", "mostib", "thethrus", "kagmel", "bidnoz", "elbost", "oten", "ushdish", "kitung", "nubam", "onget", "d%ngstam", "nimar", "gelut", "nis-n", "tarem", "nam", "kozoth", "tokmek", "ed", "et", "thunen", "shokmug", "vutok", "zanos", "torad", "berdan", "nal", "mosol", "othduk", "kinem", "zatthud", "nabtr", "rirn''l", "lised", "danman", "nirk£n", "mubun")

	default_priority = 90
	icon_state = "goblin"
	icon = 'monkestation/icons/misc/language.dmi'

/datum/species/goblin/get_species_description()
	return "A species of small green humanoids. Reknown for their stealth, they are also primarily known for their skill in tinkering and construction, which is on the level of dwarves."

/datum/species/goblin/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "",
			SPECIES_PERK_NAME = "Maintenance Native",
			SPECIES_PERK_DESC = "As a creature of filth, you feel right at home in maintenance and can see better!", //Mood boost when in maint? How to do?
		),
		// list(
		// 	SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		// 	SPECIES_PERK_ICON = "fist-raised",
		// 	SPECIES_PERK_NAME = "Swift Hands",
		// 	SPECIES_PERK_DESC = "Your small fingers allow you to pick pockets quieter than most.",		//I DON'T KNOW HOW TO DO THIS >:c
		// ),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "skull",
			SPECIES_PERK_NAME = "Level One Goblin",
			SPECIES_PERK_DESC = "You are a weak being, and have less health than most.", // 0.75% health and Easily Wounded trait
		)
		,list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "",
			SPECIES_PERK_NAME = "Short",
			SPECIES_PERK_DESC = "Short, haha.", //Dwarf trauma
		),
		,list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "hand",
			SPECIES_PERK_NAME = "Small Hands",
			SPECIES_PERK_DESC = "Goblin's small hands allow them to construct machines faster.", //Quick Build trait
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Agile",
			SPECIES_PERK_DESC = "Goblins run faster than other species.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Hard to Keep Down",
			SPECIES_PERK_DESC = "You get back up quicker from stuns.",
		),
	)

	return to_add

/obj/item/bodypart/head/goblin
	icon_greyscale = 'monkestation/icons/mob/species/goblin/bodyparts.dmi'
	limb_id = SPECIES_GOBLIN
	is_dimorphic = FALSE

/obj/item/bodypart/chest/goblin
	icon_greyscale = 'monkestation/icons/mob/species/goblin/bodyparts.dmi'
	limb_id = SPECIES_GOBLIN
	is_dimorphic = TRUE

/obj/item/bodypart/arm/left/goblin
	icon_greyscale = 'monkestation/icons/mob/species/goblin/bodyparts.dmi'
	limb_id = SPECIES_GOBLIN

/obj/item/bodypart/arm/right/goblin
	icon_greyscale = 'monkestation/icons/mob/species/goblin/bodyparts.dmi'
	limb_id = SPECIES_GOBLIN

/obj/item/bodypart/leg/left/goblin
	icon_greyscale = 'monkestation/icons/mob/species/goblin/bodyparts.dmi'
	limb_id = SPECIES_GOBLIN

/obj/item/bodypart/leg/right/goblin
	icon_greyscale = 'monkestation/icons/mob/species/goblin/bodyparts.dmi'
	limb_id = SPECIES_GOBLIN
