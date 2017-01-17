/proc/consonant()
	return pick("B","C","D","F","G","H","J","K","L","M","N","P","Q","R","S","T","V","W","X","Y","Z")

/proc/vowel()
	return pick("A", "E", "I", "O", "U")

/proc/ucfirst(var/S)
	return "[uppertext(ascii2text(text2ascii(S, 1)))][copytext(S, 2)]"

/proc/ucfirsts(var/S)
	var/list/L = splittext(S, " ")
	var/list/M = list()
	for (var/P in L)
		M += ucfirst(P)
	return jointext(M, " ")

var/global/list/FrozenAccounts = list()

/proc/list_frozen()
	for (var/A in FrozenAccounts)
		usr << "[A]: [length(FrozenAccounts[A])] borrows"

/datum/article
	var/headline = "Something big is happening"
	var/subtitle = "Investors panic as stock market collapses"
	var/article = "God, it's going to be fun to randomly generate this."
	var/author = "P. Pubbie"
	var/spacetime = ""
	var/opinion = 0
	var/ticks = 0
	var/datum/stock/about = null
	var/outlet = ""
	var/static/list/outlets = list()
	var/static/list/default_tokens = list( \
		"buy" = list("buy!", "buy, buy, buy!", "get in now!", "ride the share value to the stars!"), \
		"company" = list("company", "corporation", "conglomerate", "enterprise", "venture"), \
		"complete" = list("complete", "total", "absolute", "incredible"), \
		"country" = list("Space", "Argentina", "Hungary", "United States of America", "United Space", "Space Federation", "Nanotrasen", "The Wizard Federation", "United Kingdom", "Poland", "The Syndicate", "Australia", "Serbia", "The European Union", "The Illuminati", "The New World Order", "Eurasian Union", "Asian Union", "United Arab Emirates", "Arabian League", "United States of Africa", "Mars Federation", "Allied Colonies of Jupiter", "Saturn's Ring", "Fringe Republic of Formerly Planet Pluto"), \
		"development" = list("development", "unfolding of events", "turn of events", "new shit"), \
		"dip" = list("dip", "fall", "plunge", "decrease"), \
		"excited" = list("excited", "euphoric", "exhilarated", "thrilled", "stimulated"), \
		"expand_influence" = list("expands their influence over", "continues to dominate", "gains traction in", "rolls their new product line out in"), \
		"failure" = list("failure", "meltdown", "breakdown", "crash", "defeat", "wreck"), \
		"famous" = list("famous", "prominent", "leading", "renowned", "expert"), \
		"hit_shelves" = list("hit the shelves", "appeared on the market", "came out", "was released"), \
		"industry" = list("industry", "sector"), \
		"industrial" = list("industrial"), \
		"jobs" = list("workers"), \
		"negative_outcome" = list("it's not leaving the shelves", "nobody seems to care", "it's a huge money sink", "they have already pulled all advertising and marketing support"), \
		"neutral_outcome" = list("it's not lifting off as expected", "it's not selling according to expectations", "it's only generating enough profit to cover the marketing and manufacturing costs", "it does not look like it will become a massive success", "it's experiencing modest sales"), \
		"positive_outcome" = list("it's already sold out", "it has already sold over one billion units", "suppliers cannot keep up with the wild demand", "several companies using this new technology are already reporting a projected increase in profits"), \
		"resounding" = list("resounding", "tremendous", "total", "massive", "terrific", "colossal"), \
		"rise" = list("rise", "increase", "fly off the positive side of the charts", "skyrocket", "lift off"), \
		"sell" = list("sell!", "sell, sell, sell!", "bail!", "abandon ship!", "get out before it's too late!", "evacuate!", "withdraw!"), \
		"signifying" = list("signifying", "indicating", "implying", "displaying", "suggesting"), \
		"sneak_peek" = list("review", "sneak peek", "preview", "exclusive look"), \
		"stock_market" = list("stock market", "stock exchange"), \
		"stockholder" = list("stockholder", "shareholder"), \
		"success" = list("success", "triumph", "victory"), \
		"this_time" = list("this week", "last week", "this month", "yesterday", "today", "a few days ago") \
	)

/datum/article/New()
	..()
	if ((outlets.len && !prob(100 / (outlets.len + 1))) || !outlets.len)
		var/ON = generateOutletName()
		if (!(ON in outlets))
			outlets[ON] = list()
		outlet = ON
	else
		outlet = pick(outlets)

	var/list/authors = outlets[outlet]
	if ((authors.len && !prob(100 / (authors.len + 1))) || !authors.len)
		var/AN = generateAuthorName()
		outlets[outlet] += AN
		author = AN
	else
		author = pick(authors)

	ticks = world.time

/datum/article/proc/generateOutletName()
	var/list/locations = list("Earth", "Luna", "Mars", "Saturn", "Jupiter", "Uranus", "Pluto", "Europa", "Io", "Phobos", "Deimos", "Space", "Venus", "Neptune", "Mercury", "Kalliope", "Ganymede", "Callisto", "Amalthea", "Himalia", "Orion", "Sybil", "Basil", "Badger", "Terry", "Artyom")
	var/list/nouns = list("Post", "Herald", "Sun", "Tribune", "Mail", "Times", "Journal", "Report")
	var/list/timely = list("Daily", "Hourly", "Weekly", "Biweekly", "Monthly", "Yearly")

	switch(rand(1,2))
		if (1)
			return "The [pick(locations)] [pick(nouns)]"
		if (2)
			return "The [pick(timely)] [pick(nouns)]"

/datum/article/proc/generateAuthorName()
	switch(rand(1,3))
		if (1)
			return "[consonant()]. [pick(last_names)]"
		if (2)
			return "[prob(50) ? pick(first_names_male) : pick(first_names_female)] [consonant()].[prob(50) ? "[consonant()]. " : null] [pick(last_names)]"
		if (3)
			return "[prob(50) ? pick(first_names_male) : pick(first_names_female)] \"[prob(50) ? pick(first_names_male) : pick(first_names_female)]\" [pick(last_names)]"

/datum/article/proc/formatSpacetime()
	var/ticksc = round(ticks/100)
	ticksc = ticksc % 100000
	var/ticksp = "[ticksc]"
	while (length(ticksp) < 5)
		ticksp = "0[ticksp]"
	spacetime = "[ticksp][time2text(world.realtime, "MM")][time2text(world.realtime, "DD")]2556"

/datum/article/proc/formatArticle()
	if (spacetime == "")
		formatSpacetime()
	var/output = "<div class='article'><div class='headline'>[headline]</div><div class='subtitle'>[subtitle]</div><div class='article-body'>[article]</div><div class='author'>[author]</div><div class='timestamp'>[spacetime]</div></div>"
	return output

/datum/article/proc/detokenize(var/token_string, var/list/industry_tokens, var/list/product_tokens = list())
	var/list/T_list = default_tokens.Copy()
	for (var/I in industry_tokens)
		T_list[I] = industry_tokens[I]
	for (var/I in product_tokens)
		T_list[I] = list(product_tokens[I])
	for (var/I in T_list)
		token_string = replacetext(token_string, "%[I]%", pick(T_list[I]))
	return ucfirst(token_string)