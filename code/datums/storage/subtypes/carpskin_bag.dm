/datum/storage/carpskin_bag
	var/forced_pickup = FALSE

// All hooks, lines and lures are classified as one type
/datum/storage/carpskin_bag/process_numerical_display()
	var/list/toreturn = list()

	for(var/obj/item/thing in real_location)
		var/total_amnt = 1

		if (isstack(thing))
			var/obj/item/stack/things = thing
			total_amnt = things.amount

		var/thing_key = "[thing.type]-[thing.name]"

		if (istype(thing, /obj/item/fishing_line))
			thing_key = "fishing_line"
		else if (istype(thing, /obj/item/fishing_hook))
			thing_key = "fishing_hook"
		else if (istype(thing, /obj/item/fishing_lure))
			thing_key = "fishing_lure"

		if (!toreturn[thing_key])
			toreturn[thing_key] = new /datum/numbered_display(thing, total_amnt)
		else
			var/datum/numbered_display/numberdisplay = toreturn[thing_key]
			numberdisplay.number += total_amnt

	return toreturn

/// Display a radial of all items of that "parent" type
/datum/storage/carpskin_bag/remove_single(mob/removing, obj/item/thing, atom/remove_to_loc, silent = FALSE)
	if (forced_pickup)
		return ..()

	var/thing_key = null
	if (istype(thing, /obj/item/fishing_line))
		thing_key = /obj/item/fishing_line
	else if (istype(thing, /obj/item/fishing_hook))
		thing_key = /obj/item/fishing_hook
	else if (istype(thing, /obj/item/fishing_lure))
		thing_key = /obj/item/fishing_lure

	if (!thing_key)
		return ..()

	var/list/radial_popup = list()
	for (var/obj/item/possible_item in real_location.contents)
		if (istype(possible_item, thing_key))
			// Can't do .appearance because the first item has maptext of how many lures/hooks/lines we hold in total
			radial_popup[possible_item] = image(initial(possible_item.icon), initial(possible_item.icon_state))

	var/obj/item/result = show_radial_menu(removing, parent, radial_popup, tooltips = TRUE)

	if (!result)
		return FALSE

	forced_pickup = TRUE
	result.attempt_pickup(removing)
	forced_pickup = FALSE
	return FALSE
