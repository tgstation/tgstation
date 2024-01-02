/datum/preferences

	///Ships owned by the owner of the prefs
	var/list/ships_owned = list(
		/obj/item/ship_parts/neutral = 0,
		/obj/item/ship_parts/nanotrasen = 0,
		/obj/item/ship_parts/syndicate = 0,
	)

/datum/preferences/proc/save_ships()
	savefile.set_entry("ships_owned", ships_owned)
	return TRUE

/datum/controller/subsystem/ticker/display_report(popcount)
	. = ..()
	for(var/client/all_clients as anything in GLOB.clients)
		all_clients.give_random_ship_part()

