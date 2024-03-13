/obj/structure/liquid_plasma_extraction_pipe
	name = "liquid plasma extraction pipe"
	desc = "Get that mork- liquid plasma, and return back to the base."
	icon = 'icons/obj/pipes_n_cables/plasma_extractor.dmi'
	icon_state = "pipe_unbuilt"
	base_icon_state = "pipe"
	max_integrity = 900 //a lot more resistant.
	anchored = TRUE
	obj_flags = CAN_BE_HIT
	move_resist = MOVE_FORCE_STRONG
	dir = NONE // we will set the direction ourselves in placement.

	///The extraction hub pipenet we're connected to, which also has us in their own list.
	var/obj/structure/plasma_extraction_hub/part/pipe/connected_hub
	///The state of the pipe, in construction steps.
	var/pipe_state = PIPE_STATE_UNBUILT
	///The status of the pipe, basically if it's currently working on sucking up plasma or not.
	var/pipe_status = PIPE_STATUS_OFF

/obj/structure/liquid_plasma_extraction_pipe/Initialize(mapload, obj/structure/plasma_extraction_hub/part/pipe/connected_hub)
	. = ..()
	src.connected_hub = connected_hub

/obj/structure/liquid_plasma_extraction_pipe/Destroy()
	if(connected_hub)
		connected_hub.on_pipe_destroyed(src)
		connected_hub = null
	return ..()

/obj/structure/liquid_plasma_extraction_pipe/update_icon_state()
	. = ..()
	switch(pipe_state)
		if(PIPE_STATE_UNBUILT)
			icon_state = "[base_icon_state]_unbuilt"
		if(PIPE_STATE_DAMAGED)
			icon_state = "[base_icon_state]_damaged"
		else
			icon_state = base_icon_state

/obj/structure/liquid_plasma_extraction_pipe/update_overlays()
	. = ..()
	if(ISDIAGONALDIR(dir)) //overlays are only placed on straight pipes.
		return
	switch(pipe_status)
		if(PIPE_STATUS_OFF)
			. += "[base_icon_state]_red"
		if(PIPE_STATUS_ON)
			. += "[base_icon_state]_green"

/obj/structure/liquid_plasma_extraction_pipe/wrench_act(mob/living/user, obj/item/tool)
	if(pipe_state != PIPE_STATE_UNBUILT)
		balloon_alert(user, "already built!")
		return ITEM_INTERACT_BLOCKING
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 40, interaction_key = DOAFTER_SOURCE_PIPE_CONSTRUCTION))
		return ITEM_INTERACT_BLOCKING
	//diagonal pipes cant be moved on top of, others are fine, once we're wrenched in.
	if(ISDIAGONALDIR(dir))
		density = TRUE
	balloon_alert(user, "fastened")
	pipe_state = PIPE_STATE_FINE
	update_appearance(UPDATE_ICON)
	return ITEM_INTERACT_SUCCESS

/obj/structure/liquid_plasma_extraction_pipe/welder_act(mob/living/user, obj/item/tool)
	if(pipe_state != PIPE_STATE_DAMAGED)
		balloon_alert(user, "not damaged!")
		return ITEM_INTERACT_BLOCKING
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 40, interaction_key = DOAFTER_SOURCE_PIPE_CONSTRUCTION))
		return ITEM_INTERACT_BLOCKING
	repair_damage(max_integrity) //repair all damage.
	balloon_alert(user, "repaired")
	pipe_state = PIPE_STATE_FINE
	var/obj/structure/plasma_extraction_hub/part/pipe/main/connected_hub = connected_hub
	if(istype(connected_hub) && connected_hub.drilling)
		connected_hub.start_drilling()
	else if(connected_hub.pipe_owner.drilling)
		connected_hub.start_drilling()
	else
		update_appearance(UPDATE_ICON)
	return ITEM_INTERACT_SUCCESS

//this is called by basic animals, but not simple. Too bad, if you want to fix this then start making more basic mobs!
/obj/structure/liquid_plasma_extraction_pipe/attack_animal(mob/user, list/modifiers)
	. = ..()
	if(!.)
		return
	if(pipe_state == PIPE_STATE_DAMAGED)
		return
	balloon_alert_to_viewers("springs a leak!")
	pipe_state = PIPE_STATE_DAMAGED
	if(connected_hub.currently_functional)
		connected_hub.stop_drilling()
	else
		update_appearance(UPDATE_ICON)

/obj/structure/liquid_plasma_extraction_pipe/Move(atom/newloc, direct, glide_size_override, update_dir)
	. = ..()
	//you shouldn't be moving, now die.
	qdel(src)

/**
 * Ending pipe
 * This one starts off freely built and has a different sprite.
 */
/obj/structure/liquid_plasma_ending
	name = "liquid plasma extractor"
	desc = "Extracts concentrated liquid plasma from the geyser for mining."
	icon = 'icons/obj/pipes_n_cables/plasma_extractor.dmi'
	icon_state = "pipe_ending"
	base_icon_state = "pipe_ending"
	anchored = TRUE
	density = TRUE
	obj_flags = CAN_BE_HIT
	resistance_flags = LAVA_PROOF | FIRE_PROOF | INDESTRUCTIBLE
	move_resist = MOVE_FORCE_OVERPOWERING
