/obj/item/pinpointer/crew/contractor
	name = "contractor pinpointer"
	desc = "A handheld tracking device that locks onto certain signals. Ignores suit sensors, but is much less accurate."
	icon_state = "pinpointer_syndicate"
	worn_icon_state = "pinpointer_black"
	minimum_range = 15
	has_owner = TRUE
	ignore_suit_sensor_level = TRUE

/obj/item/extraction_pack/contractor
	name = "black fulton extraction pack"
	desc = "A modified fulton pack that can be used indoors thanks to Bluespace technology. Favored by Syndicate Contractors."
	icon = 'monkestation/icons/obj/items/fulton.dmi'
	can_use_indoors = TRUE

/obj/item/pinpointer
	var/special_examine = FALSE

/obj/item/pinpointer/area_pinpointer
	name = "hacked pinpointer"
	desc = "A handheld tracking device that locks onto certain signals. This one seems to have wires sticking out of it, and can point onto areas instead of humans."
	icon_state = "pinpointer_syndicate"
	worn_icon_state = "pinpointer_black"
	special_examine = TRUE
	/// We save our position every time we scan_for_target()
	/// Its used to check if we moved so we may ignore calculations when being still, along with calculations between us and the target turfs.
	var/turf/pinpointer_turf
	/// The area we are currently tracking
	var/area/tracked_area

	/// The list of all open turfs within our tracked area
	var/list/turf/all_tracked_area_turfs = list()
	/// The list of all open turfs within our tracked area that we dont track, used exclusivelly for the debug pinpointer
	var/list/turf/open/not_tracked_area_turfs = list()
	/// The list of all open turfs within our tracked area, trimmed down to only the turfs we track
	var/list/turf/open/tracked_area_turfs = list()
	/// The list of all turfs with doors on them, used for the door mode
	var/list/turf/open/door_turfs = list()

	/// a switch, if TRUE it will display all door turfs instead of all open turfs
	var/door_mode = FALSE

/obj/item/pinpointer/area_pinpointer/Destroy()
	tracked_area = null
	pinpointer_turf = null

	all_tracked_area_turfs = null
	not_tracked_area_turfs = null
	tracked_area_turfs = null
	door_turfs = null

	return ..()

/obj/item/pinpointer/area_pinpointer/AltClick(mob/living/carbon/user)
	if(!istype(user) || !user.can_perform_action(src))
		return
	user.visible_message(span_notice("[user] quietly flips a switch in [user.p_their()] pinpointer."), span_notice("You quietly flip the switch your pinpointer."))
	door_mode = !door_mode

// we need to get our own examine text, since it would be "tracking the floor" otherwise
/obj/item/pinpointer/area_pinpointer/examine(mob/user)
	. = ..()
	if(target)
		. += span_notice("It is currently tracking [tracked_area].")
	if(door_mode)
		. += span_notice("It is currently tracking the nearest door in the given area, alt+click to switch modes")
	else
		. += span_notice("It is currently tracking the nearest floor in the given area, alt+click to switch modes")

/obj/item/pinpointer/area_pinpointer/get_direction_icon(here, there)
	// if we are in an area, we cheat a bit and instead of tracking our target, we just display the icon of being in the location
	for(var/turf/possible_turf as anything in all_tracked_area_turfs)
		if(pinpointer_turf == possible_turf)
			return "pinon[alert ? "alert" : ""]direct[icon_suffix]"

	return ..()

/obj/item/pinpointer/area_pinpointer/proc/create_target_turfs()
	all_tracked_area_turfs = get_area_turfs(tracked_area)
	// Treatment 1: store all open turfs, exclude all walls right-away and store open turfs with doors on a seperate variable
	for(var/turf/floor as anything in all_tracked_area_turfs) // Lets go over everything and store the turfs we care about
		if(floor.density) // catch all the walls, we dont want them
			not_tracked_area_turfs += floor
			continue
		tracked_area_turfs += floor
		if(locate(/obj/machinery/door/airlock) in floor)
			door_turfs += floor

	// Treatment 2: Any tile that is not near a wall is removed from our list
	// This majorly improves our performance in large rooms
	for(var/turf/open/open_turf as anything in tracked_area_turfs)
		var/marked_for_deletion = TRUE

		for(var/turf/unknown_turf as anything in RANGE_TURFS(1, open_turf))
			// we are near a wall, this turf is important
			// this also ignores windows, might need to change it depending on how relevant it is
			if(unknown_turf.density)
				marked_for_deletion = FALSE

		if(marked_for_deletion)
			not_tracked_area_turfs += open_turf
			tracked_area_turfs -= open_turf // it has no walls around it, so this turf is just bloating calculations for tracking. Cut it off

/obj/item/pinpointer/area_pinpointer/scan_for_target()
	var/current_turf = drop_location()

	if(pinpointer_turf == current_turf) // if our position has not changed, we dont need to update our target.
		return

	pinpointer_turf = current_turf

	// we dont need to track our target when they are in the area already
	for(var/turf/possible_turf as anything in all_tracked_area_turfs)
		if(pinpointer_turf == possible_turf)
			return

	/// The turf that has the lowest possible range towards us and the area
	var/turf/closest_turf
	/// Whats the range between us and the closest turf?
	var/closest_turf_range = 255
	if(!door_mode)
		for(var/turf/open/floor as anything in tracked_area_turfs) // Lets go over every turf and check their distances for the closest tile
			if(get_dist_euclidian(pinpointer_turf, floor) < closest_turf_range)
				closest_turf_range = get_dist_euclidian(pinpointer_turf, floor)
				closest_turf = floor

	else // if door_mode is TRUE, we instead want to track the nearest airlock instead of all turfs
		for(var/turf/open/floor as anything in door_turfs) // Lets go over every door and check their distances for the closest tile
			if(get_dist_euclidian(pinpointer_turf, floor) < closest_turf_range)
				closest_turf_range = get_dist_euclidian(pinpointer_turf, floor)
				closest_turf = floor

	target = closest_turf

/obj/item/pinpointer/area_pinpointer/attack_self(mob/living/user)
	if(active)
		toggle_on()
		user.visible_message(span_notice("[user] deactivates [user.p_their()] pinpointer."), span_notice("You deactivate your pinpointer."))

		// empty the lists so we can fill it on the next activation with the new area's turfs
		all_tracked_area_turfs = list()
		not_tracked_area_turfs = list()
		tracked_area_turfs = list()
		door_turfs = list()

		return

	if(!user)
		CRASH("[src] has had attack_self attempted by a non-existing user.")

	// This list should ONLY include areas that are on our z-level and are actually recognizable, else we confuse the contractor
	var/list/possible_areas = list()
	for(var/area/area in GLOB.areas)
		var/our_z = user.z
		var/area_z = area.z
		if(!our_z)
			// What the actual hell are you doing
			CRASH("[src] was activated in an area without a valid z-level")

		if(our_z != area_z)
			continue

		possible_areas += area

	if(!length(possible_areas))
		CRASH("[src] has failed to detect a valid area, this should never happen!")

	var/target_area = tgui_input_list(user, "Area to track", "Pinpoint", sort_list(possible_areas))
	if(isnull(target_area))
		return
	if(QDELETED(src) || QDELETED(user) || !user.is_holding(src) || user.incapacitated())
		return

	tracked_area = target_area

	create_target_turfs()

	target = get_first_open_turf_in_area(target_area) // failsafe

	toggle_on()

	user.visible_message(span_notice("[user] activates [user.p_their()] pinpointer."), span_notice("You activate your pinpointer."))

/**
 * Debug area pinpointer focuses on visualization, to better show how the area pinpointer interacts with turfs
 * Red - This tile is ignored by tracking, but recognized as a part of the target area
 * Green - This tile is a potential target, but not yet our current target
 * Yellow - The tile would be a potential target, but the tracking is currently off due to the pinpointer being in its area
 * Blue - This is the tile we are currently tracking
 */
/obj/item/pinpointer/area_pinpointer/debug
	name = "debug area pinpointer"
	desc = "A debug version of the area pinpointer, this one visualizes all of the turfs that are being tracked and ignored."
	var/list/obj/machinery/door/airlock/affected_airlock_list = list()

/obj/item/pinpointer/area_pinpointer/debug/create_target_turfs()
	. = ..()
	for(var/turf/non_tracked_turf as anything in not_tracked_area_turfs) // this tile will never be a potential target, no need to refresh it
		non_tracked_turf.color = rgb(255, 0, 0)
		non_tracked_turf.maptext = MAPTEXT("X")

	// we want to make the alpha of all the doors in the area lower so we can see the turf's colors easier
	for(var/turf/open/door_turf as anything in door_turfs)
		var/obj/machinery/door/airlock/affected_airlock = locate(/obj/machinery/door/airlock) in door_turf
		if(!affected_airlock)
			CRASH("[src] has tried to locate an airlock that was inside of the (door_turfs) list, but failed. This should never happen!")

		affected_airlock_list += affected_airlock
		affected_airlock.alpha = 50

/obj/item/pinpointer/area_pinpointer/debug/scan_for_target()
	. = ..()
	// we dont track turfs when the person holding us is in the area we are pointing to
	for(var/turf/possible_turf as anything in all_tracked_area_turfs)
		if(pinpointer_turf == possible_turf)
			for(var/turf/open/tracked_turf as anything in tracked_area_turfs)
				tracked_turf.color = rgb(255, 255, 0)
				tracked_turf.maptext = MAPTEXT("-")
			return

	for(var/turf/open/tracked_turf as anything in tracked_area_turfs)
		tracked_turf.color = rgb(0, 255, 0)
		tracked_turf.maptext = MAPTEXT("+")

	target.color = rgb(0, 0, 255) // higher color priority than any other turfs
	target.maptext = MAPTEXT("T")

/obj/item/pinpointer/area_pinpointer/debug/attack_self(mob/living/user)
	if(active)
		for(var/turf/floor as anything in all_tracked_area_turfs) // we need to clear all the colors we created
			floor.color = initial(floor.color)
			floor.maptext = initial(floor.maptext)

		// we need to reset the alpha on the airlocks
		for(var/obj/machinery/door/airlock/affected_airlock as anything in affected_airlock_list)
			affected_airlock.alpha = initial(affected_airlock.alpha)

		affected_airlock_list = list() // empty da list when we are done cleaning
	return ..()

/obj/item/pinpointer/area_pinpointer/debug/Destroy()
	if(active)
		for(var/turf/floor as anything in all_tracked_area_turfs) // we need to clear all th- wait why am i getting dejavu?
			floor.color = initial(floor.color)
			floor.maptext = initial(floor.maptext)

		for(var/obj/machinery/door/airlock/affected_airlock as anything in affected_airlock_list)
			affected_airlock.alpha = initial(affected_airlock.alpha)

	affected_airlock_list = null
	return ..()
