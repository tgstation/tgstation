/turf/closed/wall/concrete
	name = "concrete wall"
	desc = "A thick wall made of concrete, poured around steel supports."
	icon = 'icons/turf/walls/concrete.dmi'
	icon_state = "concrete-0"
	base_icon_state = "concrete"
	explosive_resistance = 2
	rad_insulation = RAD_MEDIUM_INSULATION
	rust_resistance = RUST_RESISTANCE_REINFORCED

	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_CONCRETE_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_CONCRETE_WALLS
	hardness = 30

	sheet_type = /obj/item/stack/ore/glass/concrete_powder
	sheet_amount = 2
	girder_type = /obj/structure/grille
	break_sound = 'sound/effects/break_stone.ogg'

	/// Time to fully cure
	var/time_to_harden = 60 SECONDS
	/// fraction ranging from 0 to 1 -- 0 is fully soft, 1 is fully hardened
	/// don't change this in subtypes unless you want them to spawn in soft on maps
	var/harden_lvl = 1

/turf/closed/wall/concrete/Initialize(mapload)
	. = ..()
	check_harden()

/turf/closed/wall/concrete/deconstruction_hints(mob/user)
	. = list()
	. += span_notice("[p_They()] look[p_s()] like you could smash [p_them()] with <b>[tool_behaviour_name(TOOL_MINING)]</b>.")
	switch(harden_lvl)
		if(0.8 to 0.99)
			. += "[p_They()] look[p_s()] nearly dry."
		if(0.4 to 0.8)
			. += "[p_They()] look[p_s()] a little wet."
		if(0 to 0.4)
			. += "[p_They()] look[p_s()] freshly poured."
	return

/turf/closed/wall/concrete/try_clean(obj/item/W, mob/living/user)
	// You can't weld dents on concrete wall
	return FALSE

/turf/closed/wall/concrete/try_decon(obj/item/I, mob/user)
	if (I.tool_behaviour == TOOL_MINING)
		to_chat(user, span_notice("You begin breaking the wall..."))
		if(I.use_tool(src, user, slicing_duration, volume=100))
			// break_prob decreases linearly from 100 to hardness as it cures
			var/break_prob = hardness + (1 - harden_lvl) * (100 - hardness)
			if(prob(break_prob))
				to_chat(user, span_notice("You break the wall."))
				dismantle_wall()
				new /obj/effect/decal/cleanable/concrete_dust(src)
			else
				add_dent(WALL_DENT_HIT)
				playsound(src, break_sound, 50, TRUE)

			return TRUE

	return FALSE

/turf/closed/wall/concrete/break_wall()
	var/atom/girder = ..()
	girder.atom_break()
	return girder

/turf/closed/wall/concrete/update_icon(updates=ALL)
	. = ..()
	if(!.)
		return
	remove_filter("harden")
	if(harden_lvl == 1)
		return

	var/offset = (1 - harden_lvl) * 0.4
	var/base = 1 - offset
	var/col_filter = list(base, 0, 0, 0, base, 0, 0, 0, base, offset, offset, offset)
	add_filter("harden", 1, color_matrix_filter(col_filter, FILTER_COLOR_RGB))
	return

/turf/closed/wall/concrete/proc/check_harden()
	harden_lvl = clamp(harden_lvl, 0, 1)
	if(harden_lvl < 1)
		START_PROCESSING(SSobj, src)
		update_icon(UPDATE_ICON_STATE)

/turf/closed/wall/concrete/process(seconds_per_tick)
	var/time_per_tick = seconds_per_tick SECONDS
	harden_lvl = min(harden_lvl + (time_per_tick / time_to_harden), 1)
	if(harden_lvl == 1)
		STOP_PROCESSING(SSobj, src)
	update_icon(UPDATE_ICON_STATE)

/turf/closed/wall/concrete/reinforced
	name = "hexacrete wall"
	desc = "A thick wall made of steel-reinforced hexacrete. Sturdier than a normal concrete wall."
	icon = 'icons/turf/walls/hexacrete.dmi'
	icon_state = "hexacrete-0"
	base_icon_state = "hexacrete"

	hardness = 15
	explosive_resistance = 3
	rad_insulation = RAD_HEAVY_INSULATION
	rust_resistance = RUST_RESISTANCE_REINFORCED
	girder_type = /obj/structure/girder

	time_to_harden = 60 SECONDS

/turf/closed/wall/concrete/reinforced/rcd_vals(...)
	return call(src, /turf/closed/wall/r_wall::rcd_vals())(arglist(args))

/turf/closed/wall/concrete/reinforced/rcd_act(...)
	return call(src, /turf/closed/wall/r_wall::rcd_act())(arglist(args))

/turf/closed/wall/concrete/reinforced/rust_turf(magic = FALSE)
	return call(src, /turf/closed/wall/r_wall::rust_turf())(magic)

