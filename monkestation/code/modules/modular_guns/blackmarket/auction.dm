#define AUCTION_TIME 3 MINUTES

/datum/market/auction
	name = "Black Market Auction"
	market_flags = (MARKET_PROCESS | MARKET_AUCTION)
	categories = list("Auction")
	///list of all items and when they start in world time
	var/list/queued_items = list()
	///how many items we have in a queue at once
	var/queue_length = 3
	///our current auction
	var/datum/market_item/auction/current_auction
	///how much time is left of our auction checked with COOLDOWN_TIME_LEFT
	COOLDOWN_DECLARE(current_auction_time)

/datum/market/auction/add_item(datum/market_item/auction/item)
	if(!prob(initial(item.availability_prob)))
		return FALSE

	if(ispath(item))
		item = new item()

	if(!istype(item))
		return FALSE

	if(!length(available_items))
		available_items = list()
		categories |= "Auction"

	available_items += item
	available_items[item] = item.auction_weight
	return TRUE

/datum/market/auction/try_process()
	if(!length(queued_items))
		var/datum/market_item/auction/first_item = pick_weight(available_items)
		var/datum/market_item/auction/created_item = new first_item.type
		queued_items += created_item
		queued_items[created_item] = world.time + rand(1.5 MINUTES, 3 MINUTES) + AUCTION_TIME

	if(length(queued_items) < queue_length) // we are missing a new auction
		var/datum/market_item/auction/listed_item = pick_weight(available_items)
		var/datum/market_item/auction/new_item = new listed_item.type
		var/initial_time = queued_items[queued_items[length(queued_items)]]
		queued_items += new_item
		queued_items[new_item] = initial_time + rand(1.5 MINUTES, 3 MINUTES) + AUCTION_TIME

	if(COOLDOWN_FINISHED(src, current_auction_time) && current_auction)
		grab_purchase_info(current_auction, current_auction.category, SHIPPING_METHOD_AT_FEET)
		current_auction = null

	if(world.time >= queued_items[queued_items[1]])
		current_auction = queued_items[1]
		queued_items[queued_items[1]] = 0
		queued_items -= current_auction
		COOLDOWN_START(src, current_auction_time, AUCTION_TIME)


/datum/market/auction/proc/reroll(obj/item/market_uplink/uplink, user)
	var/balance = uplink?.current_user.account_balance
	if(balance < 350)
		to_chat(user, span_warning("You don't have enough credits in [uplink] to reroll the auction block."))
		return FALSE
	uplink.current_user.adjust_money(-350, "Other: Third Party Transaction")
	queued_items = list()
	logger.Log(LOG_CATEGORY_BLACKMARKET, "[user] has rerolled the [name]")

/datum/market/auction/pre_purchase(item, category, method, obj/item/market_uplink/uplink, user, bid_amount)
	if(item != current_auction.type)
		return FALSE

	if(current_auction.user == user)
		to_chat(user, span_warning("You are currently the top bidder on [current_auction] already!"))
		return FALSE

	var/price = current_auction.price

	if(price >= bid_amount)
		to_chat(user, span_warning("You need to bid more than the current bid amount!"))
		return FALSE

	if(!uplink.current_user)///There is no ID card on the user, or the ID card has no account
		to_chat(user, span_warning("The uplink sparks, as it can't identify an ID card with a bank account on you."))
		return FALSE
	var/balance = uplink?.current_user.account_balance

	// I can't get the price of the item and shipping in a clean way to the UI, so I have to do this.
	if(balance < bid_amount)
		to_chat(user, span_warning("You don't have enough credits in [uplink] to bid on [current_auction]."))
		return FALSE

	if(current_auction.user)
		var/old_bidder = "Anonymous Creature"
		if(ishuman(current_auction.user))
			var/mob/living/carbon/human/human = current_auction.user
			old_bidder = "Anonymous [human.dna.species.name]"
		current_auction.bidders += list(list(
			"name" = old_bidder,
			"amount" = current_auction.current_price,
		))

	logger.Log(LOG_CATEGORY_BLACKMARKET, "[user] has just bid [bid_amount] on [current_auction.item] in the [name]")
	current_auction.uplink = uplink
	current_auction.user = user
	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		current_auction.top_bidder = "Anonymous [human.dna.species.name]"
	else
		current_auction.top_bidder = "Anonymous Creature"
	current_auction.current_price = bid_amount
	current_auction.price = bid_amount


/// Handles buying the item, this is mainly for future use and moving the code away from the uplink.
/datum/market/auction/purchase(item, category, method, obj/item/market_uplink/uplink, user)
	if(!istype(uplink))
		return FALSE

	for(var/datum/market_item/I in available_items)
		if(I.type != item)
			continue
		var/price = I.price

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
			logger.Log(LOG_CATEGORY_BLACKMARKET, "[user] has just bought the [current_auction.item] for [price] in the [name]")
			if(ismob(user))
				var/mob/m_user = user
				m_user.playsound_local(get_turf(m_user), 'sound/machines/twobeep_high.ogg', 50, TRUE)
			return TRUE
		return FALSE


/datum/market/auction/proc/grab_purchase_info(datum/market_item/auction/item, category, method)
	purchase(item.type, category, method, item.uplink, item.user)
	if(item.user)
		message_admins("[item.user] has won the auction for [item]")


/datum/market/auction/guns
	name = "Back Alley Guns"

/datum/market_item/auction
	uses_stock = FALSE
	markets = list(/datum/market/auction)
	///the user whos currently bid on it
	var/mob/user
	///the current price we have
	var/current_price = 0
	///the highest bidding uplink
	var/obj/item/market_uplink/uplink
	///list of mob names with prices used to show previous prices
	var/list/bidders = list()
	///the name of our top bidder as a string
	var/top_bidder
	///the weight this item has to appear high = more likely to be picked
	var/auction_weight = 10
