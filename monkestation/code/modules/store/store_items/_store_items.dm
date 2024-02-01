/datum/store_item
	///the displayed name of this item in the shop
	var/name
	///the category of the item
	var/category
	///the path of the item
	var/atom/item_path
	///the cost of the item
	var/item_cost = 1000
	///hidden from general store
	var/hidden = FALSE
	///is this a one time purchase for a roundstart?
	var/one_time_buy = FALSE
	///the description shown in the store if we show descriptions
	var/store_desc = ""


/datum/store_item/proc/attempt_purchase(client/buyer)
	var/datum/preferences/buyers_preferences = buyer.prefs

	if(item_path in buyers_preferences.inventory)
		return FALSE

	if(!buyers_preferences.has_coins(item_cost))
		to_chat(buyer, span_warning("You don't have the funds to buy the [name]"))
		return FALSE
	buyers_preferences.adjust_metacoins(buyer.ckey, -item_cost, donator_multipler = FALSE)

	logger.Log(LOG_CATEGORY_META, "[buyer] bought a [name] for [item_cost]", list("currency_left" = buyer.prefs.metacoins))
	if(!one_time_buy)
		finalize_purchase(buyer)
		return
	attempt_spawn(buyer)


/datum/store_item/proc/finalize_purchase(client/buyer)
	SHOULD_CALL_PARENT(TRUE)
	var/fail_message ="<span class='warning'>Failed to add purchase to database. You have not been charged.</span>"
	if(!SSdbcore.IsConnected())
		to_chat(buyer, fail_message)
		return FALSE
	if(!buyer?.prefs)
		return FALSE
	if(!buyer.prefs.inventory[item_path])
		buyer.prefs.inventory += item_path
		var/datum/db_query/query_add_gear_purchase = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("metacoin_item_purchases")] (`ckey`, `item_id`, `amount`) VALUES (:ckey, :item_id, :amount)"},
			list("ckey" = buyer.ckey, "item_id" = item_path, "amount" = 1))
		if(!query_add_gear_purchase.Execute())
			to_chat(buyer, fail_message)
			qdel(query_add_gear_purchase)
			return FALSE
		qdel(query_add_gear_purchase)
	else
		buyer.prefs.inventory += item_path
		var/datum/db_query/query_add_gear_purchase = SSdbcore.NewQuery({"
			UPDATE [format_table_name("metacoin_item_purchases")] SET amount = :amount WHERE ckey = :ckey AND item_id = :item_id"},
			list("ckey" = buyer.ckey, "item_id" = item_path, "amount" = 1))
		if(!query_add_gear_purchase.Execute())
			to_chat(buyer, fail_message)
			qdel(query_add_gear_purchase)
			return FALSE
		qdel(query_add_gear_purchase)

	return TRUE

/datum/store_item/proc/attempt_spawn(client/buyer)
	var/mob/buyer_mob = get_mob_by_ckey(buyer.ckey)

	if(!isliving(buyer_mob))
		buyer.prefs.adjust_metacoins(buyer.ckey, item_cost, "Spawned as Non-Living, Unable to utilize items", TRUE, FALSE)
		return

	var/obj/item/created_item = new item_path

	return created_item
