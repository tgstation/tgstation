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
	/// List of mobs currently leaning on our parent
	var/list/leaning_mobs = list()

/datum/component/leanable/Initialize(leaning_offset = 11, list/click_mods = null, datum/callback/lean_check = null, same_turf = FALSE)
	. = ..()
	src.leaning_offset = leaning_offset
	src.click_mods = click_mods
	src.lean_check = lean_check
	src.same_turf = same_turf

/datum/component/leanable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOUSEDROPPED_ONTO, PROC_REF(mousedrop_receive))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/datum/component/leanable/Destroy(force)
	for (var/mob/living/leaner as anything in leaning_mobs)
		leaner.stop_leaning()
	leaning_mobs = null
	return ..()

/datum/component/leanable/proc/on_moved(datum/source)
	SIGNAL_HANDLER
	for (var/mob/living/leaner as anything in leaning_mobs)
		leaner.stop_leaning()

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
	if (INCAPACITATED_IGNORING(leaner, INCAPABLE_RESTRAINTS) || leaner.stat != CONSCIOUS || HAS_TRAIT(leaner, TRAIT_NO_TRANSFORM))
		return
	if (HAS_TRAIT_FROM(leaner, TRAIT_UNDENSE, LEANING_TRAIT))
		return
	var/turf/checked_turf = get_step(leaner, REVERSE_DIR(leaner.dir))
	if (checked_turf != get_turf(source) && (!same_turf || get_turf(source) != get_turf(leaner)))
		return
	if (!isnull(lean_check) && !lean_check.Invoke(dropped, params))
		return
	leaner.start_leaning(source, leaning_offset)
	leaning_mobs += leaner
	RegisterSignals(leaner, list(COMSIG_LIVING_STOPPED_LEANING, COMSIG_QDELETING), PROC_REF(stopped_leaning))
	return COMPONENT_CANCEL_MOUSEDROPPED_ONTO

/datum/component/leanable/proc/stopped_leaning(datum/source)
	SIGNAL_HANDLER
	leaning_mobs -= source
	UnregisterSignal(source, list(COMSIG_LIVING_STOPPED_LEANING, COMSIG_QDELETING))

/mob/living/proc/start_leaning(atom/lean_target, leaning_offset)
	var/new_x = lean_target.pixel_x + base_pixel_x + body_position_pixel_x_offset
	var/new_y = lean_target.pixel_y + base_pixel_y + body_position_pixel_y_offset
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
	), PROC_REF(stop_leaning))

	RegisterSignal(src, COMSIG_MOVABLE_TELEPORTED, PROC_REF(teleport_away_while_leaning))
	RegisterSignal(src, COMSIG_ATOM_POST_DIR_CHANGE, PROC_REF(lean_dir_changed))
	update_fov()

/// You fall on your face if you get teleported while leaning
/mob/living/proc/teleport_away_while_leaning()
	SIGNAL_HANDLER
	// Make sure we unregister signal handlers and reset animation
	stop_leaning()
	// -1000 aura
	visible_message(span_notice("[src] falls flat on [p_their()] face from losing [p_their()] balance!"), span_warning("You fall suddenly as the object you were leaning on vanishes from contact with you!"))
	Knockdown(3 SECONDS)

/mob/living/proc/stop_leaning()
	SIGNAL_HANDLER
	UnregisterSignal(src, list(
		COMSIG_MOB_CLIENT_PRE_MOVE,
		COMSIG_LIVING_DISARM_HIT,
		COMSIG_LIVING_GET_PULLED,
		COMSIG_ATOM_POST_DIR_CHANGE,
		COMSIG_MOVABLE_TELEPORTED,
	))
	animate(src, 0.2 SECONDS, pixel_x = base_pixel_x + body_position_pixel_x_offset, pixel_y = base_pixel_y + body_position_pixel_y_offset)
	remove_traits(list(TRAIT_UNDENSE, TRAIT_EXPANDED_FOV), LEANING_TRAIT)
	SEND_SIGNAL(src, COMSIG_LIVING_STOPPED_LEANING)
	update_fov()

/mob/living/proc/lean_dir_changed(atom/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if (old_dir != new_dir)
		INVOKE_ASYNC(src, PROC_REF(stop_leaning))
