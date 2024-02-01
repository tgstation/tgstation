#define DONATOR_ROUNDEND_BONUS 25 //25 monkecoin for donators

/datum/preferences/proc/load_inventory(ckey)
	if(!ckey || !SSdbcore.IsConnected())
		return
	var/datum/db_query/query_gear = SSdbcore.NewQuery(
		"SELECT item_id,amount FROM [format_table_name("metacoin_item_purchases")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	if(!query_gear.Execute())
		qdel(query_gear)
		return
	while(query_gear.NextRow())
		var/key = query_gear.item[1]
		inventory += text2path(key)
	qdel(query_gear)


/datum/preferences/proc/load_metacoins(ckey)
	if(!ckey || !SSdbcore.IsConnected())
		metacoins = 5000
		return
	var/datum/db_query/query_get_metacoins = SSdbcore.NewQuery("SELECT metacoins FROM [format_table_name("player")] WHERE ckey = '[ckey]'")
	var/mc_count = 0
	if(query_get_metacoins.warn_execute())
		if(query_get_metacoins.NextRow())
			mc_count = query_get_metacoins.item[1]

	qdel(query_get_metacoins)
	metacoins = text2num(mc_count)


/datum/preferences/proc/adjust_metacoins(ckey, amount, reason = null, announces = TRUE, donator_multipler = TRUE, respects_roundcap = FALSE)
	if(!ckey || !SSdbcore.IsConnected())
		return FALSE

	//RoundCap Checks
	if(!max_round_coins && respects_roundcap)
		to_chat(parent, "You've hit the Monkecoin limit for this shift, please try again next shift.")
		return
	if(respects_roundcap)
		if(max_round_coins <= amount)
			amount = max_round_coins
		max_round_coins -= amount

	//Patreon Flat Roundend Bonus
	if((parent.patreon?.has_access(2)) && donator_multipler)
		amount += DONATOR_ROUNDEND_BONUS

	//Twitch Flat Roundend Bonus
	if((parent.twitch?.has_access(1)) && donator_multipler)
		amount += DONATOR_ROUNDEND_BONUS

	//Donator Multiplier
	if(amount > 0 && donator_multipler)
		switch(parent.patreon.access_rank)
			if(ACCESS_COMMAND_RANK)
				amount *= 1.5
			if(ACCESS_TRAITOR_RANK)
				amount *= 2
			if(ACCESS_NUKIE_RANK)
				amount *= 3

	amount = round(amount, 1) //make sure whole number
	metacoins += amount //store the updated metacoins in a variable, but not the actual game-to-game storage mechanism (load_metacoins() pulls from database)

	logger.Log(LOG_CATEGORY_META, "[parent]'s monkecoins were changed by [amount] Reason: [reason]", list("currency_left" = metacoins, "reason" = reason))

	//SQL query - updates the metacoins in the database (this is where the storage actually happens)
	var/datum/db_query/query_inc_metacoins = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET metacoins = metacoins + '[amount]' WHERE ckey = '[ckey]'")
	query_inc_metacoins.warn_execute()
	qdel(query_inc_metacoins)

	//Output to chat
	if(announces)
		if(reason)
			to_chat(parent, "<span class='rose bold'>[abs(amount)] Monkecoins have been [amount >= 0 ? "deposited to" : "withdrawn from"] your account! Reason: [reason]</span>")
		else
			to_chat(parent, "<span class='rose bold'>[abs(amount)] Monkecoins have been [amount >= 0 ? "deposited to" : "withdrawn from"] your account!</span>")
	return TRUE

/datum/preferences/proc/has_coins(amount)
	if(amount > metacoins)
		return FALSE
	return TRUE
