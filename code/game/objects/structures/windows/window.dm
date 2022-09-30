/obj/structure/window
	name = "window"
	desc = "A window."
	icon = 'icons/obj/structures_tall.dmi'
	icon_state = "window"
	density = TRUE
	layer = ABOVE_OBJ_LAYER //Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = TRUE //initially is 0 for tile smoothing
	flags_1 = ON_BORDER_1 | RAD_PROTECT_CONTENTS_1
	max_integrity = 25
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 100)
	can_atmos_pass = ATMOS_PASS_PROC
	rad_insulation = RAD_VERY_LIGHT_INSULATION
	pass_flags_self = PASSGLASS
	set_dir_on_move = FALSE
	var/state = WINDOW_OUT_OF_FRAME
	var/reinf = FALSE
	var/heat_resistance = 800
	var/decon_speed = 30
	var/wtype = "glass"
	var/fulltile = FALSE
	var/glass_type = /obj/item/stack/sheet/glass
	var/shard_type = /obj/item/shard
	var/glass_amount = 1
	var/mutable_appearance/crack_overlay
	var/real_explosion_block //ignore this, just use explosion_block
	var/breaksound = "shatter"
	var/knocksound = 'sound/effects/Glassknock.ogg'
	var/bashsound = 'sound/effects/Glassbash.ogg'
	var/hitsound = 'sound/effects/Glasshit.ogg'
	flags_ricochet = RICOCHET_HARD
	receive_ricochet_chance_mod = 0.5

/obj/structure/window/examine(mob/user)
	. = ..()
	if(reinf)
		if(anchored && state == WINDOW_SCREWED_TO_FRAME)
			. += span_notice("The window is <b>screwed</b> to the frame.")
		else if(anchored && state == WINDOW_IN_FRAME)
			. += span_notice("The window is <i>unscrewed</i> but <b>pried</b> into the frame.")
		else if(anchored && state == WINDOW_OUT_OF_FRAME)
			. += span_notice("The window is out of the frame, but could be <i>pried</i> in. It is <b>screwed</b> to [src].")
		else if(!anchored)
			. += span_notice("The window is <i>unscrewed</i> from [src], and could be deconstructed by <b>wrenching</b>.")
	else
		if(anchored)
			. += span_notice("The window is <b>screwed</b> to [src].")
		else
			. += span_notice("The window is <i>unscrewed</i> from [src], and could be deconstructed by <b>wrenching</b>.")

/obj/structure/window/Initialize(mapload, direct)
	. = ..()
	if(direct)
		setDir(direct)
	if(reinf && anchored)
		state = RWINDOW_SECURE

	air_update_turf(TRUE, TRUE)

	if(fulltile)
		setDir()
		update_icon_state()

	//windows only block while reinforced and fulltile, so we'll use the proc
	real_explosion_block = explosion_block
	explosion_block = EXPLOSION_BLOCK_PROC

	flags_1 |= ALLOW_DARK_PAINTS_1
	RegisterSignal(src, COMSIG_OBJ_PAINTED, .proc/on_painted)
	AddElement(/datum/element/atmos_sensitive, mapload)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = .proc/on_exit,
	)

	if (flags_1 & ON_BORDER_1)
		AddElement(/datum/element/connect_loc, loc_connections)

	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS ,null,CALLBACK(src, .proc/can_be_rotated),CALLBACK(src,.proc/after_rotation))

/obj/structure/window/Moved(atom/OldLoc, Dir)
	. = ..()
	if(fulltile)
		update_icon_state()

/obj/structure/window/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 20, "cost" = 5)
	return FALSE

/obj/structure/window/rcd_act(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, span_notice("You deconstruct the window."))
			qdel(src)
			return TRUE
	return FALSE

/obj/structure/window/narsie_act()
	add_atom_colour(NARSIE_WINDOW_COLOUR, FIXED_COLOUR_PRIORITY)

/obj/structure/window/singularity_pull(S, current_size)
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
		return valid_window_location(loc, moved_window.dir, is_fulltile = moved_window.fulltile)

	if(istype(mover, /obj/structure/windoor_assembly) || istype(mover, /obj/machinery/door/window))
		return valid_window_location(loc, mover.dir, is_fulltile = FALSE)

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
	playsound(src, knocksound, 50, TRUE)
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
		playsound(src, knocksound, 50, TRUE)
	else
		user.visible_message(span_warning("[user] bashes [src]!"), \
			span_warning("You bash [src]!"))
		playsound(src, bashsound, 100, TRUE)

/obj/structure/window/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/window/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1) //used by attack_alien, attack_animal, and attack_slime
	if(!can_be_reached(user))
		return
	..()

/obj/structure/window/attackby(obj/item/I, mob/living/user, params)
	if(!can_be_reached(user))
		return TRUE //skip the afterattack

	add_fingerprint(user)

	var/obj/structure/window_frame/our_frame = locate() in loc

	if(I.tool_behaviour == TOOL_WELDER)
		if(atom_integrity < max_integrity)
			if(!I.tool_start_check(user, amount = 0))
				return

			to_chat(user, span_notice("You begin repairing [src]..."))
			if(I.use_tool(src, user, 40, volume = 50))
				atom_integrity = max_integrity
				update_nearby_icons()
				to_chat(user, span_notice("You repair [src]."))
		else
			to_chat(user, span_warning("[src] is already in good condition!"))
		return

	if(!(flags_1 & NODECONSTRUCT_1) && !(reinf && state >= RWINDOW_FRAME_BOLTED))
		if(I.tool_behaviour == TOOL_SCREWDRIVER)
			if(fulltile && !anchored && !our_frame)
				to_chat(user, span_notice("You can only secure this window to a window frame!"))
				return

			to_chat(user, span_notice("You begin to [anchored ? "unscrew the window from":"screw the window to"] [our_frame]..."))
			if(I.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, .proc/check_anchored, anchored)))
				set_anchored(!anchored)
				to_chat(user, span_notice("You [anchored ? "fasten the window to":"unfasten the window from"] [our_frame]."))
			return

		else if(I.tool_behaviour == TOOL_WRENCH && !anchored)
			to_chat(user, span_notice("You begin to disassemble [src]..."))
			if(I.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, .proc/check_state_and_anchored, state, anchored)))
				var/obj/item/stack/sheet/G = new glass_type(user.loc, glass_amount)
				G.add_fingerprint(user)
				playsound(src, 'sound/items/Deconstruct.ogg', 50, TRUE)
				to_chat(user, span_notice("You successfully disassemble [src]."))
				qdel(src)
			return

		else if(I.tool_behaviour == TOOL_CROWBAR && reinf && (state == WINDOW_OUT_OF_FRAME) && anchored)
			to_chat(user, span_notice("You begin to lever the window into the frame..."))
			if(I.use_tool(src, user, 100, volume = 75, extra_checks = CALLBACK(src, .proc/check_state_and_anchored, state, anchored)))
				state = RWINDOW_SECURE
				to_chat(user, span_notice("You pry the window into the frame."))
			return

	return ..()

/obj/structure/window/set_anchored(anchorvalue)
	. = ..()
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


/obj/structure/window/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(.) //received damage
		update_nearby_icons()

/obj/structure/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, hitsound, 75, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/Welder.ogg', 100, TRUE)


/obj/structure/window/deconstruct(disassembled = TRUE)
	if(QDELETED(src))
		return
	if(!disassembled)
		playsound(src, breaksound, 70, TRUE)
		if(!(flags_1 & NODECONSTRUCT_1))
			for(var/obj/item/shard/debris in spawnDebris(drop_location()))
				transfer_fingerprints_to(debris) // transfer fingerprints to shards only
	qdel(src)
	update_nearby_icons()

/obj/structure/window/proc/spawnDebris(location)
	. = list()
	. += new /obj/item/shard(location)
	. += new /obj/effect/decal/cleanable/glass(location)
	if (reinf)
		. += new /obj/item/stack/rods(location, (fulltile ? 2 : 1))
	if (fulltile)
		. += new /obj/item/shard(location)

/obj/structure/window/proc/can_be_rotated(mob/user,rotation_type)
	if(anchored)
		var/fastened_to = loc
		if(fulltile)
			fastened_to = locate(/obj/structure/window_frame) in loc

		to_chat(user, span_warning("[src] cannot be rotated while it is fastened to [fastened_to]!"))
		return FALSE

	var/target_dir = turn(dir, rotation_type == ROTATION_CLOCKWISE ? -90 : 90)

	if(!valid_window_location(loc, target_dir, is_fulltile = fulltile))
		to_chat(user, span_warning("[src] cannot be rotated in that direction!"))
		return FALSE
	return TRUE

/obj/structure/window/proc/after_rotation(mob/user,rotation_type)
	air_update_turf(TRUE, FALSE)
	add_fingerprint(user)

/obj/structure/window/proc/on_painted(obj/structure/window/source, is_dark_color)
	SIGNAL_HANDLER
	if (is_dark_color && fulltile) //Opaque directional windows restrict vision even in directions they are not placed in, please don't do this
		set_opacity(255)
	else
		set_opacity(initial(opacity))

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

/obj/structure/window/can_atmos_pass(turf/T)
	if(!anchored || !density)
		return TRUE
	return !(fulltile || dir == get_dir(loc, T))

//This proc is used to update the icons of nearby windows.
/obj/structure/window/proc/update_nearby_icons()
	update_appearance()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/window/update_icon_state()
	. = ..()
	if(!fulltile)
		return

	if(locate(/obj/structure/window_frame) in loc)
		pixel_y = WINDOW_ON_FRAME_Y_OFFSET
	else
		pixel_y = WINDOW_OFF_FRAME_Y_OFFSET

//merges adjacent full-tile windows into one
/obj/structure/window/update_overlays(updates=ALL)
	. = ..()
	if(QDELETED(src) || !fulltile)
		return

	if((updates & UPDATE_SMOOTHING) && (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
		QUEUE_SMOOTH(src)

	var/ratio = atom_integrity / max_integrity
	ratio = CEILING(ratio*4, 1) * 25
	cut_overlay(crack_overlay)
	if(ratio > 75)
		return
	crack_overlay = mutable_appearance('icons/obj/structures.dmi', "damage[ratio]", -(layer+0.1))
	. += crack_overlay

/obj/structure/window/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > T0C + heat_resistance

/obj/structure/window/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(round(air.return_volume() / 100), BURN, 0, 0)

/obj/structure/window/get_dumping_location(obj/item/storage/source,mob/user)
	return null

/obj/structure/window/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/caller)
	if(!density)
		return TRUE
	if(fulltile || (dir == to_dir))
		return FALSE

	return TRUE

/obj/structure/window/GetExplosionBlock()
	return reinf && fulltile ? real_explosion_block : 0

/obj/structure/window/spawner/east
	dir = EAST

/obj/structure/window/spawner/west
	dir = WEST

/obj/structure/window/spawner/north
	dir = NORTH

/obj/structure/window/unanchored
	anchored = FALSE

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "A window that is reinforced with metal rods."
	icon_state = "rwindow"
	reinf = TRUE
	heat_resistance = 1600
	armor = list(MELEE = 80, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 25, BIO = 100, RAD = 100, FIRE = 80, ACID = 100)
	max_integrity = 75
	explosion_block = 1
	damage_deflection = 11
	state = RWINDOW_SECURE
	glass_type = /obj/item/stack/sheet/rglass
	rad_insulation = RAD_HEAVY_INSULATION
	receive_ricochet_chance_mod = 1.1

//this is shitcode but all of construction is shitcode and needs a refactor, it works for now
//If you find this like 4 years later and construction still hasn't been refactored, I'm so sorry for this //Adding a timestamp, I found this in 2020, I hope it's from this year -Lemon
//2021 AND STILLLL GOING STRONG
/obj/structure/window/reinforced/attackby_secondary(obj/item/tool, mob/user, params)
	switch(state)
		if(RWINDOW_SECURE)
			if(tool.tool_behaviour == TOOL_WELDER)
				var/obj/item/weldingtool/welder = tool
				if(welder.isOn())
					user.visible_message(span_notice("[user] holds \the [tool] to the security screws on \the [src]..."),
						span_notice("You begin heating the security screws on \the [src]..."))
				if(tool.use_tool(src, user, 150, volume = 100))
					to_chat(user, span_notice("The security screws are glowing white hot and look ready to be removed."))
					state = RWINDOW_BOLTS_HEATED
					addtimer(CALLBACK(src, .proc/cool_bolts), 300)
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

/obj/structure/window/proc/cool_bolts()
	if(state == RWINDOW_BOLTS_HEATED)
		state = RWINDOW_SECURE
		visible_message(span_notice("The bolts on \the [src] look like they've cooled off..."))

/obj/structure/window/reinforced/examine(mob/user)
	. = ..()
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

/obj/structure/window/reinforced/spawner/east
	dir = EAST

/obj/structure/window/reinforced/spawner/west
	dir = WEST

/obj/structure/window/reinforced/spawner/north
	dir = NORTH

/obj/structure/window/reinforced/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/plasma
	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through."
	icon_state = "plasmawindow"
	reinf = FALSE
	heat_resistance = 25000
	armor = list(MELEE = 80, BULLET = 5, LASER = 0, ENERGY = 0, BOMB = 45, BIO = 100, RAD = 100, FIRE = 99, ACID = 100)
	max_integrity = 200
	explosion_block = 1
	glass_type = /obj/item/stack/sheet/plasmaglass
	rad_insulation = RAD_NO_INSULATION

/obj/structure/window/plasma/Initialize(mapload, direct)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive)

/obj/structure/window/plasma/spawnDebris(location)
	. = list()
	. += new /obj/item/shard/plasma(location)
	. += new /obj/effect/decal/cleanable/glass/plasma(location)
	if (reinf)
		. += new /obj/item/stack/rods(location, (fulltile ? 2 : 1))
	if (fulltile)
		. += new /obj/item/shard/plasma(location)

/obj/structure/window/plasma/spawner/east
	dir = EAST

/obj/structure/window/plasma/spawner/west
	dir = WEST

/obj/structure/window/plasma/spawner/north
	dir = NORTH

/obj/structure/window/plasma/unanchored
	anchored = FALSE

/obj/structure/window/reinforced/plasma
	name = "reinforced plasma window"
	desc = "A window made out of a plasma-silicate alloy and a rod matrix. It looks hopelessly tough to break and is most likely nigh fireproof."
	icon_state = "plasmarwindow"
	reinf = TRUE
	heat_resistance = 50000
	armor = list(MELEE = 80, BULLET = 20, LASER = 0, ENERGY = 0, BOMB = 60, BIO = 100, RAD = 100, FIRE = 99, ACID = 100)
	max_integrity = 500
	damage_deflection = 21
	explosion_block = 2
	glass_type = /obj/item/stack/sheet/plasmarglass

/obj/structure/window/reinforced/plasma/block_superconductivity()
	return TRUE

/obj/structure/window/reinforced/plasma/spawner/east
	dir = EAST

/obj/structure/window/reinforced/plasma/spawner/west
	dir = WEST

/obj/structure/window/reinforced/plasma/spawner/north
	dir = NORTH

/obj/structure/window/reinforced/plasma/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	icon_state = "twindow"
	opacity = TRUE
/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	icon_state = "fwindow"

/obj/structure/window/bronze
	name = "brass window"
	desc = "A paper-thin pane of translucent yet reinforced brass. Nevermind, this is just weak bronze!"
	icon = 'icons/obj/smooth_structures/clockwork_window.dmi'
	icon_state = "clockwork_window_single"
	glass_type = /obj/item/stack/sheet/bronze

/obj/structure/window/bronze/unanchored
	anchored = FALSE
