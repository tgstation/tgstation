/datum/market/restock
	market_flags = (MARKET_PROCESS)
	///our current restock timer
	COOLDOWN_DECLARE(restock_timer)
	///how long each restock interval is
	var/restock_interval = 5 MINUTES
	///list of all market_item_types
	var/list/viable_items = list()

/datum/market/restock/try_process()
	if(COOLDOWN_FINISHED(src, restock_timer))
		restock_market()
		COOLDOWN_START(src, restock_timer, restock_interval)


/datum/market/restock/add_item(datum/market_item/item)
	viable_items |= item.type
	. = ..()

/datum/market/restock/proc/restock_market()
	available_items = list()
	categories = list()
	for(var/item in viable_items)
		var/datum/market_item/I = new item()
		if(!I.item)
			continue
		for(var/M in I.markets)
			if(M != type)
				continue
			add_item(I)
		qdel(I)

/datum/market/restock/guns_galore
	name = "Guns Galore"
	shipping = list(SHIPPING_METHOD_AT_FEET=0)
