
//global because its easier long term
//also its own file to make it super easy
//to find and adjust odds of lootbox rolls
/proc/return_rolled(type_string, mob/user)
	var/obj/item/temp
	switch(type_string)
		if("Unusual")
			var/list/viable_hats = list(
				/obj/item/clothing/head/caphat,
				/obj/item/clothing/head/beanie,
				/obj/item/clothing/head/beret,
			)
			viable_hats += subtypesof(/obj/item/clothing/head/hats) - typesof(/obj/item/clothing/head/hats/hos) - /obj/item/clothing/head/hats/centcom_cap - /obj/item/clothing/head/hats/hopcap - /obj/item/clothing/head/hats/centhat - /obj/item/clothing/head/hats/warden
			viable_hats += subtypesof(/obj/item/clothing/head/costume)
			var/path = pick(viable_hats)
			temp = new path
			var/list/viable_unusuals = subtypesof(/datum/component/particle_spewer) - /datum/component/particle_spewer/movement
			var/picked_path = pick(viable_unusuals)
			var/pulled_key =  user.ckey
			if(!pulled_key)
				pulled_key = "MissingNo." // have fun trying to get this one lol
			temp.AddComponent(/datum/component/unusual_handler, particle_path = picked_path, fresh_unusual = TRUE, client_ckey = pulled_key)

			if(user.client?.prefs)
				user.client.prefs.save_new_unusual(temp)

		//token adding
		if("High Tier")
			temp = new /obj/item/coin/antagtoken
			temp.name = "High Tier Antag Token"
			user.client.saved_tokens.adjust_tokens(HIGH_THREAT, 1)
		if("Medium Tier")
			temp = new /obj/item/coin/antagtoken
			temp.name = "Medium Tier Antag Token"
			user.client.saved_tokens.adjust_tokens(MEDIUM_THREAT, 1)
		if("Low Tier")
			temp = new /obj/item/coin/antagtoken
			temp.name = "Low Tier Antag Token"
			user.client.saved_tokens.adjust_tokens(LOW_THREAT, 1)

		if("Loadout Item")
			var/static/list/viable_types = list()
			if(!length(viable_types))
				for(var/datum/loadout_item/type as anything in subtypesof(/datum/loadout_item))
					var/datum/loadout_item/listed = new type()
					if(!istype(listed))
						continue
					if(!listed.requires_purchase || listed.donator_only)
						continue
					if(!listed.item_path)
						continue
					if(length(listed.ckeywhitelist))
						continue
					viable_types += listed
			var/datum/loadout_item/picked = pick(viable_types)
			temp = new picked.item_path
			if(picked.item_path in user.client.prefs.inventory)
				user.client.prefs.adjust_metacoins(user.ckey, 2500, "Duplicate Loadout Item", donator_multipler = FALSE)
				temp.color = COLOR_GRAY
				temp.name = "Loadout Item [temp.name] (Duplicate)"
				user.overlay_fullscreen("lb_duplicate", /atom/movable/screen/fullscreen/lootbox_overlay/duplicate)
			else
				picked.add_to_user(usr.client)
				temp.name = "Loadout Item [temp.name]"

	return temp


/datum/loadout_item/proc/add_to_user(client/buyer)
	SHOULD_CALL_PARENT(TRUE)
	var/fail_message ="<span class='warning'>Failed to add lootbox item to database. Will reattempt until added!</span>"
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
			addtimer(CALLBACK(src, PROC_REF(add_to_user), buyer), 15 SECONDS)
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

/proc/testing_spawn_bulk_unusuals()
	var/turf/turf = get_turf(usr)

	for(var/i = 1 to 20)
		var/list/viable_hats = list(
		/obj/item/clothing/head/caphat,
		/obj/item/clothing/head/beanie,
		/obj/item/clothing/head/beret,
		)
		viable_hats += subtypesof(/obj/item/clothing/head/hats) - typesof(/obj/item/clothing/head/hats/hos) - /obj/item/clothing/head/hats/centcom_cap - /obj/item/clothing/head/hats/hopcap - /obj/item/clothing/head/hats/centhat - /obj/item/clothing/head/hats/warden
		viable_hats += subtypesof(/obj/item/clothing/head/costume) - /obj/item/clothing/head/costume/nightcap
		var/path = pick(viable_hats)
		var/obj/item/temp = new path(turf)
		var/list/viable_unusuals = subtypesof(/datum/component/particle_spewer) - /datum/component/particle_spewer/movement
		var/picked_path = pick(viable_unusuals)
		temp.AddComponent(/datum/component/unusual_handler, particle_path = picked_path)
