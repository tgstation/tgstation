// VENTCRAWLING
// Handles the entrance and exit on ventcrawling
/mob/living/proc/handle_ventcrawl(obj/machinery/atmospherics/components/A)
	// Being able to always ventcrawl trumps being only able to ventcrawl when wearing nothing
	var/required_nudity = HAS_TRAIT(src, TRAIT_VENTCRAWLER_NUDE) && !HAS_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS)
	// Cache the vent_movement bitflag var from atmos machineries
	var/vent_movement = A.vent_movement

	if(!Adjacent(A))
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
	if(A.welded)
		to_chat(src, "<span class='warning'>You can't crawl around a welded vent!</span>")
		return	

	if(vent_movement & VENTCRAWL_ENTRANCE_ALLOWED)
		//Handle the exit here
		if(HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) && istype(src.loc, /obj/machinery/atmospherics) && movement_type & VENTCRAWLING)
			visible_message("<span class='notice'>[src] begins climbing out from the ventilation system...</span>" ,"<span class='notice'>You begin climbing out from the ventilation system...</span>")
			if(!client)
				return
			visible_message("<span class='notice'>[src] scrambles out from the ventilation ducts!</span>","<span class='notice'>You out from the ventilation ducts.</span>")
			forceMove(A.loc)
			REMOVE_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)
			update_pipe_vision()
		//Entrance here
		else
			var/datum/pipeline/vent_parent = A.parents[1]
			if(vent_parent && (vent_parent.members.len || vent_parent.other_atmosmch))
				visible_message("<span class='notice'>[src] begins climbing into the ventilation system...</span>" ,"<span class='notice'>You begin climbing into the ventilation system...</span>")
				if(!do_after(src, 25, target = A))
					return
				if(!client)
					return
				visible_message("<span class='notice'>[src] scrambles into the ventilation ducts!</span>","<span class='notice'>You climb into the ventilation ducts.</span>")
				forceMove(A)
				ADD_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)
				update_pipe_vision()
			else
				to_chat(src, "<span class='warning'>This ventilation duct is not connected to anything!</span>")


/mob/living/simple_animal/slime/handle_ventcrawl(atom/A)
	if(buckled)
		to_chat(src, "<i>I can't vent crawl while feeding...</i>")
		return
	return ..()

/mob/living/proc/update_pipe_vision()
	if(HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) && istype(src.loc, /obj/machinery/atmospherics) && movement_type & VENTCRAWLING)
		var/list/totalMembers = list()
		var/obj/machinery/atmospherics/current_location = src.loc
		for(var/datum/pipeline/P in current_location.returnPipenets())
			totalMembers += P.members
			totalMembers += P.other_atmosmch

		if(!totalMembers.len)
			return

		if(client)
			for(var/obj/machinery/atmospherics/A in totalMembers)
				if(A.vent_movement & VENTCRAWL_CAN_SEE && in_view_range(client.mob, A))
					if(!A.pipe_vision_img)
						A.pipe_vision_img = image(A, A.loc, layer = ABOVE_HUD_LAYER, dir = A.dir)
						A.pipe_vision_img.plane = ABOVE_HUD_PLANE
					client.images += A.pipe_vision_img
					pipes_shown += A.pipe_vision_img
	else
		if(client)
			for(var/image/current_image in pipes_shown)
				client.images -= current_image
			pipes_shown.len = 0
