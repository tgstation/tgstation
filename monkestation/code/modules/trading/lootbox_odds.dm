//global because its easier long term
//also its own file to make it super easy
//to find and adjust odds of lootbox rolls
/proc/return_rolled(type_string, mob/user)
	var/obj/item/temp
	switch(type_string)
		if("Unusual")
			var/path = pick(GLOB.possible_lootbox_clothing)
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
			user.client.client_token_holder.adjust_antag_tokens(HIGH_THREAT, 1)
		if("Medium Tier")
			temp = new /obj/item/coin/antagtoken
			temp.name = "Medium Tier Antag Token"
			user.client.client_token_holder.adjust_antag_tokens(MEDIUM_THREAT, 1)
		if("Low Tier")
			temp = new /obj/item/coin/antagtoken
			temp.name = "Low Tier Antag Token"
			user.client.client_token_holder.adjust_antag_tokens(LOW_THREAT, 1)

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
		var/path = pick(GLOB.possible_lootbox_clothing)
		var/obj/item/temp = new path(turf)
		var/list/viable_unusuals = subtypesof(/datum/component/particle_spewer) - /datum/component/particle_spewer/movement
		var/picked_path = pick(viable_unusuals)
		temp.AddComponent(/datum/component/unusual_handler, particle_path = picked_path)

///list of all clothing that can be rolled by lootboxes
GLOBAL_LIST_INIT(possible_lootbox_clothing, list(
		/obj/item/clothing/head/avipilot,
		/obj/item/clothing/head/beanie,
		/obj/item/clothing/head/beanie/black,
		/obj/item/clothing/head/beanie/christmas,
		/obj/item/clothing/head/beanie/durathread/lootbox,
		/obj/item/clothing/head/bee,
		/obj/item/clothing/head/beret,
		/obj/item/clothing/head/beret/durathread/lootbox,
		/obj/item/clothing/head/beret/sec/lootbox,
		/obj/item/clothing/head/caphat/beret/lootbox,
		/obj/item/clothing/head/chameleon/broken,
		/obj/item/clothing/head/chaplain/clownmitre,
		/obj/item/clothing/head/cone,
		/obj/item/clothing/head/costume/allies,
		/obj/item/clothing/head/costume/bearpelt,
		/obj/item/clothing/head/costume/bronze,
		/obj/item/clothing/head/costume/bunnyhead,
		/obj/item/clothing/head/costume/canada,
		/obj/item/clothing/head/costume/cardborg,
		/obj/item/clothing/head/costume/chicken,
		/obj/item/clothing/head/costume/cirno,
		/obj/item/clothing/head/costume/constable,
		/obj/item/clothing/head/costume/crown,
		/obj/item/clothing/head/costume/crown/fancy,
		/obj/item/clothing/head/costume/cueball,
		/obj/item/clothing/head/costume/dark_hos,
		/obj/item/clothing/head/costume/deckers,
		/obj/item/clothing/head/costume/delinquent,
		/obj/item/clothing/head/costume/drfreezehat,
		/obj/item/clothing/head/costume/festive,
		/obj/item/clothing/head/costume/foilhat,
		/obj/item/clothing/head/costume/football_helmet,
		/obj/item/clothing/head/costume/garland,
		/obj/item/clothing/head/costume/griffin,
		/obj/item/clothing/head/costume/hasturhood,
		/obj/item/clothing/head/costume/irs,
		/obj/item/clothing/head/costume/jackbros,
		/obj/item/clothing/head/costume/jester,
		/obj/item/clothing/head/costume/jester/alt,
		/obj/item/clothing/head/costume/justice,
		/obj/item/clothing/head/costume/kitty,
		/obj/item/clothing/head/costume/lizard,
		/obj/item/clothing/head/costume/lobsterhat,
		/obj/item/clothing/head/costume/maidheadband,
		/obj/item/clothing/head/costume/mailman,
		/obj/item/clothing/head/costume/nemes,
		/obj/item/clothing/head/costume/nightcap/blue,
		/obj/item/clothing/head/costume/nightcap/red,
		/obj/item/clothing/head/costume/nursehat,
		/obj/item/clothing/head/costume/papersack,
		/obj/item/clothing/head/costume/papersack/smiley,
		/obj/item/clothing/head/costume/pharaoh,
		/obj/item/clothing/head/costume/pirate,
		/obj/item/clothing/head/costume/pirate/bandana,
		/obj/item/clothing/head/costume/pirate/captain,
		/obj/item/clothing/head/costume/pot,
		/obj/item/clothing/head/costume/powdered_wig,
		/obj/item/clothing/head/costume/rabbitears,
		/obj/item/clothing/head/costume/redcoat,
		/obj/item/clothing/head/costume/rice_hat,
		/obj/item/clothing/head/costume/santa,
		/obj/item/clothing/head/costume/scarecrow_hat,
		/obj/item/clothing/head/costume/shrine_wig,
		/obj/item/clothing/head/costume/snowman,
		/obj/item/clothing/head/costume/sombrero,
		/obj/item/clothing/head/costume/space_marine,
		/obj/item/clothing/head/costume/spacepolice,
		/obj/item/clothing/head/costume/strigihat,
		/obj/item/clothing/head/costume/tmc,
		/obj/item/clothing/head/costume/tv_head/fov_less,
		/obj/item/clothing/head/costume/ushanka,
		/obj/item/clothing/head/costume/ushanka/frosty,
		/obj/item/clothing/head/costume/weddingveil,
		/obj/item/clothing/head/costume/witchwig,
		/obj/item/clothing/head/costume/xenos,
		/obj/item/clothing/head/costume/yuri,
		/obj/item/clothing/head/costume/zed_officercap,
		/obj/item/clothing/head/cowboy/black/lootbox,
		/obj/item/clothing/head/cowboy/bounty/lootbox,
		/obj/item/clothing/head/cowboy/brown/lootbox,
		/obj/item/clothing/head/cowboy/grey/lootbox,
		/obj/item/clothing/head/cowboy/red/lootbox,
		/obj/item/clothing/head/cowboy/white/lootbox,
		/obj/item/clothing/head/fedora,
		/obj/item/clothing/head/fedora/carpskin,
		/obj/item/clothing/head/fedora/white,
		/obj/item/clothing/head/guardmanhelmet/lootbox,
		/obj/item/clothing/head/hats/bowler,
		/obj/item/clothing/head/hats/caphat/lootbox,
		/obj/item/clothing/head/hats/caphat/parade/lootbox,
		/obj/item/clothing/head/hats/centcom_cap/lootbox,
		/obj/item/clothing/head/hats/centhat/lootbox,
		/obj/item/clothing/head/hats/coordinator/lootbox,
		/obj/item/clothing/head/hats/hopcap/lootbox,
		/obj/item/clothing/head/hats/hos/beret/lootbox,
		/obj/item/clothing/head/hats/hos/cap/lootbox,
		/obj/item/clothing/head/hats/hos/shako/lootbox,
		/obj/item/clothing/head/hats/intern,
		/obj/item/clothing/head/hats/tophat,
		/obj/item/clothing/head/hats/warden/lootbox,
		/obj/item/clothing/head/hats/warden/drill/lootbox,
		/obj/item/clothing/head/hats/warden/red/lootbox,
		/obj/item/clothing/head/mikuhair,
		/obj/item/clothing/head/milkmanhat,
		/obj/item/clothing/head/morningstar,
		/obj/item/clothing/head/mothcap,
		/obj/item/clothing/head/nanner_crown,
		/obj/item/clothing/head/nanotrasen_consultant/hubert/lootbox,
		/obj/item/clothing/head/rasta,
		/obj/item/clothing/head/recruiter_cap/lootbox,
		/obj/item/clothing/head/saints,
		/obj/item/clothing/head/soft/fishing_hat/lootbox,
		/obj/item/clothing/head/soft/rainbow,
		/obj/item/clothing/head/soft/sec/lootbox,
		/obj/item/clothing/head/utility/hardhat/pumpkinhead/lootbox,
		/obj/item/clothing/head/utility/hardhat/pumpkinhead/blumpkin/lootbox,
		/obj/item/clothing/head/waldo,
		/obj/item/clothing/head/wizard/lootbox,
		/obj/item/clothing/head/wizard/black/lootbox,
		/obj/item/clothing/head/wizard/marisa/lootbox,
		/obj/item/clothing/head/wonka,
))
