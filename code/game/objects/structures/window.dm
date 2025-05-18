/obj/structure/window
	name = "window"
	desc = "A directional window."
	icon_state = "window"
	density = TRUE
	layer = ABOVE_OBJ_LAYER //Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = TRUE //initially is 0 for tile smoothing
	flags_1 = ON_BORDER_1
	obj_flags = CAN_BE_HIT | BLOCKS_CONSTRUCTION_DIR | IGNORE_DENSITY
	max_integrity = 50
	resistance_flags = ACID_PROOF
	armor_type = /datum/armor/structure_window
	can_atmos_pass = ATMOS_PASS_PROC
	rad_insulation = RAD_VERY_LIGHT_INSULATION
	pass_flags_self = PASSGLASS | PASSWINDOW
	set_dir_on_move = FALSE
	flags_ricochet = RICOCHET_HARD
	receive_ricochet_chance_mod = 0.5
	var/state = WINDOW_OUT_OF_FRAME
	var/reinf = FALSE
	var/heat_resistance = 800
	var/decon_speed = 30
	var/wtype = "glass"
	var/fulltile = FALSE
	var/glass_type = /obj/item/stack/sheet/glass
	var/glass_amount = 1
	var/real_explosion_block //ignore this, just use explosion_block
	var/break_sound = SFX_SHATTER
	var/knock_sound = 'sound/effects/glass/glassknock.ogg'
	var/bash_sound = 'sound/effects/glass/glassbash.ogg'
	var/hit_sound = 'sound/effects/glass/glasshit.ogg'
	/// If some inconsiderate jerk has had their blood spilled on this window, thus making it cleanable
	var/bloodied = FALSE
	///Datum that the shard and debris type is pulled from for when the glass is broken.
	var/datum/material/glass_material_datum = /datum/material/glass
	/// Whether or not we're disappearing but dramatically
	var/dramatically_disappearing = FALSE
	/// If we added a leaning component to ourselves
	var/added_leaning = FALSE

/datum/armor/structure_window
	melee = 50
	fire = 80
	acid = 100

/obj/structure/window/Initialize(mapload, direct)
	AddElement(/datum/element/blocks_explosives)
	. = ..()
	if(direct)
		setDir(direct)
	if(reinf && anchored)
		state = RWINDOW_SECURE

	if(!reinf && anchored)
		state = WINDOW_SCREWED_TO_FRAME

	air_update_turf(TRUE, TRUE)

	if(fulltile)
		setDir()
		obj_flags &= ~BLOCKS_CONSTRUCTION_DIR
		obj_flags &= ~IGNORE_DENSITY
		AddElement(/datum/element/can_barricade)

	//windows only block while reinforced and fulltile
	if(!reinf || !fulltile)
		set_explosion_block(0)

	flags_1 |= ALLOW_DARK_PAINTS_1
	RegisterSignal(src, COMSIG_OBJ_PAINTED, PROC_REF(on_painted))
	AddElement(/datum/element/atmos_sensitive, mapload)
	AddComponent(/datum/component/simple_rotation, ROTATION_NEEDS_ROOM, post_rotation = CALLBACK(src, PROC_REF(post_rotation)))

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	if (flags_1 & ON_BORDER_1)
		AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/window/mouse_drop_receive(atom/dropping, mob/user, params)
	. = ..()
	if (flags_1 & ON_BORDER_1)
		return

	//Adds the component only once. We do it here & not in Initialize() because there are tons of windows & we don't want to add to their init times
	LoadComponent(/datum/component/leanable, dropping)

/obj/structure/window/examine(mob/user)
	. = ..()

	switch(state)
		if(WINDOW_SCREWED_TO_FRAME)
			. += span_notice("The window is <b>screwed</b> to the frame.")
		if(WINDOW_IN_FRAME)
			. += span_notice("The window is <i>unscrewed</i> but <b>pried</b> into the frame.")
		if(WINDOW_OUT_OF_FRAME)
			if (anchored)
				. += span_notice("The window is <b>screwed</b> to the floor.")
			else
				. += span_notice("The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.")

/obj/structure/window/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("delay" = 2 SECONDS, "cost" = 5)
	return FALSE

/obj/structure/window/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(rcd_data["[RCD_DESIGN_MODE]"] == RCD_DECONSTRUCT)
		qdel(src)
		return TRUE
	return FALSE

/obj/structure/window/narsie_act()
	add_atom_colour(NARSIE_WINDOW_COLOUR, FIXED_COLOUR_PRIORITY)

/obj/structure/window/singularity_pull(atom/singularity, current_size)
	..()
	if(anchored && current_size >= STAGE_TWO)
		set_anchored(FALSE)
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)

/obj/structure/window/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return

	if(fulltile)
		return FALSE

	if(border_dir == dir)
		return FALSE

	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/moved_window = mover
		return valid_build_direction(loc, moved_window.dir, is_fulltile = moved_window.fulltile)

	if(istype(mover, /obj/structure/windoor_assembly) || istype(mover, /obj/machinery/door/window))
		return valid_build_direction(loc, mover.dir, is_fulltile = FALSE)

	return TRUE

/obj/structure/window/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving.movement_type & PHASING)
		return

	if(leaving == src)
		return // Let's not block ourselves.

	if (leaving.pass_flags & pass_flags_self)
		return

	if (fulltile)
		return

	if(direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/window/attack_tk(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(span_notice("Something knocks on [src]."))
	add_fingerprint(user)
	playsound(src, knock_sound, 50, TRUE)
	return COMPONENT_CANCEL_ATTACK_CHAIN


/obj/structure/window/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(!can_be_reached(user))
		return
	. = ..()

/obj/structure/window/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!can_be_reached(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)

	if(!user.combat_mode)
		user.visible_message(span_notice("[user] knocks on [src]."), \
			span_notice("You knock on [src]."))
		playsound(src, knock_sound, 50, TRUE)
	else
		user.visible_message(span_warning("[user] bashes [src]!"), \
			span_warning("You bash [src]!"))
		playsound(src, bash_sound, 100, TRUE)

/obj/structure/window/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/window/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1) //used by attack_alien, attack_animal
	if(!can_be_reached(user))
		return
	return ..()

/obj/structure/window/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(!can_be_reached(user))
		return ITEM_INTERACT_SKIP_TO_ATTACK // Guess you get to hit it
	add_fingerprint(user)
	return ..()

/obj/structure/window/welder_act(mob/living/user, obj/item/tool)
	if(atom_integrity >= max_integrity)
		to_chat(user, span_warning("[src] is already in good condition!"))
		return ITEM_INTERACT_SUCCESS
	if(!tool.tool_start_check(user, amount = 0))
		return FALSE
	to_chat(user, span_notice("You begin repairing [src]..."))
	if(tool.use_tool(src, user, 4 SECONDS, volume = 50))
		repair_damage(max_integrity)
		to_chat(user, span_notice("You repair [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/window/screwdriver_act(mob/living/user, obj/item/tool)

	switch(state)
		if(WINDOW_SCREWED_TO_FRAME)
			to_chat(user, span_notice("You begin to unscrew the window from the frame..."))
			if(tool.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				state = WINDOW_IN_FRAME
				to_chat(user, span_notice("You unfasten the window from the frame."))
		if(WINDOW_IN_FRAME)
			to_chat(user, span_notice("You begin to screw the window to the frame..."))
			if(tool.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				state = WINDOW_SCREWED_TO_FRAME
				to_chat(user, span_notice("You fasten the window to the frame."))
		if(WINDOW_OUT_OF_FRAME)
			if(anchored)
				to_chat(user, span_notice("You begin to unscrew the frame from the floor..."))
				if(tool.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
					set_anchored(FALSE)
					to_chat(user, span_notice("You unfasten the frame from the floor."))
			else
				to_chat(user, span_notice("You begin to screw the frame to the floor..."))
				if(tool.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
					set_anchored(TRUE)
					to_chat(user, span_notice("You fasten the frame to the floor."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/window/wrench_act(mob/living/user, obj/item/tool)
	if(anchored)
		return FALSE
	if(reinf && state >= RWINDOW_FRAME_BOLTED)
		return FALSE

	to_chat(user, span_notice("You begin to disassemble [src]..."))
	if(!tool.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
		return ITEM_INTERACT_SUCCESS
	var/obj/item/stack/sheet/G = new glass_type(user.loc, glass_amount)
	if (!QDELETED(G))
		G.add_fingerprint(user)
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	to_chat(user, span_notice("You successfully disassemble [src]."))
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/window/crowbar_act(mob/living/user, obj/item/tool)
	if(!anchored)
		return FALSE

	switch(state)
		if(WINDOW_IN_FRAME)
			to_chat(user, span_notice("You begin to lever the window out of the frame..."))
			if(tool.use_tool(src, user, 10 SECONDS, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				state = WINDOW_OUT_OF_FRAME
				to_chat(user, span_notice("You pry the window out of the frame."))
		if(WINDOW_OUT_OF_FRAME)
			to_chat(user, span_notice("You begin to lever the window back into the frame..."))
			if(tool.use_tool(src, user, 5 SECONDS, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				state = WINDOW_SCREWED_TO_FRAME
				to_chat(user, span_notice("You pry the window back into the frame."))
		else
			return FALSE

	return ITEM_INTERACT_SUCCESS

/obj/structure/window/attackby(obj/item/I, mob/living/user, list/modifiers)
	if(!can_be_reached(user))
		return TRUE //skip the afterattack

	add_fingerprint(user)
	return ..()


/obj/structure/window/set_anchored(anchorvalue)
	..()
	air_update_turf(TRUE, anchorvalue)
	update_nearby_icons()

/obj/structure/window/proc/check_state(checked_state)
	if(state == checked_state)
		return TRUE

/obj/structure/window/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/window/proc/check_state_and_anchored(checked_state, checked_anchored)
	return check_state(checked_state) && check_anchored(checked_anchored)


/obj/structure/window/proc/can_be_reached(mob/user)
	if(fulltile)
		return TRUE
	var/checking_dir = get_dir(user, src)
	if(!(checking_dir & dir))
		return TRUE // Only windows on the other side may be blocked by other things.
	checking_dir = REVERSE_DIR(checking_dir)
	for(var/obj/blocker in loc)
		if(!blocker.CanPass(user, checking_dir))
			return FALSE
	return TRUE


/obj/structure/window/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	if(.) //received damage
		update_nearby_icons()

/obj/structure/window/repair_damage(amount)
	. = ..()
	update_nearby_icons()

/obj/structure/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, hit_sound, 75, TRUE)
			else
				playsound(src, 'sound/items/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/tools/welder.ogg', 100, TRUE)


/obj/structure/window/atom_deconstruct(disassembled = TRUE)
	if(!disassembled)
		playsound(src, break_sound, 70, TRUE)
		for(var/obj/item/shard/debris in spawn_debris(drop_location()))
			transfer_fingerprints_to(debris) // transfer fingerprints to shards only
	update_nearby_icons()

///Spawns shard and debris decal based on the glass_material_datum, spawns rods if window is reinforned and number of shards/rods is determined by the window being fulltile or not.
/obj/structure/window/proc/spawn_debris(location)
	var/datum/material/glass_material_ref = GET_MATERIAL_REF(glass_material_datum)
	var/obj/item/shard_type = glass_material_ref.shard_type
	var/obj/effect/decal/debris_type = glass_material_ref.debris_type
	var/list/dropped_debris = list()
	if(!isnull(shard_type))
		dropped_debris += new shard_type(location)
		if (fulltile)
			dropped_debris += new shard_type(location)
	if(!isnull(debris_type))
		dropped_debris += new debris_type(location)
	if (reinf)
		dropped_debris += new /obj/item/stack/rods(location, (fulltile ? 2 : 1))
	return dropped_debris

/obj/structure/window/proc/post_rotation(mob/user, degrees)
	air_update_turf(TRUE, FALSE)

/obj/structure/window/proc/on_painted(obj/structure/window/source, mob/user, obj/item/toy/crayon/spraycan/spraycan, is_dark_color)
	SIGNAL_HANDLER
	if(!spraycan.actually_paints)
		return
	if (is_dark_color && fulltile) //Opaque directional windows restrict vision even in directions they are not placed in, please don't do this
		set_opacity(255)
	else
		set_opacity(initial(opacity))

/obj/structure/window/wash(clean_types)
	. = ..()
	if(!(clean_types & CLEAN_SCRUB))
		return
	set_opacity(initial(opacity))
	remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	for(var/atom/movable/cleanables as anything in src)
		if(cleanables == src)
			continue
		if(!cleanables.wash(clean_types))
			continue
		vis_contents -= cleanables
	bloodied = FALSE

/obj/structure/window/Destroy()
	set_density(FALSE)
	air_update_turf(TRUE, FALSE)
	update_nearby_icons()
	return ..()

/obj/structure/window/Move()
	var/turf/T = loc
	. = ..()
	if(anchored)
		move_update_air(T)

/obj/structure/window/can_atmos_pass(turf/T, vertical = FALSE)
	if(!anchored || !density)
		return TRUE
	return !(fulltile || dir == get_dir(loc, T))

//This proc is used to update the icons of nearby windows.
/obj/structure/window/proc/update_nearby_icons()
	update_appearance()
	if(smoothing_flags & USES_SMOOTHING)
		QUEUE_SMOOTH_NEIGHBORS(src)

//merges adjacent full-tile windows into one
/obj/structure/window/update_overlays(updates=ALL)
	. = ..()
	if(QDELETED(src) || !fulltile)
		return

	if((updates & UPDATE_SMOOTHING) && (smoothing_flags & USES_SMOOTHING))
		QUEUE_SMOOTH(src)

	var/ratio = atom_integrity / max_integrity
	ratio = CEILING(ratio*4, 1) * 25
	if(ratio > 75)
		return
	. += mutable_appearance('icons/obj/structures.dmi', "damage[ratio]", -(layer+0.1))

/obj/structure/window/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > T0C + heat_resistance

/obj/structure/window/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(round(air.return_volume() / 100), BURN, 0, 0)

/obj/structure/window/get_dumping_location()
	return null

/obj/structure/window/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!density)
		return TRUE
	if(fulltile || (dir == to_dir))
		return FALSE

	return TRUE

/obj/structure/window/proc/temporary_shatter(time_to_go = 1 SECONDS, time_to_return = 4 SECONDS, take_grill = TRUE)
	if(dramatically_disappearing)
		return

	// do a cute breaking animation
	var/static/time_interval = 2 DECISECONDS //per how many steps should we do damage?
	for(var/damage_step in 1 to (floor(time_to_go / time_interval) - 1)) //10 ds / 2 ds = 5 damage steps, minus 1 so we dont actually break it
		// slowly drain our total health for the illusion of shattering
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, take_damage), floor(atom_integrity / (time_to_go / time_interval))), time_interval * damage_step)

	//disappear in 1 second
	dramatically_disappearing = TRUE
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), loc, break_sound, 70, TRUE), time_to_go) //SHATTER SOUND
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, moveToNullspace)), time_to_go) //woosh

	// come back in 1 + 4 seconds
	addtimer(VARSET_CALLBACK(src, atom_integrity, atom_integrity), time_to_go + time_to_return) //set the health back (icon is updated on move)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, forceMove), loc), time_to_go + time_to_return) //we back boys
	addtimer(VARSET_CALLBACK(src, dramatically_disappearing, FALSE), time_to_go + time_to_return) //also set the var back
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_appearance)), time_to_go + time_to_return)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), get_turf(src), 'sound/effects/glass/glass_reverse.ogg', 70, TRUE), time_to_go + time_to_return)

	var/obj/structure/grille/grill = take_grill ? (locate(/obj/structure/grille) in loc) : null
	if(grill)
		grill.temporary_shatter(time_to_go, time_to_return)

/obj/structure/window/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(loc)
		update_nearby_icons()

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/spawner, 0)

/obj/structure/window/unanchored
	anchored = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/unanchored/spawner, 0)

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "A window that is reinforced with metal rods."
	icon_state = "rwindow"
	reinf = TRUE
	heat_resistance = 1600
	armor_type = /datum/armor/window_reinforced
	max_integrity = 75
	explosion_block = 1
	damage_deflection = 11
	state = RWINDOW_SECURE
	glass_type = /obj/item/stack/sheet/rglass
	rad_insulation = RAD_LIGHT_INSULATION
	receive_ricochet_chance_mod = 1.1

//this is shitcode but all of construction is shitcode and needs a refactor, it works for now
//If you find this like 4 years later and construction still hasn't been refactored, I'm so sorry for this

//Adding a timestamp, I found this in 2020, I hope it's from this year -Lemon
//2021 AND STILLLL GOING STRONG
//2022 BABYYYYY ~lewc
//2023 ONE YEAR TO GO! -LT3
/datum/armor/window_reinforced
	melee = 80
	bomb = 25
	fire = 80
	acid = 100

/obj/structure/window/reinforced/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("delay" = 3 SECONDS, "cost" = 15)
	return FALSE

/obj/structure/window/reinforced/attackby_secondary(obj/item/tool, mob/user, list/modifiers)
	if(resistance_flags & INDESTRUCTIBLE)
		balloon_alert(user, "too resilient!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	switch(state)
		if(RWINDOW_SECURE)
			if(tool.tool_behaviour == TOOL_WELDER)
				if(tool.tool_start_check(user, heat_required = HIGH_TEMPERATURE_REQUIRED))
					user.visible_message(span_notice("[user] holds \the [tool] to the security screws on \the [src]..."),
						span_notice("You begin heating the security screws on \the [src]..."))
					if(tool.use_tool(src, user, 15 SECONDS, volume = 100))
						to_chat(user, span_notice("The security screws are glowing white hot and look ready to be removed."))
						state = RWINDOW_BOLTS_HEATED
						addtimer(CALLBACK(src, PROC_REF(cool_bolts)), 30 SECONDS)
			else if (tool.tool_behaviour)
				to_chat(user, span_warning("The security screws need to be heated first!"))

		if(RWINDOW_BOLTS_HEATED)
			if(tool.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message(span_notice("[user] digs into the heated security screws and starts removing them..."),
										span_notice("You dig into the heated screws hard and they start turning..."))
				if(tool.use_tool(src, user, 50, volume = 50))
					state = RWINDOW_BOLTS_OUT
					to_chat(user, span_notice("The screws come out, and a gap forms around the edge of the pane."))
			else if (tool.tool_behaviour)
				to_chat(user, span_warning("The security screws need to be removed first!"))

		if(RWINDOW_BOLTS_OUT)
			if(tool.tool_behaviour == TOOL_CROWBAR)
				user.visible_message(span_notice("[user] wedges \the [tool] into the gap in the frame and starts prying..."),
										span_notice("You wedge \the [tool] into the gap in the frame and start prying..."))
				if(tool.use_tool(src, user, 40, volume = 50))
					state = RWINDOW_POPPED
					to_chat(user, span_notice("The panel pops out of the frame, exposing some thin metal bars that looks like they can be cut."))
			else if (tool.tool_behaviour)
				to_chat(user, span_warning("The gap needs to be pried first!"))

		if(RWINDOW_POPPED)
			if(tool.tool_behaviour == TOOL_WIRECUTTER)
				user.visible_message(span_notice("[user] starts cutting the exposed bars on \the [src]..."),
										span_notice("You start cutting the exposed bars on \the [src]"))
				if(tool.use_tool(src, user, 20, volume = 50))
					state = RWINDOW_BARS_CUT
					to_chat(user, span_notice("The panels falls out of the way exposing the frame bolts."))
			else if (tool.tool_behaviour)
				to_chat(user, span_warning("The bars need to be cut first!"))

		if(RWINDOW_BARS_CUT)
			if(tool.tool_behaviour == TOOL_WRENCH)
				user.visible_message(span_notice("[user] starts unfastening \the [src] from the frame..."),
					span_notice("You start unfastening the bolts from the frame..."))
				if(tool.use_tool(src, user, 40, volume = 50))
					to_chat(user, span_notice("You unscrew the bolts from the frame and the window pops loose."))
					state = WINDOW_OUT_OF_FRAME
					set_anchored(FALSE)
			else if (tool.tool_behaviour)
				to_chat(user, span_warning("The bolts need to be loosened first!"))


	if (tool.tool_behaviour)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return ..()

/obj/structure/window/reinforced/crowbar_act(mob/living/user, obj/item/tool)
	if(!anchored)
		return FALSE
	if(state != WINDOW_OUT_OF_FRAME)
		return FALSE
	to_chat(user, span_notice("You begin to lever the window back into the frame..."))
	if(tool.use_tool(src, user, 10 SECONDS, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
		state = RWINDOW_SECURE
		to_chat(user, span_notice("You pry the window back into the frame."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/window/proc/cool_bolts()
	if(state == RWINDOW_BOLTS_HEATED)
		state = RWINDOW_SECURE
		visible_message(span_notice("The bolts on \the [src] look like they've cooled off..."))

/obj/structure/window/reinforced/examine(mob/user)
	. = ..()
	if(resistance_flags & INDESTRUCTIBLE)
		return
	switch(state)
		if(RWINDOW_SECURE)
			. += span_notice("It's been screwed in with one way screws, you'd need to <b>heat them</b> to have any chance of backing them out.")
		if(RWINDOW_BOLTS_HEATED)
			. += span_notice("The screws are glowing white hot, and you'll likely be able to <b>unscrew them</b> now.")
		if(RWINDOW_BOLTS_OUT)
			. += span_notice("The screws have been removed, revealing a small gap you could fit a <b>prying tool</b> in.")
		if(RWINDOW_POPPED)
			. += span_notice("The main plate of the window has popped out of the frame, exposing some bars that look like they can be <b>cut</b>.")
		if(RWINDOW_BARS_CUT)
			. += span_notice("The main pane can be easily moved out of the way to reveal some <b>bolts</b> holding the frame in.")

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/spawner, 0)

/obj/structure/window/reinforced/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/unanchored/spawner, 0)

// You can't rust glass! So only reinforced glass can be impacted.
/obj/structure/window/reinforced/rust_heretic_act()
	add_atom_colour(COLOR_RUSTED_GLASS, FIXED_COLOUR_PRIORITY)
	AddElement(/datum/element/rust)
	set_armor(/datum/armor/none)
	take_damage(get_integrity() * 0.5)
	modify_max_integrity(initial(max_integrity) * 0.2)

/obj/structure/window/plasma
	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through."
	icon_state = "plasmawindow"
	reinf = FALSE
	heat_resistance = 25000
	armor_type = /datum/armor/window_plasma
	max_integrity = 200
	explosion_block = 1
	glass_type = /obj/item/stack/sheet/plasmaglass
	rad_insulation = RAD_MEDIUM_INSULATION
	glass_material_datum = /datum/material/alloy/plasmaglass

/datum/armor/window_plasma
	melee = 80
	bullet = 5
	bomb = 45
	fire = 99
	acid = 100

/obj/structure/window/plasma/Initialize(mapload, direct)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/plasma/spawner, 0)

/obj/structure/window/plasma/unanchored
	anchored = FALSE

/obj/structure/window/reinforced/plasma
	name = "reinforced plasma window"
	desc = "A window made out of a plasma-silicate alloy and a rod matrix. It looks hopelessly tough to break and is most likely nigh fireproof."
	icon_state = "plasmarwindow"
	reinf = TRUE
	heat_resistance = 50000
	armor_type = /datum/armor/reinforced_plasma
	max_integrity = 500
	damage_deflection = 21
	explosion_block = 2
	glass_type = /obj/item/stack/sheet/plasmarglass
	rad_insulation = RAD_HEAVY_INSULATION
	glass_material_datum = /datum/material/alloy/plasmaglass

/datum/armor/reinforced_plasma
	melee = 80
	bullet = 20
	bomb = 60
	fire = 99
	acid = 100

/obj/structure/window/reinforced/plasma/block_superconductivity()
	return TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/plasma/spawner, 0)

/obj/structure/window/reinforced/plasma/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	icon_state = "twindow"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/tinted/spawner, 0)

/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	icon_state = "fwindow"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/tinted/frosted/spawner, 0)

/* Full Tile Windows (more atom_integrity) */

/obj/structure/window/fulltile
	name = "full tile window"
	desc = "A full tile window."
	icon = 'icons/obj/smooth_structures/window.dmi'
	icon_state = "window-0"
	base_icon_state = "window"
	max_integrity = 100
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	glass_amount = 2

/obj/structure/window/fulltile/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("delay" = 2.5 SECONDS, "cost" = 10)
	return FALSE

/obj/structure/window/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/plasma/fulltile
	icon = 'icons/obj/smooth_structures/plasma_window.dmi'
	icon_state = "plasma_window-0"
	base_icon_state = "plasma_window"
	max_integrity = 400
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	glass_amount = 2

/obj/structure/window/plasma/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/reinforced/plasma/fulltile
	icon = 'icons/obj/smooth_structures/rplasma_window.dmi'
	icon_state = "rplasma_window-0"
	base_icon_state = "rplasma_window"
	state = RWINDOW_SECURE
	max_integrity = 1000
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	glass_amount = 2

/obj/structure/window/reinforced/plasma/fulltile/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced/fulltile
	name = "full tile reinforced window"
	desc = "A full tile window that is reinforced with metal rods."
	icon = 'icons/obj/smooth_structures/reinforced_window.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	max_integrity = 150
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	state = RWINDOW_SECURE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	glass_amount = 2

/obj/structure/window/reinforced/fulltile/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("mode" = RCD_DECONSTRUCT, "delay" = 4 SECONDS, "cost" = 20)
	return FALSE

/obj/structure/window/reinforced/fulltile/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced/tinted/fulltile
	icon = 'icons/obj/smooth_structures/tinted_window.dmi'
	icon_state = "tinted_window-0"
	base_icon_state = "tinted_window"
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	glass_amount = 2
	// Not on the parent because directional opacity does NOT WORK
	opacity = TRUE

/obj/structure/window/reinforced/fulltile/ice
	icon = 'icons/obj/smooth_structures/rice_window.dmi'
	icon_state = "rice_window-0"
	base_icon_state = "rice_window"
	max_integrity = 150
	glass_amount = 2

//there is a sub shuttle window in survival_pod.dm for mining pods
/obj/structure/window/reinforced/shuttle//this is called reinforced because it is reinforced w/titanium
	name = "shuttle window"
	desc = "A reinforced, air-locked pod window."
	icon = 'icons/obj/smooth_structures/shuttle_window.dmi'
	icon_state = "shuttle_window-0"
	base_icon_state = "shuttle_window"
	max_integrity = 150
	wtype = "shuttle"
	reinf = TRUE
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	reinf = TRUE
	heat_resistance = 1600
	armor_type = /datum/armor/reinforced_shuttle
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE
	explosion_block = 3
	glass_type = /obj/item/stack/sheet/titaniumglass
	glass_amount = 2
	receive_ricochet_chance_mod = 1.2
	rad_insulation = RAD_MEDIUM_INSULATION
	glass_material_datum = /datum/material/alloy/titaniumglass

/datum/armor/reinforced_shuttle
	melee = 90
	bomb = 50
	fire = 80
	acid = 100

/obj/structure/window/reinforced/shuttle/narsie_act()
	add_atom_colour("#3C3434", FIXED_COLOUR_PRIORITY)

/obj/structure/window/reinforced/shuttle/tinted
	opacity = TRUE

/obj/structure/window/reinforced/shuttle/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced/shuttle/indestructible
	name = "hardened shuttle window"
	flags_1 = PREVENT_CLICK_UNDER_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/window/reinforced/shuttle/indestructible/welder_act(mob/living/user, obj/item/tool)
	return NONE

/obj/structure/window/reinforced/shuttle/indestructible/screwdriver_act(mob/living/user, obj/item/tool)
	return NONE

/obj/structure/window/reinforced/shuttle/indestructible/wrench_act(mob/living/user, obj/item/tool)
	return NONE

/obj/structure/window/reinforced/shuttle/indestructible/crowbar_act(mob/living/user, obj/item/tool)
	return NONE

/obj/structure/window/reinforced/plasma/plastitanium
	name = "plastitanium window"
	desc = "A durable looking window made of an alloy of plasma and titanium."
	icon = 'icons/obj/smooth_structures/plastitanium_window.dmi'
	icon_state = "plastitanium_window-0"
	base_icon_state = "plastitanium_window"
	max_integrity = 1200
	wtype = "shuttle"
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	heat_resistance = 1600
	armor_type = /datum/armor/plasma_plastitanium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM
	explosion_block = 3
	damage_deflection = 21 //The same as reinforced plasma windows.3
	glass_type = /obj/item/stack/sheet/plastitaniumglass
	glass_amount = 2
	rad_insulation = RAD_EXTREME_INSULATION
	glass_material_datum = /datum/material/alloy/plastitaniumglass

/obj/structure/window/reinforced/plasma/plastitanium/indestructible
	name = "plastitanium window"
	desc = "A durable looking window made of an alloy of plasma and titanium."
	icon = 'icons/obj/smooth_structures/plastitanium_window.dmi'
	icon_state = "plastitanium_window-0"
	base_icon_state = "plastitanium_window"
	max_integrity = 1200
	wtype = "shuttle"
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	heat_resistance = 1600
	armor_type = /datum/armor/plasma_plastitanium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM
	explosion_block = 3
	damage_deflection = 21 //The same as reinforced plasma windows.3
	glass_type = /obj/item/stack/sheet/plastitaniumglass
	glass_amount = 2
	rad_insulation = RAD_EXTREME_INSULATION
	glass_material_datum = /datum/material/alloy/plastitaniumglass
	name = "hardened shuttle window"
	flags_1 = PREVENT_CLICK_UNDER_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/datum/armor/plasma_plastitanium
	melee = 95
	bomb = 50
	fire = 80
	acid = 100

/obj/structure/window/reinforced/plasma/plastitanium/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/paperframe
	name = "paper frame"
	desc = "A fragile separator made of thin wood and paper."
	icon = 'icons/obj/smooth_structures/paperframes.dmi'
	icon_state = "paperframes-0"
	base_icon_state = "paperframes"
	opacity = TRUE
	max_integrity = 15
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_PAPERFRAME
	canSmoothWith = SMOOTH_GROUP_PAPERFRAME
	glass_amount = 2
	glass_type = /obj/item/stack/sheet/paperframes
	heat_resistance = 233
	decon_speed = 10
	can_atmos_pass = ATMOS_PASS_YES
	resistance_flags = FLAMMABLE
	armor_type = /datum/armor/none
	knock_sound = SFX_PAGE_TURN
	bash_sound = 'sound/items/weapons/slashmiss.ogg'
	break_sound = 'sound/items/poster/poster_ripped.ogg'
	hit_sound = 'sound/items/weapons/slashmiss.ogg'
	var/static/mutable_appearance/torn = mutable_appearance('icons/obj/smooth_structures/structure_variations.dmi',icon_state = "paper-torn", layer = ABOVE_OBJ_LAYER - 0.1)
	var/static/mutable_appearance/paper = mutable_appearance('icons/obj/smooth_structures/structure_variations.dmi',icon_state = "paper-whole", layer = ABOVE_OBJ_LAYER - 0.1)

/obj/structure/window/paperframe/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/window/paperframe/examine(mob/user)
	. = ..()
	if(atom_integrity < max_integrity)
		. += span_info("It looks a bit damaged, you may be able to fix it with some <b>paper</b>.")

/obj/structure/window/paperframe/spawn_debris(location)
	. = list(new /obj/item/stack/sheet/mineral/wood(location))
	for (var/i in 1 to rand(1,4))
		. += new /obj/item/paper/natural(location)

/obj/structure/window/paperframe/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(user.combat_mode)
		take_damage(4, BRUTE, MELEE, 0)
		if(!QDELETED(src))
			update_appearance()

/obj/structure/window/paperframe/update_appearance(updates)
	. = ..()
	set_opacity(atom_integrity >= max_integrity)

/obj/structure/window/paperframe/update_icon(updates=ALL)
	. = ..()
	if((updates & UPDATE_SMOOTHING) && (smoothing_flags & USES_SMOOTHING))
		QUEUE_SMOOTH(src)

/obj/structure/window/paperframe/update_overlays()
	. = ..()
	. += (atom_integrity < max_integrity) ? torn : paper

/obj/structure/window/paperframe/attackby(obj/item/W, mob/living/user)
	if(W.get_temperature())
		fire_act(W.get_temperature())
		return
	if(user.combat_mode)
		return ..()
	if(istype(W, /obj/item/paper) && atom_integrity < max_integrity)
		user.visible_message(span_notice("[user] starts to patch the holes in \the [src]."))
		if(do_after(user, 2 SECONDS, target = src))
			atom_integrity = min(atom_integrity+4,max_integrity)
			qdel(W)
			user.visible_message(span_notice("[user] patches some of the holes in \the [src]."))
			if(atom_integrity == max_integrity)
				update_appearance()
			return
	..()
	update_appearance()

/obj/structure/window/bronze
	name = "brass window"
	desc = "A paper-thin pane of translucent yet reinforced brass. Nevermind, this is just weak bronze!"
	icon = 'icons/obj/smooth_structures/structure_variations.dmi'
	icon_state = "clockwork_window-single"
	glass_type = /obj/item/stack/sheet/bronze

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/bronze/spawner, 0)

/obj/structure/window/bronze/unanchored
	anchored = FALSE

/obj/structure/window/bronze/fulltile
	icon = 'icons/obj/smooth_structures/clockwork_window.dmi'
	icon_state = "clockwork_window-0"
	base_icon_state = "clockwork_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE_BRONZE + SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE_BRONZE
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	max_integrity = 50
	glass_amount = 2

/obj/structure/window/bronze/fulltile/unanchored
	anchored = FALSE
