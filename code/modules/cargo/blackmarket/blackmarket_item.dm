/datum/blackmarket_item
	var/name
	var/desc
	var/category
	// Used only on SSblackmarket init.
	var/list/markets = list(/datum/blackmarket_market/blackmarket)

	var/price
	var/stock

	var/item

	// Random number between these is set as the price.
	var/price_min	= 0
	var/price_max	= 0
	// Random number between these is set as the stock amount.
	var/stock_min	= 1 // Defaults to one because most items have it as one.
	var/stock_max	= 0
	// Probability for this item to be available.
	var/availability_prob = 0

/datum/blackmarket_item/New()
	if(!price)
		price = rand(price_min, price_max)
	if(!stock)
		stock = rand(stock_min, stock_max)

/datum/blackmarket_item/proc/spawn_item(loc)
	return new item(loc)

/datum/blackmarket_item/proc/buy(obj/item/blackmarket_uplink/uplink, mob/buyer, shipping_method)
	// Sanity
	if(!istype(uplink) || !istype(buyer))
		return FALSE
	
	if(!item)
		to_chat(buyer, "<span class='notice'>How did you even manage to do this there is no item, please ahelp an admin about how you did this.</span>")
		return

	if(stock <= 0)
		to_chat(buyer, "<span class='warning'>This is not in stock right now.</span>")
		return
	
	if(uplink.money < price)
		to_chat(buyer, "<span class='warning'>You don't have enough money in the uplink for that.</span>")
		return FALSE
	
	// Alright, the item has been purchased.
	stock--
	uplink.money -= price
	
	var/datum/blackmarket_purchase/purchase = new(src, uplink, shipping_method)

	// SSblackmarket takes care of the shipping.
	SSblackmarket.queued_purchases += purchase
	return TRUE

// This only exists because I don't want to make a list for the values.
/datum/blackmarket_purchase
	var/datum/blackmarket_item/entry
	var/item
	var/obj/item/blackmarket_uplink/uplink
	var/method

/datum/blackmarket_purchase/New(_entry, _uplink, _method)
	entry = _entry
	uplink = _uplink
	method = _method
