///A special category for goods placed on the market by station by someone with the LTSRBT.
/datum/market_item/local_good
	category = "Local Goods"
	abstract_path = /datum/market_item/local_good
	stock = 1
	availability_prob = 100
	restockable = FALSE
	var/datum/bank_account/seller

/datum/market_item/local_good/New(atom/movable/thing, datum/bank_account/seller)
	..()
	set_item(thing)
	src.seller = seller
	if(seller)
		RegisterSignal(seller, COMSIG_QDELETING, PROC_REF(delete_reference))

/datum/market_item/local_good/buy(obj/item/market_uplink/uplink, mob/buyer, shipping_method, legal_status)
	. = ..()
	if(. && seller)
		seller.adjust_money(round(price * (1 - MARKET_WITHHOLDING_TAX)), "Market: Item Sold")
	QDEL_IN(src, 10 MINUTES) //This category cannot hold more than 40 items at a time, so we need to clear sold items.

/datum/market_item/local_good/proc/delete_reference(datum/source)
	SIGNAL_HANDLER
	seller = null
