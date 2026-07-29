/turf/open/floor/concrete
	name = "concrete floor"
	desc = "Cold, bare concrete flooring."
	icon = 'icons/turf/floors/concrete.dmi'
	damaged_dmi = 'icons/turf/floors/concrete.dmi'
	icon_state = "conc_smooth_1"
	base_icon_state = "conc_smooth"
	baseturfs = /turf/open/floor/plating
	floor_tile = null
	footstep = FOOTSTEP_CONCRETE
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	leave_footprints = TRUE

	var/smash_time = 3 SECONDS
	/// Time to fully cure
	var/time_to_harden = 60 SECONDS
	/// fraction ranging from 0 to 1 -- 0 is fully soft, 1 is fully hardened
	/// don't change this in subtypes unless you want them to spawn in soft on maps
	var/harden_lvl = 1
	var/has_variation = TRUE

	var/shape_types = list(
		/turf/open/floor/concrete,
		/turf/open/floor/concrete/slab_1,
		/turf/open/floor/concrete/slab_2,
		/turf/open/floor/concrete/slab_3,
		/turf/open/floor/concrete/slab_4,
		/turf/open/floor/concrete/tiles
	)

/turf/open/floor/concrete/Initialize(mapload)
	. = ..()
	if(has_variation)
		icon_state = "[base_icon_state]_[rand(1,4)]"
	check_harden()
	update_icon(UPDATE_ICON_STATE)

/turf/open/floor/concrete/broken_states()
	return list("concdam_1", "concdam_2", "concdam_3", "concdam_4")

/turf/open/floor/concrete/examine(mob/user)
	. = ..()
	. += span_notice("[p_They()] look[p_s()] like you could smash [p_them()] with <b>[tool_behaviour_name(TOOL_MINING)]</b>.")
	switch(harden_lvl)
		if(0.8 to 0.99)
			. += "[p_They()] look[p_s()] nearly dry."
		if(0.4 to 0.8)
			. += "[p_They()] look[p_s()] a little wet."
		if(0 to 0.4)
			. += "[p_They()] look[p_s()] freshly poured."
	return

/turf/open/floor/concrete/add_footprint(mob/living/carbon/human/walker, movement_direction)
	if (harden_lvl <= 0.8)
		..()

/turf/open/floor/concrete/clear_footprints()
	if (harden_lvl <= 0.8)
		..()
	else
		update_appearance()

/turf/open/floor/concrete/attackby(obj/item/I, mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(I.tool_behaviour == TOOL_MINING)
		to_chat(user, span_notice("You start smashing [src]..."))
		var/adj_time = (broken || burnt) ? smash_time/2 : smash_time
		if(I.use_tool(src, user, adj_time, volume=30))
			new /obj/effect/decal/cleanable/concrete_dust(src)
			to_chat(user, span_notice("You break [src]."))
			playsound(src, 'sound/effects/break_stone.ogg', 30, TRUE)
			remove_tile(silent=TRUE)
			return TRUE
	return FALSE

/turf/open/floor/concrete/try_replace_tile(obj/item/stack/tile/T, mob/user, list/modifiers)
	return FALSE

/turf/open/floor/concrete/pry_tile(obj/item/I, mob/user, silent)
	return FALSE

/turf/open/floor/concrete/update_icon(updates=ALL)
	. = ..()
	if(!.)
		return
	remove_filter("harden")
	if(harden_lvl == 1)
		return

	var/offset = (1 - harden_lvl) * 0.3
	var/base = 1 - offset
	var/col_filter = list(base,0,0, 0,base,0, 0,0,base, offset, offset, offset)
	add_filter("harden", 1, color_matrix_filter(col_filter, FILTER_COLOR_RGB))
	return

/turf/open/floor/concrete/proc/check_harden()
	harden_lvl = clamp(harden_lvl, 0, 1)
	if(harden_lvl < 1)
		START_PROCESSING(SSobj, src)
		update_icon(UPDATE_ICON_STATE)

/turf/open/floor/concrete/process(seconds_per_tick)
	var/time_per_tick = seconds_per_tick SECONDS
	harden_lvl = min(harden_lvl + (time_per_tick / time_to_harden), 1)
	if(harden_lvl == 1)
		STOP_PROCESSING(SSobj, src)
	update_icon(UPDATE_ICON_STATE)

/turf/open/floor/concrete/proc/handle_shape(mob/user)
	if(harden_lvl >= 0.8)
		return FALSE
	var/list/opts = list()

	for(var/turf/open/floor/concrete/conc as anything in shape_types)
		opts[conc] = image(icon = initial(conc.icon), icon_state = initial(conc.icon_state))

	var/choice = show_radial_menu(
		user,
		src,
		opts,
		uniqueid = "concmenu_[REF(user)]",
		radius = 48,
		custom_check = CALLBACK(src, PROC_REF(check_menu), user),
		require_near = TRUE
	)
	if(!choice)
		return FALSE
	to_chat(user, "You reshape [src].")
	var/old_harden = harden_lvl
	var/turf/open/floor/concrete/newconc = ChangeTurf(choice, flags = CHANGETURF_INHERIT_AIR)
	newconc.harden_lvl = old_harden
	newconc.check_harden()
	newconc.update_appearance()
	return TRUE

/turf/open/floor/concrete/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated || !user.Adjacent(src))
		return FALSE
	return TRUE

/turf/open/floor/concrete/slab_1
	icon_state = "conc_slab_1"
	has_variation = FALSE

/turf/open/floor/concrete/slab_2
	icon_state = "conc_slab_2"
	has_variation = FALSE

/turf/open/floor/concrete/slab_3
	icon_state = "conc_slab_3"
	has_variation = FALSE

/turf/open/floor/concrete/slab_4
	icon_state = "conc_slab_4"
	has_variation = FALSE

/turf/open/floor/concrete/tiles
	icon_state = "conc_tiles"
	has_variation = FALSE

/turf/open/floor/concrete/reinforced
	name = "hexacrete floor"
	desc = "Reinforced hexacrete tiling."
	icon = 'icons/turf/floors/hexacrete.dmi'
	icon_state = "hexacrete-0"
	base_icon_state = "hexacrete"
	has_variation = FALSE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_OPEN_FLOOR + SMOOTH_GROUP_FLOOR_HEXACRETE
	canSmoothWith = SMOOTH_GROUP_FLOOR_HEXACRETE

	smash_time = 8 SECONDS
	time_to_harden = 90 SECONDS
	shape_types = list(/turf/open/floor/concrete/reinforced)
	slowdown = -0.3

/turf/open/floor/concrete/pavement
	name = "strip of pavement"
	desc = "Hot, coarse pavement. Preferred for roadways, as vehicles are generally quieter driven on this than on traditional concrete."
	icon_state = "pavement_1"
	base_icon_state = "pavement"
	shape_types = list(/turf/open/floor/concrete/pavement)
	slowdown = -0.2
