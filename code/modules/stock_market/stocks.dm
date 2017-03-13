/datum/stock
	var/name = "Stock"
	var/short_name = "STK"
	var/desc = "A company that does not exist."
	var/list/values = list()
	var/current_value = 10
	var/last_value = 10
	var/list/products = list()

	var/performance = 0						// The current performance of the company. Tends itself to 0 when no events happen.

	// These variables determine standard fluctuational patterns for this stock.
	var/fluctuational_coefficient = 1		// How much the price fluctuates on an average daily basis
	var/average_optimism = 0				// The history of shareholder optimism of this stock
	var/current_trend = 0
	var/last_trend = 0
	var/speculation = 0
	var/bankrupt = 0

	var/disp_value_change = 0
	var/optimism = 0
	var/last_unification = 0
	var/average_shares = 100
	var/outside_shareholders = 10000		// The amount of offstation people holding shares in this company. The higher it is, the more fluctuation it causes.
	var/available_shares = 500000

	var/list/borrow_brokers = list()
	var/list/shareholders = list()
	var/list/borrows = list()
	var/list/events = list()
	var/list/articles = list()
	var/fluctuation_rate = 15
	var/fluctuation_counter = 0
	var/datum/industry/industry = null

/datum/stock/proc/addEvent(var/datum/stockEvent/E)
	events |= E

/datum/stock/proc/addArticle(var/datum/article/A)
	if (!(A in articles))
		articles.Insert(1, A)
	A.ticks = world.time

/datum/stock/proc/generateEvents()
	var/list/types = typesof(/datum/stockEvent) - /datum/stockEvent
	for (var/T in types)
		generateEvent(T)

/datum/stock/proc/generateEvent(var/T)
	var/datum/stockEvent/E = new T(src)
	addEvent(E)

/datum/stock/proc/affectPublicOpinion(var/boost)
	optimism += rand(0, 500) / 500 * boost
	average_optimism += rand(0, 150) / 5000 * boost
	speculation += rand(-1, 50) / 10 * boost
	performance += rand(0, 150) / 100 * boost

/datum/stock/proc/generateIndustry()
	if (findtext(name, "Farms"))
		industry = new /datum/industry/agriculture
	else if (findtext(name, "Software") || findtext(name, "Programming")  || findtext(name, "IT Group") || findtext(name, "Electronics") || findtext(name, "Electric") || findtext(name, "Nanotechnology"))
		industry = new /datum/industry/it
	else if (findtext(name, "Mobile") || findtext(name, "Communications"))
		industry = new /datum/industry/communications
	else if (findtext(name, "Pharmaceuticals") || findtext(name, "Health"))
		industry = new /datum/industry/health
	else if (findtext(name, "Wholesale") || findtext(name, "Stores"))
		industry = new /datum/industry/consumer
	else
		var/ts = typesof(/datum/industry) - /datum/industry
		var/in_t = pick(ts)
		industry = new in_t
	for (var/i = 0, i < rand(2, 5), i++)
		products += industry.generateProductName(name)

/datum/stock/proc/frc(amt)
	var/shares = available_shares + outside_shareholders * average_shares
	var/fr = amt / 100 / shares * fluctuational_coefficient * fluctuation_rate * max(-(current_trend / 100), 1)
	if ((fr < 0 && speculation < 0) || (fr > 0 && speculation > 0))
		fr *= max(abs(speculation) / 5, 1)
	else
		fr /= max(abs(speculation) / 5, 1)
	return fr

/datum/stock/proc/supplyGrowth(amt)
	var/fr = frc(amt)
	available_shares += amt
	if (abs(fr) < 0.0001)
		return
	current_value -= fr * current_value

/datum/stock/proc/supplyDrop(amt)
	supplyGrowth(-amt)

/datum/stock/proc/fluctuate()
	var/change = rand(-100, 100) / 10 + optimism * rand(200) / 10
	optimism -= (optimism - average_optimism) * (rand(10,80) / 1000)
	var/shift_score = change + current_trend
	var/as_score = abs(shift_score)
	var/sh_change_dev = rand(-10, 10) / 10
	var/sh_change = shift_score / (as_score + 100) + sh_change_dev
	var/shareholder_change = round(sh_change)
	outside_shareholders += shareholder_change
	var/share_change = shareholder_change * average_shares
	if (as_score > 20 && prob(as_score / 4))
		var/avg_change_dev = rand(-10, 10) / 10
		var/avg_change = shift_score / (as_score + 100) + avg_change_dev
		average_shares += avg_change
		share_change += outside_shareholders * avg_change

	var/cv = last_value
	supplyDrop(share_change)
	available_shares += share_change // temporary

	if (prob(25))
		average_optimism = max(min(average_optimism + (rand(-3, 3) - current_trend * 0.15) / 100, 1), -1)

	var/aspec = abs(speculation)
	if (prob((aspec - 75) * 2))
		speculation += rand(-4, 4)
	else
		if (prob(50))
			speculation += rand(-4, 4)
		else
			speculation += rand(-400, 0) / 1000 * speculation
			if (prob(1) && prob(5)) // pop that bubble
				speculation += rand(-4000, 0) / 1000 * speculation
	var/fucking_stock_spikes = current_value + 500
	var/piece_of_shit_fuck = current_value - 500
	var/i_hate_this_code = (speculation / rand(25000, 50000) + performance / rand(100, 800)) * current_value
	if(i_hate_this_code < fucking_stock_spikes || i_hate_this_code > piece_of_shit_fuck)
		current_value += i_hate_this_code
	if (current_value < 5)
		current_value = 5

	if (performance != 0)
		performance = rand(900,1050) / 1000 * performance
		if (abs(performance) < 0.2)
			performance = 0

	disp_value_change = (cv < current_value) ? 1 : ((cv > current_value) ? -1 : 0)
	last_value = current_value
	if (values.len >= 50)
		values.Cut(1,2)
	values += current_value

	if (current_value < 10)
		unifyShares()

	last_trend = current_trend
	current_trend += rand(-200, 200) / 100 + optimism * rand(200) / 10 + max(50 - abs(speculation), 0) / 50 * rand(0, 200) / 1000 * (-current_trend) + max(speculation - 50, 0) * rand(0, 200) / 1000 * speculation / 400

/datum/stock/proc/unifyShares()
	for (var/I in shareholders)
		var/shr = shareholders[I]
		if (shr % 2)
			sellShares(I, 1)
		shr -= 1
		shareholders[I] /= 2
		if (!shareholders[I])
			shareholders -= I
	for (var/datum/borrow/B in borrow_brokers)
		B.share_amount = round(B.share_amount / 2)
		B.share_debt = round(B.share_debt / 2)
	for (var/datum/borrow/B in borrows)
		B.share_amount = round(B.share_amount / 2)
		B.share_debt = round(B.share_debt / 2)
	average_shares /= 2
	available_shares /= 2
	current_value *= 2
	last_unification = world.time

/datum/stock/proc/buyShares(var/who, var/howmany)
	if (howmany <= 0)
		return
	howmany = round(howmany)
	var/loss = howmany * current_value
	if (available_shares < howmany)
		return 0
	if (modifyAccount(who, -loss))
		supplyDrop(howmany)
		if (!(who in shareholders))
			shareholders[who] = howmany
		else
			shareholders[who] += howmany
		return 1
	return 0

/datum/stock/proc/sellShares(var/whose, var/howmany)
	if (howmany < 0)
		return
	howmany = round(howmany)
	var/gain = howmany * current_value
	if (shareholders[whose] < howmany)
		return 0
	if (modifyAccount(whose, gain))
		supplyGrowth(howmany)
		shareholders[whose] -= howmany
		if (shareholders[whose] <= 0)
			shareholders -= whose
		return 1
	return 0

/datum/stock/proc/displayValues(var/mob/user)
	user << browse(plotBarGraph(values, "[name] share value per share"), "window=stock_[name];size=450x450")
