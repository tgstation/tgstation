#define MAX_BOULDERS_PER_VENT 10

SUBSYSTEM_DEF(stock_market)
	name = "Stock Market"
	wait = 20 SECONDS
	init_order = INIT_ORDER_DEFAULT
	runlevels = RUNLEVEL_GAME

	/// Associated list of materials and their prices at the given time.
	var/list/materials_prices = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/silver,
		/datum/material/uranium,
		/datum/material/titanium,
		/datum/material/gold,
		/datum/material/plasma,
		/datum/material/diamond,
	)

/datum/controller/subsystem/stock_market/Initialize()
	for(var/datum/material/market in materials_prices)
		materials_prices[market] = market.value_per_unit * SHEET_MATERIAL_AMOUNT
	// for(var/datum/material/possible_market in subtypesof(/datum/material)) // I need to make this work like this, but lets hardcode it for now
	// 	to_chat(world, span_boldannounce("[possible_market.name] is [possible_market.tradable]"))
	// 	if(possible_market.tradable)
	// 		materials_prices += possible_market
	// 		materials_prices[possible_market] = (possible_market.value_per_unit * SHEET_MATERIAL_AMOUNT)

/datum/controller/subsystem/stock_market/fire(resumed)
	for(var/datum/material/market in materials_prices)
		var/price_units = materials_prices[market]
		materials_prices[market] = clamp(price_units + gaussian(price_units, 0.1 * price_units), market.value_per_unit * SHEET_MATERIAL_AMOUNT * 0.5, market.value_per_unit * SHEET_MATERIAL_AMOUNT * 1.5)
