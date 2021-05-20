// VENTCRAWLING
// Handles the entrance and exit on ventcrawling
/mob/living/proc/handle_ventcrawl(obj/machinery/atmospherics/components/ventcrawl_target)
	// Being able to always ventcrawl trumps being only able to ventcrawl when wearing nothing
	var/required_nudity = HAS_TRAIT(src, TRAIT_VENTCRAWLER_NUDE) && !HAS_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS)
	// Cache the vent_movement bitflag var from atmos machineries
	var/vent_movement = ventcrawl_target.vent_movement

	if(!Adjacent(ventcrawl_target))
		return
	if(!HAS_TRAIT(src, TRAIT_VENTCRAWLER_NUDE) && !HAS_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS))
		return
	if(stat)
		to_chat(src, "<span class='warning'>You must be conscious to do this!</span>")
		return
	if(HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		to_chat(src, "<span class='warning'>You currently can't move into the vent!</span>")
		return
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		to_chat(src, "<span class='warning'>You need to be able to use your hands to ventcrawl!</span>")
		return
	if(has_buckled_mobs())
		to_chat(src, "<span class='warning'>You can't vent crawl with other creatures on you!</span>")
		return
	if(buckled)
		to_chat(src, "<span class='warning'>You can't vent crawl while buckled!</span>")
		return
	if(iscarbon(src) && required_nudity)
		if(length(get_equipped_items(include_pockets = TRUE)) || get_num_held_items())
			to_chat(src, "<span class='warning'>You can't crawl around in the ventilation ducts with items!</span>")
			return
	if(ventcrawl_target.welded)
		to_chat(src, "<span class='warning'>You can't crawl around a welded vent!</span>")
		return

	if(vent_movement & VENTCRAWL_ENTRANCE_ALLOWED)
		//Handle the exit here
		if(HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) && istype(loc, /obj/machinery/atmospherics) && movement_type & VENTCRAWLING)
			visible_message("<span class='notice'>[src] begins climbing out from the ventilation system...</span>" ,"<span class='notice'>You begin climbing out from the ventilation system...</span>")
			if(!client)
				return
			visible_message("<span class='notice'>[src] scrambles out from the ventilation ducts!</span>","<span class='notice'>You out from the ventilation ducts.</span>")
			forceMove(ventcrawl_target.loc)
			REMOVE_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)
			update_pipe_vision()

		//Entrance here
		else
			var/datum/pipeline/vent_parent = ventcrawl_target.parents[1]
			if(vent_parent && (vent_parent.members.len || vent_parent.other_atmosmch))
				visible_message("<span class='notice'>[src] begins climbing into the ventilation system...</span>" ,"<span class='notice'>You begin climbing into the ventilation system...</span>")
				if(!do_after(src, 2.5 SECONDS, target = ventcrawl_target))
					return
				if(!client)
					return
				visible_message("<span class='notice'>[src] scrambles into the ventilation ducts!</span>","<span class='notice'>You climb into the ventilation ducts.</span>")
				forceMove(ventcrawl_target)
				ADD_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)
				update_pipe_vision()
			else
				to_chat(src, "<span class='warning'>This ventilation duct is not connected to anything!</span>")


/mob/living/simple_animal/slime/handle_ventcrawl(atom/A)
	if(buckled)
		to_chat(src, "<i>I can't vent crawl while feeding...</i>")
		return
	return ..()

/**
 * Everything related to pipe vision on ventcrawling is handled by update_pipe_vision().
 * Called on exit, entrance, and pipenet differences (e.g. moving to a new pipenet).
 * One important thing to note however is that the movement of the client's eye is handled by the relaymove() proc in /obj/machinery/atmospherics.
 * We move first and then call update. Dont flip this around
 */
/mob/living/proc/update_pipe_vision()
	// Take the pipe images from the client
	if (!isnull(client))
		for(var/image/current_image in pipes_shown)
			client.images -= current_image
		pipes_shown.len = 0

	// Give the pipe images to the client
	if(HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) && istype(loc, /obj/machinery/atmospherics) && movement_type & VENTCRAWLING)
		var/list/total_members = list()
		var/obj/machinery/atmospherics/current_location = loc
		for(var/datum/pipeline/location_pipeline in current_location.returnPipenets())
			total_members += location_pipeline.members
			total_members += location_pipeline.other_atmosmch

		if(!total_members.len)
			return

		if(client)
			for(var/obj/machinery/atmospherics/pipenet_part in total_members)
				// If the machinery is not in view or is not meant to be seen, continue
				if(!in_view_range(client.mob, pipenet_part))
					continue
				if(!(pipenet_part.vent_movement & VENTCRAWL_CAN_SEE))
					continue

				if(!pipenet_part.pipe_vision_img)
					pipenet_part.pipe_vision_img = image(pipenet_part, pipenet_part.loc, dir = pipenet_part.dir)
					pipenet_part.pipe_vision_img.plane = ABOVE_HUD_PLANE
				client.images += pipenet_part.pipe_vision_img
				pipes_shown += pipenet_part.pipe_vision_img
