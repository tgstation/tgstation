

/datum/stockMarket
	var/list/stocks = list()
	var/list/balances = list()
	var/list/last_read = list()
	var/list/stockBrokers = list()
	var/list/logs = list()

/datum/stockMarket/New()
		..()
		generateBrokers()
		generateStocks()
		START_PROCESSING(SSobj, src)

/datum/stockMarket/proc/balanceLog(var/whose, var/net)
	if (!(whose in balances))
		balances[whose] = net
	else
		balances[whose] += net
/datum/stockMarket/proc/generateBrokers()
	stockBrokers = list()
	var/list/fnames = list("Goldman", "Edward", "James", "Luis", "Alexander", "Walter", "Eugene", "Mary", "Morgan", "Jane", "Elizabeth", "Xavier", "Hayden", "Samuel", "Lee")
	var/list/names = list("Johnson", "Rothschild", "Sachs", "Stanley", "Hepburn", "Brown", "McColl", "Fischer", "Edwards", "Becker", "Witter", "Walker", "Lambert", "Smith", "Montgomery", "Lynch", "Roosevelt", "Lehman")
	var/list/locations = list("Earth", "Luna", "Mars", "Saturn", "Jupiter", "Uranus", "Pluto", "Europa", "Io", "Phobos", "Deimos", "Space", "Venus", "Neptune", "Mercury", "Kalliope", "Ganymede", "Callisto", "Amalthea", "Himalia", "Sybil", "Basil", "Badger", "Terry", "Artyom")
	var/list/first = list("The", "First", "Premier", "Finest", "Prime")
	var/list/company = list("Investments", "Securities", "Corporation", "Bank", "Brokerage", "& Co.", "Brothers", "& Sons", "Investement Firm", "Union", "Partners", "Capital", "Trade", "Holdings")
	for(var/i in 1 to 5)
		var/pname = ""
		switch (rand(1,5))
			if (1)
				pname = "[prob(10) ? pick(first) + " " : null][pick(names)] [pick(company)]"
			if (2)
				pname = "[pick(names)] & [pick(names)][prob(25) ? " " + pick(company) : null]"
			if (3)
				pname = "[prob(45) ? pick(first) + " " : null][pick(locations)] [pick(company)]"
			if (4)
				pname = "[prob(10) ? "The " : null][pick(names)] [pick(locations)] [pick(company)]"
			if (5)
				pname = "[prob(10) ? "The " : null][pick(fnames)] [pick(names)][prob(10) ? " " + pick(company) : null]"
		if (pname in stockBrokers)
			i--
			continue
		stockBrokers += pname

/datum/stockMarket/proc/generateDesignation(var/name)
	if (length(name) <= 4)
		return uppertext(name)
	var/list/w = splittext(name, " ")
	if (w.len >= 2)
		var/d = ""
		for(var/i in 1 to min(5, w.len))
			d += uppertext(ascii2text(text2ascii(w[i], 1)))
		return d
	else
		var/d = uppertext(ascii2text(text2ascii(name, 1)))
		for(var/i in 2 to length(name))
			if (prob(100 / i))
				d += uppertext(ascii2text(text2ascii(name, i)))
		return d

/datum/stockMarket/proc/generateStocks(var/amt = 15)
	var/list/fruits = list("Banana", "Mimana", "Watermelon", "Ambrosia", "Pomegranate", "Reishi", "Papaya", "Mango", "Tomato", "Conkerberry", "Wood", "Lychee", "Mandarin", "Harebell", "Pumpkin", "Rhubarb", "Tamarillo", "Yantok", "Ziziphus", "Oranges", "Gatfruit", "Daisy", "Kudzu")
	var/list/tech_prefix = list("Nano", "Cyber", "Funk", "Astro", "Fusion", "Tera", "Exo", "Star", "Virtual", "Plasma", "Robust", "Bit", "Future", "Hugbox", "Carbon", "Nerf", "Buff", "Nova", "Space", "Meta", "Cyber")
	var/list/tech_short = list("soft", "tech", "prog", "tec", "tek", "ware", "", "gadgets", "nics", "tric", "trasen", "tronic", "coin")
	var/list/random_nouns = list("Johnson", "Cluwne", "General", "Specific", "Master", "King", "Queen", "Table", "Rupture", "Dynamic", "Massive", "Mega", "Giga", "Certain", "Singulo", "State", "National", "International", "Interplanetary", "Sector", "Planet", "Burn", "Robust", "Exotic", "Solar", "Lunar", "Chelp", "Corgi", "Lag", "Lizard")
	var/list/company = list("Company", "Factory", "Incorporated", "Industries", "Group", "Consolidated", "GmbH", "LLC", "Ltd", "Inc.", "Association", "Limited", "Software", "Technology", "Programming", "IT Group", "Electronics", "Nanotechnology", "Farms", "Stores", "Mobile", "Motors", "Electric", "Designs", "Energy", "Pharmaceuticals", "Communications", "Wholesale", "Holding", "Health", "Machines", "Astrotech", "Gadgets", "Kinetics")
	for (var/i = 1, i <= amt, i++)
		var/datum/stock/S = new
		var/sname = ""
		switch (rand(1,6))
			if(1)
				while (sname == "" || sname == "FAG") // honestly it's a 0.6% chance per round this happens - or once in 166 rounds - so i'm accounting for it before someone yells at me
					sname = "[consonant()][vowel()][consonant()]"
			if (2)
				sname = "[pick(tech_prefix)][pick(tech_short)][prob(20) ? " " + pick(company) : null]"
			if (3 to 4)
				var/fruit = pick(fruits)
				fruits -= fruit
				sname = "[prob(10) ? "The " : null][fruit][prob(40) ? " " + pick(company): null]"
			if (5 to 6)
				var/pname = pick(random_nouns)
				random_nouns -= pname
				switch (rand(1,3))
					if (1)
						sname = "[pname] & [pname]"
					if (2)
						sname = "[pname] [pick(company)]"
					if (3)
						sname = "[pname]"
		S.name = sname
		S.short_name = generateDesignation(S.name)
		S.current_value = rand(10, 125)
		var/dv = rand(10, 40) / 10
		S.fluctuational_coefficient = prob(50) ? (1 / dv) : dv
		S.average_optimism = rand(-10, 10) / 100
		S.optimism = S.average_optimism + (rand(-40, 40) / 100)
		S.current_trend = rand(-200, 200) / 10
		S.last_trend = S.current_trend
		S.disp_value_change = rand(-1, 1)
		S.speculation = rand(-20, 20)
		S.average_shares = round(rand(500, 10000) / 10)
		S.outside_shareholders = rand(1000, 30000)
		S.available_shares = rand(200000, 800000)
		S.fluctuation_rate = rand(6, 20)
		S.generateIndustry()
		S.generateEvents()
		stocks += S
		last_read[S] = list()

/datum/stockMarket/process()
	for (var/stock in stocks)
		var/datum/stock/S = stock
		S.process()

/datum/stockMarket/proc/add_log(var/log_type, var/user, var/company_name, var/stocks, var/shareprice, var/money)
	var/datum/stock_log/L = new log_type
	L.user_name = user
	L.company_name = company_name
	L.stocks = stocks
	L.shareprice = shareprice
	L.money = money
	L.time = time2text(world.timeofday, "hh:mm")
	logs += L

GLOBAL_DATUM_INIT(stockExchange, /datum/stockMarket, new)

/proc/plotBarGraph(var/list/points, var/base_text, var/width=400, var/height=400)
	var/output = "<table style='border:1px solid black; border-collapse: collapse; width: [width]px; height: [height]px'>"
	if (points.len && height > 20 && width > 20)
		var/min = points[1]
		var/max = points[1]
		for (var/v in points)
			if (v < min)
				min = v
			if (v > max)
				max = v
		var/cells = (height - 20) / 20
		if (cells > round(cells))
			cells = round(cells) + 1
		var/diff = max - min
		var/ost = diff / cells
		if (min > 0)
			min = max(min - ost, 0)
		diff = max - min
		ost = diff / cells
		var/cval = max
		var/cwid = width / (points.len + 1)
		for (var/y = cells, y > 0, y--)
			if (y == cells)
				output += "<tr>"
			else
				output += "<tr style='border:none; border-top:1px solid #00ff00; height: 20px'>"
			for (var/x = 0, x <= points.len, x++)
				if (x == 0)
					output += "<td style='border:none; height: 20px; width: [cwid]px; font-size:10px; color:#00ff00; background:black; text-align:right; vertical-align:bottom'>[round(cval - ost)]</td>"
				else
					var/v = points[x]
					if (v >= cval)
						output += "<td style='border:none; height: 20px; width: [cwid]px; background:#0000ff'>&nbsp;</td>"
					else
						output += "<td style='border:none; height: 20px; width: [cwid]px; background:black'>&nbsp;</td>"
			output += "</tr>"
			cval -= ost
		output += "<tr><td style='font-size:10px; height: 20px; width: 100%; background:black; color:green; text-align:center' colspan='[points.len + 1]'>[base_text]</td></tr>"
	else
		output += "<tr><td style='width:[width]px; height:[height]px; background: black'></td></tr>"
		output += "<tr><td style='font-size:10px; background:black; color:green; text-align:center'>[base_text]</td></tr>"

	return "[output]</table>"

