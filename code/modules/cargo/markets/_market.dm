/datum/market
	/// Name for the market.
	var/name = "huh?"

	/// Available shipping methods and prices, just leave the shipping method out that you don't want to have.
	var/list/shipping

	// Automatic vars, do not touch these.
	/// Items available from this market, populated by SSblackmarket on initialization. Automatically assigned, so don't manually adjust.
	var/list/available_items = list()
	/// Item categories available from this market, only items which are in these categories can be gotten from this market. Automatically assigned, so don't manually adjust.
	var/list/categories = list()

/// Adds item to the available items and add it's category if it is not in categories yet.
/datum/market/proc/add_item(datum/market_item/item)
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
/datum/market/proc/purchase(item, category, method, obj/item/market_uplink/uplink, user)
	if(!istype(uplink) || !(method in shipping))
		return FALSE

	for(var/datum/market_item/I in available_items[category])
		if(I.type != item)
			continue
		var/price = I.price + shipping[method]

		if(!uplink.current_user)///There is no ID card on the user, or the ID card has no account
			to_chat(user, span_warning("The uplink sparks, as it can't identify an ID card with a bank account on you."))
			return FALSE
		var/balance = uplink?.current_user.account_balance

		// I can't get the price of the item and shipping in a clean way to the UI, so I have to do this.
		if(balance < price)
			to_chat(user, span_warning("You don't have enough credits in [uplink] for [I] with [method] shipping."))
			return FALSE

		if(I.buy(uplink, user, method))
			uplink.current_user.adjust_money(-price, "Other: Third Party Transaction")
			if(ismob(user))
				var/mob/m_user = user
				m_user.playsound_local(get_turf(m_user), 'sound/machines/twobeep_high.ogg', 50, TRUE)
			return TRUE
		return FALSE

/datum/market/blackmarket
	name = "Black Market"
	shipping = list(SHIPPING_METHOD_LTSRBT =50,
					SHIPPING_METHOD_LAUNCH =10,
					SHIPPING_METHOD_TELEPORT=75)
