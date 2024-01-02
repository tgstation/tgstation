///Removes the cost of the ship from their total. Returns FALSE if unable to.
/client/proc/remove_ship_cost(ship_faction, ship_cost)
	for(var/obj/item/ship_parts/ships as anything in prefs.ships_owned)
		if(initial(ships.faction) != ship_faction)
			continue
		//not enough parts
		if(prefs.ships_owned[ships] < ship_cost)
			return FALSE
		prefs.ships_owned[ships] -= ship_cost
		prefs.save_ships()
		return TRUE
	//failed to purchase
	return FALSE

///Gives a random ship part and saves it in your prefs.
/client/proc/give_random_ship_part()
	var/obj/item/ship_parts/selected_ship = pick(subtypesof(/obj/item/ship_parts))
	prefs.ships_owned[selected_ship]++
	prefs.save_ships()
	to_chat(usr, span_notice("You have recieved a [initial(selected_ship.name)] ship part!"))

///Gives a readout of all ship parts owned.
/client/proc/list_ship_parts()
	to_chat(usr, span_boldwarning("Currently owned ship parts:"))
	for(var/obj/item/ship_parts/ships as anything in prefs.ships_owned)
		if(initial(prefs.ships_owned[ships]) < 1) //don't have any
			continue
		to_chat(usr, span_boldwarning("[prefs.ships_owned[ships]] [initial(ships.name)]"))

///Returns a list of all owned ship parts, the only player feedback is if you don't have any.
/client/proc/get_ships()
	var/list/owned_ships = list()
	for(var/obj/item/ship_parts/ships as anything in prefs.ships_owned)
		if(initial(prefs.ships_owned[ships]) < 1) //don't have any
			continue
		owned_ships["[initial(ships.name)] - [initial(prefs.ships_owned[ships])] owned"] = ships

	if(!length(owned_ships))
		to_chat(src, span_notice("You do not have any ship parts."))
		return FALSE

	return owned_ships
