
SUBSYSTEM_DEF(stock_market)
	name = "Stock Market"
	wait = 60 SECONDS
	init_order = INIT_ORDER_DEFAULT
	runlevels = RUNLEVEL_GAME

	/// Associated list of materials and their prices at the given time.
	var/list/materials_prices = list()
	/// Associated list of materials alongside their market trends. 1 is up, 0 is stable, -1 is down.
	var/list/materials_trends = list()
	/// Associated list of materials alongside the life of its current trend. After its life is up, it will change to a new trend.
	var/list/materials_trend_life = list()
	/// Associated list of materials alongside their available quantity. This is used to determine how much of a material is available to buy, and how much buying and selling affects the price.
	var/list/materials_quantity = list()
	/// A list of all currently active stock market events.
	var/list/active_events = list()
	/// HTML string that is used to display the market events to the player.
	var/news_string = ""

/datum/controller/subsystem/stock_market/Initialize()
	for(var/datum/material/possible_market as anything in subtypesof(/datum/material)) // I need to make this work like this, but lets hardcode it for now
		if(possible_market.tradable)
			materials_prices += possible_market
			materials_prices[possible_market] = possible_market.value_per_unit * SHEET_MATERIAL_AMOUNT

			materials_trends += possible_market
			materials_trends[possible_market] = rand(MARKET_TREND_DOWNWARD,MARKET_TREND_UPWARD) //aka -1 to 1

			materials_trend_life += possible_market
			materials_trend_life[possible_market] = rand(1,3)

			materials_quantity += possible_market
			materials_quantity[possible_market] = possible_market.tradable_base_quantity + (rand(-(possible_market.tradable_base_quantity) * 0.5, possible_market.tradable_base_quantity * 0.5))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/stock_market/fire(resumed)
	for(var/datum/material/market as anything in materials_prices)
		handle_trends_and_price(market)
	for(var/datum/stock_market_event/event as anything in active_events)
		event.handle()

///Adjust the price of a material(either through buying or selling) ensuring it stays within limits
/datum/controller/subsystem/stock_market/proc/adjust_material_price(datum/material/mat, delta)
	mat = GET_MATERIAL_REF(mat)

	//adjust the price
	var/new_price = materials_prices[mat.type] + delta

	//get the limits
	var/price_minimum = round(mat.value_per_unit * SHEET_MATERIAL_AMOUNT * 0.5)
	if(!isnull(mat.minimum_value_override))
		price_minimum = round(mat.minimum_value_override * SHEET_MATERIAL_AMOUNT)
	var/price_maximum = round(mat.value_per_unit * SHEET_MATERIAL_AMOUNT * 3)

	//clamp it down
	new_price = round(clamp(new_price, price_minimum, price_maximum))
	materials_prices[mat.type] = new_price

///Adjust the amount of material(either through buying or selling) ensuring it stays within limits
/datum/controller/subsystem/stock_market/proc/adjust_material_quantity(datum/material/mat, delta)
	mat = GET_MATERIAL_REF(mat)

	//adjust the quantity
	var/new_quantity = materials_quantity[mat.type] + delta

	//get the upper limit
	var/quantity_baseline = mat.tradable_base_quantity

	//clamp it down
	new_quantity = round(clamp(new_quantity, 0, quantity_baseline * 2))
	materials_quantity[mat.type] = new_quantity

/**
 * Handles shifts in the cost of materials, and in what direction the material is most likely to move.
 */
/datum/controller/subsystem/stock_market/proc/handle_trends_and_price(datum/material/mat)
	if(prob(MARKET_EVENT_PROBABILITY))
		handle_market_event(mat)
	var/trend = materials_trends[mat]
	var/trend_life = materials_trend_life[mat]

	var/price_units = materials_prices[mat]
	var/price_minimum = round(mat.value_per_unit * SHEET_MATERIAL_AMOUNT * 0.5)
	if(!isnull(mat.minimum_value_override))
		price_minimum = round(mat.minimum_value_override * SHEET_MATERIAL_AMOUNT)
	var/price_maximum = round(mat.value_per_unit * SHEET_MATERIAL_AMOUNT * 3)
	var/price_baseline = mat.value_per_unit * SHEET_MATERIAL_AMOUNT
	var/quantity_baseline = mat.tradable_base_quantity

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
		materials_trend_life[mat] = rand(1,3) // Change our trend life for x number of fires of the subsystem
	else
		materials_trend_life[mat] -= 1

	var/price_change = 0
	var/quantity_change = 0
	switch(trend)
		if(MARKET_TREND_UPWARD)
			price_change = ROUND_UP(gaussian(price_units * 0.30, price_baseline * 0.15)) //If we don't ceil, small numbers will get trapped at low values
			quantity_change = -round(gaussian(quantity_baseline * 0.15, quantity_baseline * 0.15))
		if(MARKET_TREND_STABLE)
			price_change = round(gaussian(0, price_baseline * 0.01))
			quantity_change = round(gaussian(0, quantity_baseline * 0.5))
		if(MARKET_TREND_DOWNWARD)
			price_change = -ROUND_UP(gaussian(price_units * 0.3, price_baseline * 0.15))
			quantity_change = round(gaussian(quantity_baseline * 0.15, quantity_baseline * 0.15))
	materials_prices[mat] =  round(clamp(price_units + price_change, price_minimum, price_maximum))
	materials_quantity[mat] = round(clamp(stock_quantity + quantity_change, 0, quantity_baseline * 2))

/**
 * Market events are a way to spice up the market and make it more interesting.
 * Randomly one will occur to a random material, and it will change the price of that material more drastically, or reset it to a stable price.
 * Events are also broadcast to the newscaster as a fun little fluff piece. Good way to tell some lore as well, or just make a joke.
 */
/datum/controller/subsystem/stock_market/proc/handle_market_event(datum/material/mat)
	var/datum/stock_market_event/event = pick(subtypesof(/datum/stock_market_event))
	event = new event
	if(event.start_event(mat))
		active_events += event
