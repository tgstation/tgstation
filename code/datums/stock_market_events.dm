/datum/stock_market_event
	/// The name of the event, used to describe it in the news.
	var/name = "Stock Market Event!"
	/// A list of company names to use for the event and the circumstance.
	var/static/list/company_name = list(
		"Nakamura Engineering",
		"Robust Industries, LLC",
		"MODular Solutions",
		"SolGov",
		"Australicus Industrial Mining",
		"Vey-Medical",
		"Aussec Armory",
		"Dreamland Robotics"
	)
	/// A list of strings selected from the event that's used to describe the event in the news.
	var/list/circumstance = list()
	/// What material is affected by the event?
	var/datum/material/mat
	/// Constant to multiply the original material value by to get the new minimum value, unless the material has a minimum override.
	var/price_minimum = SHEET_MATERIAL_AMOUNT * 0.5
	/// Constant to multiply the original material value by to get the new maximum value.
	var/price_maximum = SHEET_MATERIAL_AMOUNT * 3

	/// When this event is ongoing, what direction will the price trend in?
	var/trend_value
	/// When this event is triggered, for how long will its effects last?
	var/trend_duration

/**
 * When a new stock_market_event is created, this proc is called to set up the event if there's anything that needs to happen upon it starting.
 * @param _mat The material that this event will affect.
 */
/datum/stock_market_event/proc/start_event(datum/material/mat)
	if(istype(mat, /datum/material))
		return FALSE
	src.mat = mat
	if(!isnull(trend_value))
		SSstock_market.materials_trends[mat] =	trend_value
		if(!isnull(trend_duration))
			SSstock_market.materials_trend_life[mat] = trend_duration
	return TRUE

/**
 * This proc is called every tick while the event is ongoing by SSstock_market.
 */
/datum/stock_market_event/proc/handle()
	trend_duration--
	if(trend_duration <= 0)
		end_event()
	return

/**
 * When a stock_market_event is ended, this proc is called to apply any final effects and clean up anything that needs to be cleaned up.
 */
/datum/stock_market_event/proc/end_event()
	SSstock_market.active_events -= src
	qdel(src)

/**
 * This proc is called to create a news string for the event, which is passed along to SSstock_market to be appended to the automatic newscaster messages.
 */
/datum/stock_market_event/proc/create_news()
	var/temp_company = pick(company_name)
	var/temp_circumstance = pick(circumstance)
	SSstock_market.news_string += "<b>[name] [temp_company]</b> [temp_circumstance]<b>[mat.name].</b><br>"


/datum/stock_market_event/market_reset
	name = "Market Reset!"
	trend_value = MARKET_TREND_STABLE
	trend_duration = 1
	circumstance = list(
		"was purchased by a private investment firm, resetting the price of ",
		"restructured, resetting the price of ",
		"has been rolled into a larger company, resetting the price of ",
	)

/datum/stock_market_event/market_reset/start_event()
	. = ..()
	SSstock_market.materials_prices[mat] = (initial(mat.value_per_unit)) * SHEET_MATERIAL_AMOUNT
	create_news()

/datum/stock_market_event/large_boost
	name = "Large Boost!"
	trend_value = MARKET_TREND_UPWARD
	trend_duration = 4
	circumstance = list(
		"has just released a new product that raised the price of ",
		"discovered a new valuable use for ",
		"has produced a report that raised the price of ",
	)

/datum/stock_market_event/large_boost/start_event()
	. = ..()
	var/price_units = SSstock_market.materials_prices[mat]
	SSstock_market.materials_prices[mat] += round(gaussian(price_units, price_units * 0.15))
	SSstock_market.materials_prices[mat] = clamp(SSstock_market.materials_prices[mat], price_minimum * mat.value_per_unit, price_maximum * mat.value_per_unit)
	create_news()

/datum/stock_market_event/large_drop
	name = "Large Drop!"
	trend_value = MARKET_TREND_DOWNWARD
	trend_duration = 4
	circumstance = list(
		"'s latest product has seen major controversy, and resulted in a price drop for ",
		"has been hit with a major lawsuit, resulting in a price drop for ",
		"has produced a report that lowered the price of ",
	)

/datum/stock_market_event/large_drop/start_event()
	. = ..()
	var/price_units = SSstock_market.materials_prices[mat]
	SSstock_market.materials_prices[mat] -= round(gaussian(price_units * 1.5, price_units * 0.15))
	SSstock_market.materials_prices[mat] = clamp(SSstock_market.materials_prices[mat], price_minimum * mat.value_per_unit, price_maximum * mat.value_per_unit)
	create_news()

/datum/stock_market_event/hotcakes
	name = "Selling like Hotcakes!"
	trend_value = MARKET_TREND_UPWARD
	trend_duration = 1
	circumstance = list(
		"has just released a new product that is dominating the market for  ",
		"is hitting it big! Dramatically stocking and raising the price of ",
		", in a surprise move, monopolized supply and has raised the price of ",
	)

/datum/stock_market_event/hotcakes/start_event()
	. = ..()
	SSstock_market.materials_prices[mat] = round(price_maximum * mat.value_per_unit)
	create_news()

/datum/stock_market_event/lockdown
	name = "Lockdown!"
	trend_value = MARKET_TREND_DOWNWARD
	trend_duration = 2
	circumstance = list(
		"is being investigated by the Galactic Trade Commission, resulting in a halt of trade for ",
		", in a stunning move, has been embargoed by TerraGov, resulting in a halt of trade of ",
	)

/datum/stock_market_event/lockdown/handle()
	. = ..()
	SSstock_market.materials_quantity[mat] = 0 //Force the material to be unavailable.

/datum/stock_market_event/lockdown/end_event()
	. = ..()
	SSstock_market.materials_quantity[mat] = initial(mat.tradable_base_quantity) //Force the material to be available again.
	SSstock_market.materials_prices[mat] = initial(mat.value_per_unit) * SHEET_MATERIAL_AMOUNT //Force the price to be reset once the lockdown is over.
	create_news()


