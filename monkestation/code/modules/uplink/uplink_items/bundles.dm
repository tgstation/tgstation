/datum/uplink_item/bundles_tc/contract_kit
	name = "Contractor Bundle"
	desc = "A box containing everything you need to take contracts from the Syndicate. Kidnap people and drop them off at specified locations for rewards in the form of Telecrystals \
			(Usable in the provided uplink) and Contractor Points. Can not be bought if you have taken any secondary objectives."
	item = /obj/item/storage/box/syndie_kit/contract_kit
	cost = 20
	purchasable_from = UPLINK_TRAITORS

/datum/uplink_item/bundles_tc/contract_kit/unique_checks(mob/user, datum/uplink_handler/handler, atom/movable/source)
	if(length(handler.active_objectives) || !handler.can_take_objectives || !handler.has_objectives)
		return FALSE

	for(var/datum/traitor_objective/objective in handler.completed_objectives)
		if(objective.objective_state != OBJECTIVE_STATE_INACTIVE)
			return FALSE

	return TRUE

/datum/uplink_item/bundles_tc/contract_kit/purchase(mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	. = ..()
	var/datum/component/uplink/our_uplink = source.GetComponent(/datum/component/uplink)
	if(uplink_handler && our_uplink)
		our_uplink.become_contractor()

/datum/uplink_item/bundles_tc/surplus/lootbox
	name = "Syndicate Lootbox Crate"
	desc = "A dusty crate from the back of the Syndicate warehouse. Rumored to contain a valuable assortment of items, \
			With their all new kit, codenamed 'scam' the syndicate attempted to extract the energy of the die of fate to \
			make a loot-box style system but failed, so instead just fake their randomness using ook's evil twin brother to sniff out the items to shove in it. \
			Item price not guaranteed. Can contain normally unobtainable items. Purchasing this will prevent you from purchasing any non-random item. \
			Cannot be purchased if you have already bought another item."

/datum/uplink_item/bundles_tc/surplus/lootbox/unique_checks(mob/user, datum/uplink_handler/handler, atom/movable/source)
	//we dont acually have the var that makes this get checked so do it manually
	if(length(handler.purchase_log.purchase_log) > 0)
		return FALSE
	return TRUE

/datum/uplink_item/bundles_tc/surplus/lootbox/spawn_item(spawn_path, mob/user, datum/uplink_handler/handler, atom/movable/source)
	crate_tc_value = rand(1,20) * 5 // randomise how much in TC it gives, from 5 to 100 TC

	if(crate_tc_value == 5) //horrible luck, welcome to gambling
		crate_tc_value = 0
		to_chat(user, span_warning("You feel an overwhelming sense of pride and accomplishment."))

	if(crate_tc_value == 100) // Jackpot, how lucky
		crate_tc_value *= 2
		print_command_report("Congratulations to [user] for being the [rand(2, 9)]th lucky winner of the syndicate lottery! \
		Dread Admiral Sabertooth has authorised the beaming of your special equipment immediately! Happy hunting operative.",
		"Syndicate Gambling Division High Command", TRUE)
		if(ishuman(user) && !(locate(/obj/item/implant/weapons_auth) in user)) //jackpot winners dont have to find firing pins for any guns they get
			var/obj/item/implant/weapons_auth/auth = new
			auth.implant(user)
			to_chat(user, span_notice("You feel as though the syndicate have given you the ability to use weapons beyond your normal access level."))

	var/obj/structure/closet/crate/surplus_crate = new crate_type()
	// quick safety check
	if(!istype(surplus_crate))
		CRASH("crate_type is not a crate")

	var/list/possible_items = generate_possible_items(user, handler, TRUE)
	// again safety check, if things fucked up badly we give them back their cost and return
	if(!possible_items || !length(possible_items))
		handler.telecrystals += cost
		to_chat(user, span_warning("You get the feeling something went wrong and that you should inform syndicate command."))
		qdel(surplus_crate)
		CRASH("lootbox crate failed to generate possible items")

	fill_crate(surplus_crate, possible_items)

	// unlike other chests, lets give them the chest with STYLE by droppodding in a STYLIZED pod
	podspawn(list(
		"target" = get_turf(user),
		"style" = STYLE_SYNDICATE,
		"spawn" = surplus_crate,
	))

	// lock everything except random entries, once you start gambling you cannot stop
	handler.add_locked_entries(subtypesof(/datum/uplink_item) - /datum/uplink_item/bundles_tc/random)

	// return the source, this is so the round-end uplink section shows how many TC the traitor spent on us (20TC) and a radio icon. Instead of 0 TC and a blank one
	return source

//pain
///Check if we should ignore handler locked_entries or not
/datum/uplink_item/bundles_tc/random/proc/check_ignore_locked(datum/uplink_handler/handler)
	return (length(handler.locked_entries) == (length(subtypesof(/datum/uplink_item)) - 1)) && !(src.type in handler.locked_entries)

