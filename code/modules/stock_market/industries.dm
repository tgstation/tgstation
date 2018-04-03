/datum/industry
	var/name = "Industry"
	var/list/tokens = list()

	var/list/title_templates = list("The brand new %product_name% by %company_name% will revolutionize %industry%", \
									"%jobs% rejoice as %product_name% hits shelves", \
									"Does %product_name% threaten to reorganize the %industrial% status quo?", \
									"%company_name% headed toward corporate renaissance with %product_name%")

	var/list/title_templates_neutral = list("%product_name%: as if nothing happened", \
											"Nothing new but the name: %product_name% not quite exciting %jobs%", \
											"Same old %company_name%, same old product", \
											"%product_name% underwhelms, but sells")

	var/list/title_templates_bad = list("%product_name% shaping up to be the disappointment of the century", \
										"Recipe for disaster: %company_name% releases %product_name%", \
										"Atrocious quality - %jobs% boycott %product_name%", \
										"%product_name%: Inside the worst product launch in recent history")

	var/list/title_templates_ooc = list("%company_name% is looking to enter the %industry% playing field with %product_name%", \
										"%company_name% broadens spectrum, %product_name% is their latest and greatest")
	var/list/subtitle_templates = list(	"%author% investigates whether or not you should invest!", \
										"%outlet%'s very own %author% takes it to the magnifying glass", \
										"%outlet% lets you know if you should use it", \
										"Read our top tips for investors", \
										"%author% wants you to know if it's a safe bet to buy")

/datum/industry/proc/generateProductName(var/company_name)
	return

/datum/industry/proc/generateInCharacterProductArticle(var/product_name, var/datum/stock/S)
	var/datum/article/A = new
	var/list/add_tokens = list("company_name" = S.name, "product_name" = product_name, "outlet" = A.outlet, "author" = A.author)
	A.about = S
	A.opinion = rand(-1, 1)

	A.subtitle = A.detokenize(pick(subtitle_templates), tokens, add_tokens)
	var/article = {"%company_name% %expand_influence% %industry%. [ucfirst(product_name)] %hit_shelves% %this_time% "}
	if (A.opinion > 0)
		A.headline = A.detokenize(pick(title_templates), tokens, add_tokens)
		article += "but %positive_outcome%, %signifying% the %resounding% %success% the product is. The %stock_market% is %excited% over this %development%, and %stockholder% optimism is expected to %rise% as well as the stock value. Our advice: %buy%."
	else if (A.opinion == 0)
		A.headline = A.detokenize(pick(title_templates_neutral), tokens, add_tokens)
		article += "but %neutral_outcome%. For the average %stockholder%, no significant change on the market will be apparent over this %development%. Our advice is to continue investing as if this product was never released."
	else
		A.headline = A.detokenize(pick(title_templates_bad), tokens, add_tokens)
		article += "but %negative_outcome%. Following this %complete% %failure%, %stockholder% optimism and stock value are projected to %dip%. Our advice: %sell%."
	A.article = A.detokenize(article, tokens, add_tokens)
	return A

/datum/industry/proc/detokenize(var/str)
	for (var/T in tokens)
		str = replacetext(str, "%[T]%", pick(tokens[T]))
	return str

/datum/industry/agriculture
	name = "Agriculture"
	tokens = list( \
		"industry" = list("agriculture", "farming", "botany", "horticulture", "hydroponics"), \
		"industrial" = list("agricultural", "horticultural", "botanical"), \
		"jobs" = list("farmers", "agricultural experts", "botanists", "assistant gardeners")
	)
	title_templates = list(	"The brand new %product_name% by %company_name% will revolutionize %industry%", \
							"%jobs% rejoice as %product_name% hits shelves", \
							"Does %product name% threaten to reorganize the %industrial% status quo?", \
							"Took it for a field trip: our first %sneak_peek% of %product_name%.", \
							"Reaping the fruits of %product_name% - %sneak_peek% by %author%", \
							"Cultivating a new %industrial% future with %product_name%", \
							"%company_name% grows and thrives: %product_name% now on the farmer's market", \
							"It's almost harvest season: %product_name% promises to ease your life", \
							"Become the best on the farmer's market with %product_name%", \
							"%product_name%: a gene-modified reimagination of an age-old classic")

	title_templates_ooc = list(	"%company_name% is looking to enter the %industry% playing field with %product_name%", \
								"A questionable decision: %product_name% grown on the soil of %company_name%", \
								"%company_name% broadens spectrum, %product_name% is their latest and greatest", \
								"Will %company_name% grow on %industrial% wasteland? Owners of %product_name% may decide", \
								"%company_name% looking to reap profits off the %industrial% sector with %product_name%")

/datum/industry/agriculture/generateProductName(var/company_name)
	var/list/products = list("water tank", "cattle prod", "scythe", "plough", "sickle", "cultivator", "loy", "spade", "hoe", "daisy grubber", "cotton gin")
	var/list/prefix = list("[company_name]'s ", "the [company_name] ", "the fully automatic ", "the full-duplex ", "the semi-automatic ", "the drone-mounted ", "the industry-leading ", "the world-class ")
	var/list/suffix = list(" of farming", " multiplex", " +[rand(1,15)]", " [consonant()][rand(1000, 9999)]", " hybrid", " maximus", " extreme")
	return "[pick(prefix)][pick(products)][pick(suffix)]"



/datum/industry/it
		name = "Information Technology"
		tokens = list( \
			"industry" = list("information technology", "computing", "computer industry"), \
			"industrial" = list("information technological", "computing", "computer industrial"), \
			"jobs" = list("coders", "electricians", "engineers", "programmers", "devops experts", "developers")
		)

/datum/industry/it/proc/latin_number(n)
	if (n < 20 || !(n % 10))
		switch(n)
			if (0)
				return "Nihil"
			if (1)
				return "Unus"
			if (2)
				return "Duo"
			if (3)
				return "Tres"
			if (4)
				return "Quattour"
			if (5)
				return "Quinque"
			if (6)
				return "Sex"
			if (7)
				return "Septem"
			if (8)
				return "Octo"
			if (9)
				return "Novem"
			if (10)
				return "Decim"
			if (11)
				return "Undecim"
			if (12)
				return "Duodecim"
			if (13)
				return "Tredecim"
			if (14)
				return "Quattourdecim"
			if (15)
				return "Quindecim"
			if (16)
				return "Sedecim"
			if (17)
				return "Septdecim"
			if (18)
				return "Duodeviginti"
			if (19)
				return "Undeviginti"
			if (20)
				return "Viginti"
			if (30)
				return "Triginta"
			if (40)
				return "Quadriginta"
			if (50)
				return "Quinquaginta"
			if (60)
				return "Sexaginta"
			if (70)
				return "Septuaginta"
			if (80)
				return "Octoginta"
			if (90)
				return "Nonaginta"
	else
		return "[latin_number(n - (n % 10))] [lowertext(latin_number(n % 10))]"

/datum/industry/it/generateProductName(var/company_name)
	var/list/products = list("generator", "laptop", "keyboard", "memory card", "display", "operating system", "processor", "graphics card", "nanobots", "power supply", "pAI", "mech", "capacitor", "cell")
	var/list/prefix = list("the [company_name] ", "the high performance ", "the mobile ", "the portable ", "the professional ", "the extreme ", "the incredible ", "the blazing fast ", "the bleeding edge ", "the bluespace-powered ", null)
	var/L = pick(consonant(), "Seed ", "Radiant ", "Robust ", "Pentathon ", "Athlete ", "Phantom ", "Semper Fi ")
	var/N = rand(1, 99)
	var/prefix2 = "[L][N][prob(5) ? " " + latin_number(N) : null]"
	return "[pick(prefix)][prefix2] [pick(products)]"

/datum/industry/communications
	name = "Communications"
	tokens = list( \
		"industry" = list("telecommunications", "telecomms"), \
		"industrial" = list("telecommunicational"), \
		"jobs" = list("electrical engineers", "microengineers", "developers")
	)

/datum/industry/communications/generateProductName(var/company_name)
	var/list/products = list("mobile phone", "PDA", "tablet computer", "newscaster", "social network")
	var/list/prefix = list("the [company_name] ", "the high performance ", "the mobile ", "the portable ", "the professional ", "the extreme ", "the incredible ", "the blazing fast ", "the bleeding edge ", null)
	var/L = pick("[lowertext(consonant())]Phone ", "Universe ", "Xperience ", "Next ", "Engin Y ", "Cyborg ", "[consonant()]")
	var/N = rand(1,99)
	var/prefix2 = "[L][N][prob(25) ? pick(" Tiny", " Mini", " Micro", " Slim", " Water", " Air", " Fire", " Earth", " Nano", " Pico", " Femto", " Planck") : null]"
	return "[pick(prefix)][prefix2] [pick(products)]"

/datum/industry/health
	name = "Medicine"
	tokens = list( \
		"industry" = list("medicine"), \
		"industrial" = list("medicinal"), \
		"jobs" = list("medical doctors", "nurses", "paramedics", "psychologists", "psychiatrists", "chemists")
	)

/datum/industry/health/generateProductName(var/company_name)
	var/list/prefix = list("amino", "nucleo", "nitro", "panto", "meth", "eth", "as", "algo", "coca", "hero", "lotsu", "opiod", "morph", "trinitro", "prop", "but", "acet", "acyclo", "lansop", "dyclo", "hydro", "oxycod", "vicod", "cannabi", "cryo", "dex", "chloro")
	var/list/suffix = list("phen", "pirin", "pyrine", "ane", "amphetamine", "prazoline", "ine", "yl", "amine", "aminophen", "one", "ide", "phenate", "anol", "toulene", "glycerine", "vir", "tol", "trinic", "oxide")
	var/list/uses = list("antidepressant", "analgesic", "anesthetic", "antiretroviral", "antiviral", "antibiotic", "cough drop", "depressant", "hangover cure", "homeopathic", "fertility drug", "hypnotic", "narcotic", "laxative", "multivitamin", "patch", "purgative", "relaxant", "steroid", "sleeping pill", "suppository", "tranquilizer")
	return "[pick(prefix)][pick(suffix)], the [pick(uses)]"

/datum/industry/consumer
	name = "Consumer"
	tokens = list( \
		"industry" = list("shops", "stores"), \
		"industrial" = list("consumer industrial"), \
		"jobs" = list("shopkeepers", "assistants", "manual daytime hygiene engineers", "janitors", "chefs", "cooks")
	)

/datum/industry/consumer/generateProductName(var/company)
	var/list/meat = list("chicken", "lizard", "corgi", "monkey", "goat", "fly", "xenomorph", "human", "walrus", "wendigo", "bear", "clown", "turkey", "pork", "carp", "crab", "mimic", "mystery")
	var/list/qualifier = list("synthetic", "organic", "bio", "diet", "sugar-free", "paleolithic", "homeopathic", "recycled", "reclaimed", "vat-grown")
	return "the [pick(qualifier)] [pick(meat)] meat product line"

/datum/industry/mining
	name = "Mining"
	tokens = list( \
		"industry" = list("mines", "large scale mining operations"), \
		"industrial" = list("resource acquisitional"), \
		"jobs" = list("shaft miners", "drill operators", "mining foremen", "gibtonite handlers")
	)

/datum/industry/mining/generateProductName(var/company)
	var/list/equipment = list("drill", "pickaxe", "shovel", "jackhammer", "mini-pickaxe", "power hammer", "power gloves", "power armor", "hardsuit", "kinetic accelerator", "resonator", "oxygen tank", "emergency bike horn")
	var/list/material = list("mauxite", "pharosium", "molitz", "adamantium", "mithril", "cobryl", "bohrum", "claretine", "viscerite", "syreline", "cerenkite", "plasmastone", "gold", "koshmarite", "phoron", "carbon dioxide")
	return "the [pick(material)] [pick(equipment)]"

/datum/industry/defense
	name = "Defense"
	tokens = list ( \
		"industry" = list("defense", "warfare", "security", "law enforcement"), \
		"industrial" = list("defense"), \
		"jobs" = list("security officers", "government officials", "soldiers", "weapons engineers")
	)

/datum/industry/defense/generateProductName(var/company)
	var/list/equipment = list("energy gun", "laser gun", "machine gun", "grenade", "stun baton", "artillery", "bomb", "attack drone", "missile", "chem sprayer")
	var/list/material = list("bluespace", "stealth", "heat-seeking", "crime-seeking", "wide-range", "bioterror", "auto-reloading", "smart", "sentient", "rapid-fire", "species-targeting", "gibtonite", "mass-market", "perpetual-motion", "nuclear", "fission", "fusion")
	return "the [pick(material)] [pick(equipment)]"
