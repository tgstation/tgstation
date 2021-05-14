/datum/blackmarket_market
	/// Name for the market.
	var/name = "huh?"

	/// Available shipping methods and prices, just leave the shipping method out that you don't want to have.
	var/list/shipping

	/// Amount of time before the market is repopulated
	var/time_left = 0

	/// Amount of time that time_left is set to after market is repopulated
	var/max_time_left = 0

	// Automatic vars, do not touch these.
	/// Items available from this market, populated by SSblackmarket on initialization.
	var/list/available_items = list()
	/// Item categories available from this market, only items which are in these categories can be gotten from this market.
	var/list/categories = list()

/datum/blackmarket_market/New()
	. = ..()
	if(max_time_left)
		START_PROCESSING(SSprocessing,src)

/datum/blackmarket_market/Destroy(force, ...)
	if(max_time_left)
		STOP_PROCESSING(SSprocessing,src)
	return ..()

/datum/blackmarket_market/process(delta_time)
	time_left -= delta_time
	if(time_left <= 0)
		time_left = max_time_left
		SSblackmarket.repopulate_market(type)

/// Adds item to the available items and add it's category if it is not in categories yet.
/datum/blackmarket_market/proc/add_item(datum/blackmarket_item/item)
	if(!prob(initial(item.availability_prob)))
		return FALSE

	if(ispath(item))
		item = new item()

	if(!(item.category in categories))
		categories += item.category
		available_items[item.category] = list()

	available_items[item.category] += item
	return TRUE

/// Handles buying the item, this is mainly for future use and moving the code away from the uplink.
/datum/blackmarket_market/proc/purchase(item, category, method, obj/item/blackmarket_uplink/uplink, user)
	if(!istype(uplink) || !(method in shipping))
		return FALSE

	for(var/datum/blackmarket_item/I in available_items[category])
		if(I.type != item)
			continue
		var/price = I.price + shipping[method]
		// I can't get the price of the item and shipping in a clean way to the UI, so I have to do this.
		if(uplink.money < price)
			to_chat("<span class='warning'>You don't have enough credits in [uplink] for [I] with [method] shipping.</span>")
			return FALSE

		if(I.buy(uplink, user, method))
			uplink.money -= price
			return TRUE
		return FALSE

/datum/blackmarket_market/blackmarket
	name = "Black Market"
	shipping = list(SHIPPING_METHOD_LTSRBT =50,
					SHIPPING_METHOD_LAUNCH =10,
					SHIPPING_METHOD_TELEPORT=75)

/datum/blackmarket_market/cybernetics
	name = "Monorail Cybernetics Auction"
	shipping = list(SHIPPING_METHOD_LTSRBT	=100,
					SHIPPING_METHOD_LAUNCH	=20,
					SHIPPING_METHOD_TELEPORT=150)
	max_time_left = 3 MINUTES



