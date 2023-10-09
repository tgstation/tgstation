/datum/uplink_item/bundles_tc/surplus/lootbox
	name = "Syndicate Lootbox Crate"
	desc = "A dusty crate from the back of the Syndicate warehouse. Rumored to contain a valuable assortment of items, \
			With their all new kit, codenamed 'scam' the syndicate attempted to extract the energy of the die of fate to \
			make a loot-box style system but failed, so instead just fake their randomness using ook's evil twin brother to sniff out the items to shove in it. \
			Item price not guaranteed. Can contain normally unobtainable items."
	lock_other_purchases = TRUE

/datum/uplink_item/bundles_tc/surplus/lootbox/purchase(mob/user, datum/uplink_handler/handler, atom/movable/source)
	crate_tc_value = rand(1,20) // randomise how much it costs, from 5 to 100 TC
	crate_tc_value *= 5
	if(crate_tc_value == 5) //horrible luck, welcome to gambling
		crate_tc_value *= 0
		to_chat(user, span_warning("You feel an overwhelming sense of pride and accomplishment."))
	if(crate_tc_value == 100) // Jackpot, how lucky
		crate_tc_value *= 2
		print_command_report("Congratulations to [user] for being the [rand(2, 9)]th lucky winner of the syndicate lottery! \
		Dread Admiral Sabertooth has authorised the beaming of your special equipment immediately! Happy hunting operative.",
		"Syndicate Gambling Division High Command", TRUE)
	var/obj/structure/closet/crate/surplus_crate = new crate_type()
	if(!istype(surplus_crate))
		CRASH("crate_type is not a crate")
	var/list/possible_items = generate_possible_items(user, handler)

	fill_crate(surplus_crate, possible_items)

	podspawn(list( // unlike other chests, lets give them the chest with STYLE
		"target" = get_turf(user),
		"style" = STYLE_SYNDICATE,
		"spawn" = surplus_crate,
	))
