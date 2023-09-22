
SUBSYSTEM_DEF(stock_market)
	name = "Stock Market"
	wait = 20 SECONDS
	init_order = INIT_ORDER_DEFAULT
	runlevels = RUNLEVEL_GAME

	/// Associated list of materials and their prices at the given time.
	var/list/materials_prices = list()
	/// Associated list of materials alongside their market trends. 1 is up, 0 is stable, -1 is down.
	var/list/materials_trends = list()
	/// Associated list of materials alongside the life of it's current trend. After it's life is up, it will change to a new trend.
	var/list/materials_trend_life = list()
	/// Associated list of materials alongside their available quantity. This is used to determine how much of a material is available to buy, and how much buying and selling affects the price.
	var/list/materials_quantity = list()
	/// HTML string that is used to display the market events to the player.
	var/news_string = ""

/datum/controller/subsystem/stock_market/Initialize()
	for(var/datum/material/possible_market as anything in subtypesof(/datum/material)) // I need to make this work like this, but lets hardcode it for now
		if(initial(possible_market.tradable))
			materials_prices += possible_market
			materials_prices[possible_market] = initial(possible_market.value_per_unit) * SHEET_MATERIAL_AMOUNT

			materials_trends += possible_market
			materials_trends[possible_market] = rand(MARKET_TREND_DOWNWARD,MARKET_TREND_UPWARD) //aka -1 to 1

			materials_trend_life += possible_market
			materials_trend_life[possible_market] = rand(1,10)

			materials_quantity += possible_market
			materials_quantity[possible_market] = initial(possible_market.tradable_base_quantity) + (rand(-initial(possible_market.tradable_base_quantity) * 0.5, initial(possible_market.tradable_base_quantity) * 0.5))
	return SS_INIT_SUCCESS
/datum/controller/subsystem/stock_market/fire(resumed)
	for(var/datum/material/market as anything in materials_prices)
		handle_trends_and_price(market)

/**
 * Handles shifts in the cost of materials, and in what direction the material is most likely to move.
 */
/datum/controller/subsystem/stock_market/proc/handle_trends_and_price(datum/material/mat)
	if(prob(MARKET_EVENT_PROBABILITY))
		handle_market_event(mat)
		return
	var/trend = materials_trends[mat]
	var/trend_life = materials_trend_life[mat]

	var/price_units = materials_prices[mat]
	var/price_minimum = round(initial(mat.value_per_unit) * SHEET_MATERIAL_AMOUNT * 0.5)
	if(!isnull(initial(mat.minimum_value_override)))
		price_minimum = round(initial(mat.minimum_value_override) * SHEET_MATERIAL_AMOUNT)
	var/price_maximum = round(initial(mat.value_per_unit) * SHEET_MATERIAL_AMOUNT * 3)
	var/price_baseline = initial(mat.value_per_unit) * SHEET_MATERIAL_AMOUNT

	var/stock_quantity = materials_quantity[mat]

	if(HAS_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING)) //We hardset to the worst possible price and lowest possible impact if sold
		materials_prices[mat] =  price_minimum
		materials_quantity[mat] = stock_quantity * 2
		materials_trends[mat] = MARKET_TREND_DOWNWARD
		trend_life = materials_trend_life[mat] = 1
		return

	if(trend_life == 0)
		///We want to scale our trend so that if we're closer to our minimum or maximum price, we're more likely to trend the other way.
		if((price_units < price_baseline))
			var/chance_swap = 100 - ((clamp((price_units - price_minimum), 1, 1000) / (price_baseline - price_minimum))*100)
			if(prob(chance_swap))
				materials_trends[mat] = MARKET_TREND_UPWARD
			else
				materials_trends[mat] = MARKET_TREND_STABLE
		else if((price_units > price_baseline))
			var/chance_swap = 100 - ((clamp((price_units - price_maximum), 1, 1000) / (price_maximum - price_baseline))*100)
			if(prob(chance_swap))
				materials_trends[mat] = MARKET_TREND_DOWNWARD
			else
				materials_trends[mat] = MARKET_TREND_STABLE
		materials_trend_life[mat] = rand(3,10) // Change our trend life for x number of cycles
	else
		materials_trend_life[mat] -= 1

	var/price_change = 0
	var/quantity_change = 0
	switch(trend)
		if(MARKET_TREND_UPWARD)
			price_change = ROUND_UP(gaussian(price_units * 0.1, price_baseline * 0.05)) //If we don't ceil, small numbers will get trapped at low values
			quantity_change = -round(gaussian(stock_quantity * 0.1, stock_quantity * 0.05))
		if(MARKET_TREND_STABLE)
			price_change = round(gaussian(0, price_baseline * 0.01))
			quantity_change = round(gaussian(0, stock_quantity * 0.01))
		if(MARKET_TREND_DOWNWARD)
			price_change = -ROUND_UP(gaussian(price_units * 0.1, price_baseline * 0.05))
			quantity_change = round(gaussian(stock_quantity * 0.1, stock_quantity * 0.05))
	materials_prices[mat] =  round(clamp(price_units + price_change, price_minimum, price_maximum))
	materials_quantity[mat] = round(clamp(stock_quantity + quantity_change, 0, initial(mat.tradable_base_quantity) * 2))

/**
 * Market events are a way to spice up the market and make it more interesting.
 * Randomly one will occur to a random material, and it will change the price of that material more drastically, or reset it to a stable price.
 * Events are also broadcast to the newscaster as a fun little fluff piece. Good way to tell some lore as well, or just make a joke.
 */
/datum/controller/subsystem/stock_market/proc/handle_market_event(datum/material/mat)

	var/company_name = list( // Pick a random company name from the list, I let copilot make a few up for me which is why some suck
		"Nakamura Engineering",
		"Robust Industries, LLC",
		"MODular Solutions",
		"SolGov",
		"Australicus Industrial Mining",
		"Vey-Medical",
		"Aussec Armory",
		"Dreamland Robotics"
	)
	var/circumstance
	var/event = rand(1,3)

	var/price_units = materials_prices[mat]
	var/price_minimum = round(initial(mat.value_per_unit) * SHEET_MATERIAL_AMOUNT * 0.5)
	if(!isnull(initial(mat.minimum_value_override)))
		price_minimum = round(initial(mat.minimum_value_override) * SHEET_MATERIAL_AMOUNT)
	var/price_maximum = round(initial(mat.value_per_unit) * SHEET_MATERIAL_AMOUNT * 3)
	var/price_baseline = initial(mat.value_per_unit) * SHEET_MATERIAL_AMOUNT

	switch(event)
		if(1) //Reset to stable
			materials_prices[mat] = price_baseline
			materials_trends[mat] = MARKET_TREND_STABLE
			materials_trend_life[mat] = 1
			circumstance = pick(list(
				"[pick(company_name)] has been bought out by a private investment firm. As a result, <b>[initial(mat.name)]</b> is now stable at <b>[materials_prices[mat]] cr</b>.",
				"Due to a corporate restructuring, the largest supplier of <b>[initial(mat.name)]</b> has had the price changed to <b>[materials_prices[mat]] cr</b>.",
				"<b>[initial(mat.name)]</b> is now under a monopoly by [pick(company_name)]. The price has been changed to <b>[materials_prices[mat]] cr</b> accordingly."
			))
		if(2) //Big boost
			materials_prices[mat] += round(gaussian(price_units * 0.5, price_units * 0.1))
			materials_prices[mat] = clamp(materials_prices[mat], price_minimum, price_maximum)
			materials_trends[mat] = MARKET_TREND_UPWARD
			materials_trend_life[mat] = rand(1,5)
			circumstance = pick(list(
				"[pick(company_name)] has just released a new product that uses <b>[initial(mat.name)]</b>! As a result, the price has been raised to <b>[materials_prices[mat]] cr</b>.",
				"Due to [pick(company_name)] finding a new property of <b>[initial(mat.name)]</b>, its price has been raised to <b>[materials_prices[mat]] cr</b>.",
				"A study has found that <b>[initial(mat.name)]</b> may run out within the next 100 years. The price has raised to <b>[materials_prices[mat]] cr</b> due to panic."
			))
		if(3) //Big drop
			materials_prices[mat] -= round(gaussian(price_units * 1.5, price_units * 0.1))
			materials_prices[mat] = clamp(materials_prices[mat], price_minimum, price_maximum)
			materials_trends[mat] = MARKET_TREND_DOWNWARD
			materials_trend_life[mat] = rand(1,5)
			circumstance = pick(list(
				"[pick(company_name)]'s latest product has seen major controversy, and as a result, the price of <b>[initial(mat.name)]</b> has dropped to <b>[materials_prices[mat]] cr</b>.",
				"Due to a new competitor, the price of <b>[initial(mat.name)]</b> has dropped to <b>[materials_prices[mat]] cr</b>.",
				"<b>[initial(mat.name)]</b> has been found to be a carcinogen. The price has dropped to <b>[materials_prices[mat]] cr</b> due to panic."
			))
	news_string += circumstance + "<br>" // Add the event to the news_string, formatted for newscasters.
