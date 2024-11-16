/obj/structure/liquid_plasma_extraction_pipe
	name = "liquid plasma extraction pipe"
	desc = "A strong pipe used to pump liquid plasma from a geyser to the extraction hub."
	icon = 'icons/obj/pipes_n_cables/plasma_extractor.dmi'
	icon_state = "pipe_unbuilt"
	base_icon_state = "pipe"
	max_integrity = 900 //a lot more resistant than the average structure, we want focus on repairs instead.
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
	register_context()

/obj/structure/liquid_plasma_extraction_pipe/Destroy()
	if(connected_hub)
		connected_hub.on_pipe_destroyed(src)
		connected_hub.connected_pipes -= src
		connected_hub = null
	return ..()

/obj/structure/liquid_plasma_extraction_pipe/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	switch(pipe_state)
		if(PIPE_STATE_UNBUILT)
			switch(held_item?.tool_behaviour)
				if(TOOL_WELDER)
					context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
					return CONTEXTUAL_SCREENTIP_SET
				if(TOOL_WRENCH)
					context[SCREENTIP_CONTEXT_LMB] = "Fasten"
					return CONTEXTUAL_SCREENTIP_SET
		if(PIPE_STATE_DAMAGED)
			if(held_item?.tool_behaviour == TOOL_WELDER)
				context[SCREENTIP_CONTEXT_LMB] = "Repair"
				return CONTEXTUAL_SCREENTIP_SET
		if(PIPE_STATE_FINE)
			if(held_item?.tool_behaviour == TOOL_WRENCH)
				context[SCREENTIP_CONTEXT_LMB] = "Unfasten"
				return CONTEXTUAL_SCREENTIP_SET

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
	if(pipe_state == PIPE_STATE_UNBUILT) //not built yet, don't give it overlays.
		return
	switch(pipe_status)
		if(PIPE_STATUS_OFF)
			. += "[base_icon_state]_red"
		if(PIPE_STATUS_ON)
			. += "[base_icon_state]_green"

/obj/structure/liquid_plasma_extraction_pipe/wrench_act(mob/living/user, obj/item/tool)
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 40, interaction_key = DOAFTER_SOURCE_PIPE_CONSTRUCTION))
		return ITEM_INTERACT_BLOCKING
	switch(pipe_state)
		if(PIPE_STATE_FINE)
			balloon_alert(user, "unfastened")
			pipe_state = PIPE_STATE_UNBUILT
		if(PIPE_STATE_DAMAGED)
			balloon_alert(user, "repair first!")
			return ITEM_INTERACT_BLOCKING
		if(PIPE_STATE_UNBUILT)
			balloon_alert(user, "fastened")
			pipe_state = PIPE_STATE_FINE
	update_appearance(UPDATE_ICON)
	return ITEM_INTERACT_SUCCESS

/obj/structure/liquid_plasma_extraction_pipe/welder_act(mob/living/user, obj/item/tool)
	switch(pipe_state)
		if(PIPE_STATE_UNBUILT)
			if(pipe_status == PIPE_STATUS_ON)
				balloon_alert(user, "turn it off first!")
				return ITEM_INTERACT_BLOCKING
			balloon_alert(user, "deconstructing...")
		if(PIPE_STATE_FINE)
			balloon_alert(user, "not damaged")
			return ITEM_INTERACT_BLOCKING
	if(!tool.tool_start_check(user, amount = 1))
		return ITEM_INTERACT_BLOCKING
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 40, interaction_key = DOAFTER_SOURCE_PIPE_CONSTRUCTION))
		return ITEM_INTERACT_BLOCKING
	switch(pipe_state)
		if(PIPE_STATE_DAMAGED)
			repair_damage(max_integrity) //repair all damage.
			balloon_alert(user, "repaired")
			pipe_state = PIPE_STATE_FINE
			if(connected_hub.pipe_owner.drilling)
				if(connected_hub.start_drilling())
					return ITEM_INTERACT_SUCCESS
				update_appearance(UPDATE_ICON) //ensure icons are updated even if drilling doesn't start.
				return ITEM_INTERACT_SUCCESS
		if(PIPE_STATE_UNBUILT)
			qdel(src)
			return ITEM_INTERACT_SUCCESS

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
	//you shouldn't be moving, kill it.
	//This will automatically destroy all pipes after it, and let the previous one lay pipes down again.
	qdel(src)

/**
 * Ending pipe
 * This one starts off freely anchored (so no need to wrench it in) and has a different sprite.
 * This basically has no functionality and only exists to tell pipes that they've successfully connected to a geyser.
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
	layer = BELOW_STRUCTURE_LAYER
	resistance_flags = LAVA_PROOF | FIRE_PROOF | INDESTRUCTIBLE
	move_resist = MOVE_FORCE_OVERPOWERING
