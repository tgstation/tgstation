/// Things with this component can be leaned onto, optionally exclusive to RMB dragging
/datum/component/leanable
	/// How much will mobs that lean onto this object be offset
	var/leaning_offset = 11
	/// List of click modifiers that are required to be present for leaning to trigger
	var/list/click_mods = null
	/// Callback called for additional checks if a lean is valid
	var/datum/callback/lean_check = null
	/// Whenever this object can be leaned on from the same turf as its' own. Do not use without a custom lean_check!
	var/same_turf = FALSE

/datum/component/leanable/Initialize(leaning_offset = 11, list/click_mods = null, datum/callback/lean_check = null, same_turf = FALSE)
	. = ..()
	src.leaning_offset = leaning_offset
	src.click_mods = click_mods
	src.lean_check = lean_check
	src.same_turf = same_turf

/datum/component/leanable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOUSEDROPPED_ONTO, PROC_REF(mousedrop_receive))

/datum/component/leanable/proc/mousedrop_receive(atom/source, atom/movable/dropped, mob/user, params)
	if (dropped != user)
		return
	if (islist(click_mods))
		var/list/modifiers = params2list(params)
		for (var/modifier in click_mods)
			if (!LAZYACCESS(modifiers, modifier))
				return
	if (!iscarbon(dropped) && !iscyborg(dropped))
		return
	var/mob/living/leaner = dropped
	if (leaner.incapacitated(IGNORE_RESTRAINTS) || leaner.stat != CONSCIOUS || HAS_TRAIT(leaner, TRAIT_NO_TRANSFORM))
		return
	if (HAS_TRAIT_FROM(leaner, TRAIT_UNDENSE, LEANING_TRAIT))
		return
	var/turf/checked_turf = get_step(leaner, REVERSE_DIR(leaner.dir))
	if (checked_turf != get_turf(source) && (!same_turf || get_turf(source) != get_turf(leaner)))
		return
	if (!isnull(lean_check) && !lean_check.Invoke(dropped, params))
		return
	leaner.start_leaning(source, leaning_offset)
	return COMPONENT_CANCEL_MOUSEDROPPED_ONTO

/mob/living/proc/start_leaning(atom/lean_target, leaning_offset)
	var/new_y = base_pixel_y + pixel_y
	var/new_x = base_pixel_x + pixel_x
	switch(dir)
		if(SOUTH)
			new_y += leaning_offset
		if(NORTH)
			new_y -= leaning_offset
		if(WEST)
			new_x += leaning_offset
		if(EAST)
			new_x -= leaning_offset

	animate(src, 0.2 SECONDS, pixel_x = new_x, pixel_y = new_y)
	add_traits(list(TRAIT_UNDENSE, TRAIT_EXPANDED_FOV), LEANING_TRAIT)
	visible_message(
		span_notice("[src] leans against [lean_target]."),
		span_notice("You lean against [lean_target]."),
	)
	RegisterSignals(src, list(
		COMSIG_MOB_CLIENT_PRE_MOVE,
		COMSIG_LIVING_DISARM_HIT,
		COMSIG_LIVING_GET_PULLED,
		COMSIG_MOVABLE_TELEPORTING,
		COMSIG_ATOM_DIR_CHANGE,
	), PROC_REF(stop_leaning))
	update_fov()

/mob/living/proc/stop_leaning()
	SIGNAL_HANDLER
	UnregisterSignal(src, list(
		COMSIG_MOB_CLIENT_PRE_MOVE,
		COMSIG_LIVING_DISARM_HIT,
		COMSIG_LIVING_GET_PULLED,
		COMSIG_MOVABLE_TELEPORTING,
		COMSIG_ATOM_DIR_CHANGE,
	))
	animate(src, 0.2 SECONDS, pixel_x = base_pixel_x, pixel_y = base_pixel_y)
	remove_traits(list(TRAIT_UNDENSE, TRAIT_EXPANDED_FOV), LEANING_TRAIT)
	update_fov()
