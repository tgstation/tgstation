/turf/open/floor/noslip/tram
	name = "high-traction platform"
	icon_state = "noslip_tram"
	base_icon_state = "noslip_tram"
	floor_tile = /obj/item/stack/tile/noslip/tram

/turf/open/floor/noslip/tram_plate
	name = "linear induction plate"
	desc = "The linear induction plate that powers the tram."
	icon_state = "tram_plate"
	base_icon_state = "tram_plate"
	floor_tile = /obj/item/stack/tile/noslip/tram_plate
	slowdown = 0
	flags_1 = NONE

/turf/open/floor/noslip/tram_plate/energized
	desc = "The linear induction plate that powers the tram. It is currently energized."
	/// Inbound station
	var/inbound
	/// Outbound station
	var/outbound

/turf/open/floor/noslip/tram_platform
	name = "tram platform"
	icon_state = "tram_platform"
	base_icon_state = "tram_platform"
	floor_tile = /obj/item/stack/tile/noslip/tram_platform
	slowdown = 0

/turf/open/floor/noslip/tram_plate/broken_states()
	return list("tram_plate-damaged1","tram_plate-damaged2")

/turf/open/floor/noslip/tram_plate/burnt_states()
	return list("tram_plate-scorched1","tram_plate-scorched2")

/turf/open/floor/noslip/tram_platform/broken_states()
	return list("tram_platform-damaged1","tram_platform-damaged2")

/turf/open/floor/noslip/tram_platform/burnt_states()
	return list("tram_platform-scorched1","tram_platform-scorched2")

/turf/open/floor/noslip/attackby(obj/item/object, mob/living/user, params)
	. = ..()
	if(istype(object, /obj/item/stack/thermoplastic))
		INVOKE_ASYNC(TYPE_PROC_REF(/turf/open, build_with_transport_tiles), object, user)
	else if(istype(object, /obj/item/stack/sheet/mineral/titanium))
		INVOKE_ASYNC(TYPE_PROC_REF(/turf/open, build_with_titanium), object, user)

/turf/open/floor/noslip/tram_plate/energized/proc/find_tram()
	for(var/datum/transport_controller/linear/tram/tram as anything in SSicts_transport.transports_by_type[TRAM_LIFT_ID])
		if(tram.specific_transport_id != TRAMSTATION_LINE_1)
			continue
		return tram

/turf/open/floor/noslip/tram_plate/energized/proc/toast(mob/living/future_tram_victim)
	var/datum/transport_controller/linear/tram/tram = find_tram()

	// Check for stopped states.
	if(!tram || !tram.controller_operational || !inbound || !outbound)
		return FALSE

	var/obj/structure/transport/linear/tram/tram_part = tram.return_closest_platform_to(src)

	if(QDELETED(tram_part))
		return FALSE

	// Everything will be based on position and travel direction
	var/plate_pos
	var/tram_pos
	var/tram_velocity_sign // 1 for positive axis movement, -1 for negative
	// Try to be agnostic about N-S vs E-W movement
	if(tram.travel_direction & (NORTH|SOUTH))
		plate_pos = y
		tram_pos = tram_part.y
		tram_velocity_sign = tram.travel_direction & NORTH ? 1 : -1
	else
		plate_pos = x
		tram_pos = tram_part.x
		tram_velocity_sign = tram.travel_direction & EAST ? 1 : -1

	// How far away are we? negative if already passed.
	var/approach_distance = tram_velocity_sign * (plate_pos - (tram_pos + (DEFAULT_TRAM_LENGTH * 0.5)))

	// Check if our victim is in the active path of the tram.
	if(!tram.controller_active)
		return FALSE
	if(approach_distance < 0)
		return FALSE
	playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	audible_message(
		span_hear("You hear an electric crackle when you step on the plate...")
	)
	if(tram.travel_direction & WEST && inbound < tram.idle_platform.platform_code)
		return FALSE
	if(tram.travel_direction & EAST && outbound > tram.idle_platform.platform_code)
		return FALSE
	if(approach_distance >= AMBER_THRESHOLD_NORMAL)
		return FALSE

	// Finally the interesting part where they ACTUALLY get hit!
	notify_ghosts("[future_tram_victim] has fallen in the path of an oncoming tram!", source = future_tram_victim, action = NOTIFY_ORBIT, header = "Electrifying!")
	future_tram_victim.electrocute_act(15, src, 1)
	return TRUE

/turf/open/floor/glass/reinforced/tram/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)

/turf/open/floor/glass/reinforced/tram
	name = "tram bridge"
	desc = "It shakes a bit when you step, but lets you cross between sides quickly!"

/obj/structure/thermoplastic
	name = "tram"
	desc = "A lightweight thermoplastic flooring."
	icon = 'icons/turf/floors.dmi'
	icon_state = "tram_dark"
	density = FALSE
	anchored = TRUE
	armor_type = /datum/armor/tram_structure
	max_integrity = 750
	layer = TRAM_FLOOR_LAYER
	plane = FLOOR_PLANE
	obj_flags = BLOCK_Z_OUT_DOWN | BLOCK_Z_OUT_UP
	appearance_flags = PIXEL_SCALE|KEEP_TOGETHER
	var/secured = TRUE
	var/floor_tile = /obj/item/stack/thermoplastic

/obj/structure/thermoplastic/light
	icon_state = "tram_light"
	floor_tile = /obj/item/stack/thermoplastic/light

/obj/structure/thermoplastic/examine(mob/user)
	. = ..()

	if(secured)
		. += span_notice("It is secured with a set of <b>screws.</b>")
	else
		. += span_notice("You can <b>crowbar</b> to remove the tile.")
		. += span_notice("It can be re-secured using a <b>screwdriver.</b>")

/obj/structure/thermoplastic/attackby_secondary(obj/item/tool, mob/user, params)
	if(secured)
		if(tool.tool_behaviour == TOOL_SCREWDRIVER)
			user.visible_message(span_notice("[user] begins to unscrew the tile..."),
									span_notice("You begin to unscrew the tile..."))
			if(tool.use_tool(src, user, 4 SECONDS, volume = 50))
				secured = FALSE
				to_chat(user, span_notice("The screws come out, and a gap forms around the edge of the tile."))
		else if (tool.tool_behaviour)
			to_chat(user, span_warning("The security screws need to be removed first!"))

	else
		if(tool.tool_behaviour == TOOL_SCREWDRIVER)
			user.visible_message(span_notice("[user] begins to fasten the tile..."),
									span_notice("You begin to fasten the tile..."))
			if(tool.use_tool(src, user, 4 SECONDS, volume = 50))
				secured = TRUE
				to_chat(user, span_notice("The tile is securely screwed in place."))

		else if(tool.tool_behaviour == TOOL_CROWBAR)
			user.visible_message(span_notice("[user] wedges \the [tool] into the tile's gap in the edge and starts prying..."),
									span_notice("You wedge \the [tool] into the tram panel's gap in the frame and start prying..."))
			if(tool.use_tool(src, user, 4 SECONDS, volume = 50))
				to_chat(user, span_notice("The panel pops out of the frame."))
				var/obj/item/stack/thermoplastic/pulled_tile = new()
				pulled_tile.update_integrity(atom_integrity)
				user.put_in_hands(pulled_tile)
				qdel(src)

	if (tool.tool_behaviour)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return ..()

/obj/structure/thermoplastic/welder_act(mob/living/user, obj/item/tool)
	if(atom_integrity >= max_integrity)
		to_chat(user, span_warning("[src] is already in good condition!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if(!tool.tool_start_check(user, amount = 0))
		return FALSE
	to_chat(user, span_notice("You begin repairing [src]..."))
	var/integrity_to_repair = max_integrity - atom_integrity
	if(tool.use_tool(src, user, integrity_to_repair, volume = 50))
		atom_integrity = max_integrity
		to_chat(user, span_notice("You repair [src]."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/stack/thermoplastic
	name = "thermoplastic tram tile"
	singular_name = "thermoplastic tram tile"
	desc = "A high-traction floor tile. It sparkles in the light."
	icon = 'icons/obj/tiles.dmi'
	lefthand_file = 'icons/mob/inhands/items/tiles_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/tiles_righthand.dmi'
	icon_state = "tile_textured_white_large"
	inhand_icon_state = "tile-tile_textured_white_large"
	color = COLOR_TRAM_BLUE
	w_class = WEIGHT_CLASS_NORMAL
	force = 1
	throwforce = 1
	throw_speed = 3
	throw_range = 7
	max_amount = 60
	novariants = TRUE
	merge_type = /obj/item/stack/thermoplastic
	var/tile_type = /obj/structure/thermoplastic
	/// Cached associative lazy list to hold the radial options for tile reskinning. See tile_reskinning.dm for more information. Pattern: list[type] -> image
	var/list/tile_reskin_types = list(
		/obj/item/stack/thermoplastic/light,
	)

/obj/item/stack/thermoplastic/light
	color = COLOR_TRAM_LIGHT_BLUE
	tile_type = /obj/structure/thermoplastic/light

/obj/item/stack/thermoplastic/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1)
	. = ..()
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3) //randomize a little
	//if(tile_reskin_types)
	//	tile_reskin_types = tile_reskin_list(tile_reskin_types)

/obj/item/stack/thermoplastic/examine(mob/user)
	. = ..()
	if(tile_reskin_types)
		. += span_notice("Use while in your hand to change what type of [src] you want.")
	if(throwforce && !is_cyborg) //do not want to divide by zero or show the message to borgs who can't throw
		var/verb
		switch(CEILING(MAX_LIVING_HEALTH / throwforce, 1)) //throws to crit a human
			if(1 to 3)
				verb = "superb"
			if(4 to 6)
				verb = "great"
			if(7 to 9)
				verb = "good"
			if(10 to 12)
				verb = "fairly decent"
			if(13 to 15)
				verb = "mediocre"
		if(!verb)
			return
		. += span_notice("Those could work as a [verb] throwing weapon.")
