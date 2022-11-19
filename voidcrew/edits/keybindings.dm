/datum/keybinding/carbon/remove_ship_part
	hotkey_keys = list("N")
	name = "takeshippart"
	full_name = "Take ship part"
	description = "Remove ship parts from your preferences."
	keybind_signal = COMSIG_KB_CARBON_TAKESHIPPART_DOWN

/datum/keybinding/carbon/remove_ship_part/down(client/user)
	. = ..()
	if(.)
		return
	var/list/owned_ships = user.get_ships()
	if(!owned_ships)
		return FALSE

	user.list_ship_parts()
	var/ship_response = tgui_input_list(user, "Select a ship part to take out.", "Ship construction", owned_ships)
	if(!ship_response || !owned_ships[ship_response])
		return FALSE

	var/obj/item/ship_parts/removed_parts = owned_ships[ship_response]
	user.prefs.ships_owned[removed_parts]--
	new removed_parts(user.mob.loc)
	return TRUE
