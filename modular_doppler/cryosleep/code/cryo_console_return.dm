/// Returns any items inside of the `items_to_send` list to a cryo console on station.
/mob/living/carbon/human/proc/return_items_to_console(list/items_to_send)
	var/list/held_contents = get_contents()
	if(!held_contents || !items_to_send)
		return FALSE

	var/obj/machinery/computer/cryopod/target_console
	for(var/obj/machinery/computer/cryopod/cryo_console in GLOB.cryopod_computers)
		target_console = cryo_console
		var/turf/target_turf = get_turf(target_console)
		if(is_station_level(target_turf.z)) //If we find a cryo console on station, send items to it first and foremost.
			break

	if(!target_console)
		return FALSE

	for(var/obj/item/found_item in held_contents)
		if(!is_type_in_list(found_item, items_to_send))
			continue
		transferItemToLoc(found_item, target_console, force = TRUE, silent = TRUE)
		target_console.frozen_item += found_item

	return TRUE
