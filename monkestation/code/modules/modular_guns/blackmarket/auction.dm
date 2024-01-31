/datum/market/blackmarket/auction
	name = "Black Market Auction"
	market_flags = MARKET_AUCTION


/datum/market/blackmarket/auction/pre_purchase(item, category, method, obj/item/market_uplink/uplink, user)
	for(var/datum/market_item/auction/I in available_items[category])
		if(I.type != item)
			continue

		if(I.user == user)
			to_chat(user, span_warning("You are currently the top bidder on [I] already!"))
			return FALSE

		var/price = I.price + shipping[method]

		if(!uplink.current_user)///There is no ID card on the user, or the ID card has no account
			to_chat(user, span_warning("The uplink sparks, as it can't identify an ID card with a bank account on you."))
			return FALSE
		var/balance = uplink?.current_user.account_balance

		// I can't get the price of the item and shipping in a clean way to the UI, so I have to do this.
		if(balance < price)
			to_chat(user, span_warning("You don't have enough credits in [uplink] to bid on [I]."))
			return FALSE

		if(!I.timer_id)
			I.timer_id = addtimer(CALLBACK(src, PROC_REF(grab_purchase_info), I, category, method), 3 MINUTES, TIMER_UNIQUE | TIMER_STOPPABLE)

		I.uplink = uplink
		I.user = user
		I.current_price = price
		I.price = price


/datum/market/blackmarket/auction/proc/grab_purchase_info(datum/market_item/auction/item, category, method)
	purchase(item.type, category, method, item.uplink, item.user)


/datum/market/blackmarket/auction/guns
	name = "Back Alley Guns"

/datum/market_item/auction
	markets = list(/datum/market/blackmarket/auction)
	///if we have this someone started the auction
	var/timer_id
	///the user whos currently bid on it
	var/mob/user
	///the current price we have
	var/current_price = 0
	///the highest bidding uplink
	var/obj/item/market_uplink/uplink

