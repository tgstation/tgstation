// VENTCRAWLING

/mob/living/proc/notify_ventcrawler_on_login()
	var/ventcrawler = HAS_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS) || HAS_TRAIT(src, TRAIT_VENTCRAWLER_NUDE)
	if(!ventcrawler)
		return
	to_chat(src, span_notice("You can ventcrawl! Use alt+click on vents to quickly travel about the station."))

/mob/living/carbon/human/notify_ventcrawler_on_login()
	if(!ismonkey(src))
		return ..()
	if(!istype(head, /obj/item/clothing/head/helmet/monkey_sentience)) //don't notify them about ventcrawling if they're wearing the sentience helmet, because they can't ventcrawl with it on, and if they take it off they'll no longer be in control of the mob.
		return ..()



/// Checks if the mob is able to enter the vent, and provides feedback if they are unable to.
/mob/living/proc/can_enter_vent(obj/machinery/atmospherics/components/ventcrawl_target, provide_feedback = TRUE)
	// Being able to always ventcrawl trumps being only able to ventcrawl when wearing nothing
	var/required_nudity = HAS_TRAIT(src, TRAIT_VENTCRAWLER_NUDE) && !HAS_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS)
	// Cache the vent_movement bitflag var from atmos machineries
	var/vent_movement = ventcrawl_target.vent_movement

	if(!Adjacent(ventcrawl_target))
		return
	if(!HAS_TRAIT(src, TRAIT_VENTCRAWLER_NUDE) && !HAS_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS))
		return
	if(stat)
		if(provide_feedback)
			to_chat(src, span_warning("You must be conscious to do this!"))
		return
	if(HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		if(provide_feedback)
			to_chat(src, span_warning("You currently can't move into the vent!"))
		return
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		if(provide_feedback)
			to_chat(src, span_warning("You need to be able to use your hands to ventcrawl!"))
		return
	if(has_buckled_mobs())
		if(provide_feedback)
			to_chat(src, span_warning("You can't vent crawl with other creatures on you!"))
		return
	if(buckled)
		if(provide_feedback)
			to_chat(src, span_warning("You can't vent crawl while buckled!"))
		return
	if(iscarbon(src) && required_nudity)
		if(length(get_equipped_items(INCLUDE_POCKETS)) || get_num_held_items())
			if(provide_feedback)
				to_chat(src, span_warning("You can't crawl around in the ventilation ducts with items!"))
			return
	if(ventcrawl_target.welded)
		if(provide_feedback)
			to_chat(src, span_warning("You can't crawl around a welded vent!"))
		return

	if(!(vent_movement & VENTCRAWL_ENTRANCE_ALLOWED))
		if(provide_feedback)
			to_chat(src, span_warning("You can't enter this vent!"))
		return

	return TRUE

/// Handles the entrance and exit on ventcrawling
/mob/living/proc/handle_ventcrawl(obj/machinery/atmospherics/components/ventcrawl_target)
	if(!can_enter_vent(ventcrawl_target))
		return

	var/has_client = !isnull(client) // clientless mobs can do this too! this is just stored in case the client disconnects while we sleep in do_after.

	//Handle the exit here
	if(HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) && istype(loc, /obj/machinery/atmospherics) && movement_type & VENTCRAWLING)
		to_chat(src, span_notice("You begin climbing out from the ventilation system..."))
		if(has_client && isnull(client))
			return
		if(!do_after(src, 1 SECONDS, target = ventcrawl_target))
			return
		if(ventcrawl_target.welded) // in case it got welded during our sleep
			to_chat(src, span_warning("You can't crawl around a welded vent!"))
			return
		visible_message(span_notice("[src] scrambles out from the ventilation ducts!"), span_notice("You scramble out from the ventilation ducts."))
		forceMove(ventcrawl_target.loc)
		REMOVE_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)
		update_pipe_vision()

	//Entrance here
	else
		var/datum/pipeline/vent_parent = ventcrawl_target.parents[1]
		if(vent_parent && (vent_parent.members.len || vent_parent.other_atmos_machines))
			ventcrawl_target.flick_overlay_static(image('icons/effects/vent_indicator.dmi', "arrow", ABOVE_MOB_LAYER, dir = get_dir(src.loc, ventcrawl_target.loc)), 2 SECONDS)
			visible_message(span_notice("[src] begins climbing into the ventilation system...") ,span_notice("You begin climbing into the ventilation system..."))
			if(!do_after(src, 2.5 SECONDS, target = ventcrawl_target, extra_checks = CALLBACK(src, PROC_REF(can_enter_vent), ventcrawl_target)))
				return
			if(has_client && isnull(client))
				return
			if(ventcrawl_target.welded) // in case it got welded during our sleep
				to_chat(src, span_warning("You can't crawl around a welded vent!"))
				return
			ventcrawl_target.flick_overlay_static(image('icons/effects/vent_indicator.dmi', "insert", ABOVE_MOB_LAYER), 1 SECONDS)
			visible_message(span_notice("[src] scrambles into the ventilation ducts!"), span_notice("You climb into the ventilation ducts."))
			move_into_vent(ventcrawl_target)
		else
			to_chat(src, span_warning("This ventilation duct is not connected to anything!"))

/mob/living/basic/slime/can_enter_vent(obj/machinery/atmospherics/components/ventcrawl_target, provide_feedback = TRUE)
	if(buckled)
		if(provide_feedback)
			to_chat(src, span_warning("You can't vent crawl while feeding!"))
		return
	return ..()

/**
 * Moves living mob directly into the vent as a ventcrawler
 *
 * Arguments:
 * * ventcrawl_target - The vent into which we are moving the mob
 */
/mob/living/proc/move_into_vent(obj/machinery/atmospherics/components/ventcrawl_target)
	forceMove(ventcrawl_target)
	ADD_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)
	update_pipe_vision()

/**
 * Everything related to pipe vision on ventcrawling is handled by update_pipe_vision().
 * Called on exit, entrance, and pipenet differences (e.g. moving to a new pipenet).
 * One important thing to note however is that the movement of the client's eye is handled by the relaymove() proc in /obj/machinery/atmospherics.
 * We move first and then call update. Dont flip this around
 */
/mob/living/proc/update_pipe_vision(full_refresh = FALSE)
	if(!isnull(ai_controller) && isnull(client)) // we don't care about pipe vision if we have an AI controller with no client (typically means we are clientless).
		return

	// Take away all the pipe images if we're not doing anything with em
	if(isnull(client) || !HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) || !istype(loc, /obj/machinery/atmospherics) || !(movement_type & VENTCRAWLING))
		for(var/image/current_image in pipes_shown)
			client.images -= current_image
		pipes_shown.len = 0
		pipetracker = null
		for(var/atom/movable/screen/plane_master/lighting as anything in hud_used.get_true_plane_masters(LIGHTING_PLANE))
			lighting.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, "#4d4d4d")
		for(var/atom/movable/screen/plane_master/pipecrawl as anything in hud_used.get_true_plane_masters(PIPECRAWL_IMAGES_PLANE))
			pipecrawl.hide_plane(src)
		return

	// We're gonna color the lighting plane to make it darker while ventcrawling, so things look nicer
	// This is a bit hacky but it makes the background darker, which has a nice effect
	for(var/atom/movable/screen/plane_master/lighting as anything in hud_used.get_true_plane_masters(LIGHTING_PLANE))
		lighting.add_atom_colour("#4d4d4d", TEMPORARY_COLOUR_PRIORITY)

	for(var/atom/movable/screen/plane_master/pipecrawl as anything in hud_used.get_true_plane_masters(PIPECRAWL_IMAGES_PLANE))
		pipecrawl.unhide_plane(src)

	var/obj/machinery/atmospherics/current_location = loc
	var/list/our_pipenets = current_location.return_pipenets()

	// We on occasion want to do a full rebuild. this lets us do that
	if(full_refresh)
		for(var/image/current_image in pipes_shown)
			client.images -= current_image
		pipes_shown.len = 0
		pipetracker = null

	if(!pipetracker)
		pipetracker = new()

	var/turf/our_turf = get_turf(src)
	// We're getting the smallest "range" arg we can pass to the spatial grid and still get all the stuff we need
	// We preload a bit more then we need so movement looks ok
	var/list/view_range = getviewsize(client.view)
	pipetracker.set_bounds(view_range[1] + 1, view_range[2] + 1)

	var/list/entered_exited_pipes = pipetracker.recalculate_type_members(our_turf, SPATIAL_GRID_CONTENTS_TYPE_ATMOS)
	var/list/pipes_gained = entered_exited_pipes[1]
	var/list/pipes_lost = entered_exited_pipes[2]

	for(var/obj/machinery/atmospherics/pipenet_part as anything in pipes_lost)
		if(!pipenet_part.pipe_vision_img)
			continue
		client.images -= pipenet_part.pipe_vision_img
		pipes_shown -= pipenet_part.pipe_vision_img

	for(var/obj/machinery/atmospherics/pipenet_part as anything in pipes_gained)
		// If the machinery is not part of our net or is not meant to be seen, continue
		var/list/thier_pipenets = pipenet_part.return_pipenets()
		if(!length(thier_pipenets & our_pipenets))
			continue
		if(!(pipenet_part.vent_movement & VENTCRAWL_CAN_SEE))
			continue

		if(!pipenet_part.pipe_vision_img)
			var/turf/their_turf = get_turf(pipenet_part)
			pipenet_part.pipe_vision_img = image(pipenet_part, pipenet_part.loc, dir = pipenet_part.dir)
			SET_PLANE(pipenet_part.pipe_vision_img, PIPECRAWL_IMAGES_PLANE, their_turf)
		client.images += pipenet_part.pipe_vision_img
		pipes_shown += pipenet_part.pipe_vision_img
