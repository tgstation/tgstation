/mob/living/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	update_turf_movespeed(loc)
	if(HAS_TRAIT(src, TRAIT_NEGATES_GRAVITY))
		if(!isgroundlessturf(loc))
			ADD_TRAIT(src, TRAIT_IGNORING_GRAVITY, IGNORING_GRAVITY_NEGATION)
		else
			REMOVE_TRAIT(src, TRAIT_IGNORING_GRAVITY, IGNORING_GRAVITY_NEGATION)

	var/turf/old_turf = get_turf(old_loc)
	var/turf/new_turf = get_turf(src)
	// If we're moving to/from nullspace, refresh
	// Easier then adding nullchecks to all this shit, and technically right since a null turf means nograv
	if(isnull(old_turf) || isnull(new_turf))
		if(!QDELING(src))
			refresh_gravity()
		return
	// If the turf gravity has changed, then it's possible that our state has changed, so update
	if(HAS_TRAIT(old_turf, TRAIT_FORCED_GRAVITY) != HAS_TRAIT(new_turf, TRAIT_FORCED_GRAVITY) || new_turf.force_no_gravity != old_turf.force_no_gravity)
		refresh_gravity()

	// Going to do area gravity checking here
	var/area/old_area = old_turf.loc
	var/area/new_area = new_turf.loc
	// If the area gravity has changed, then it's possible that our state has changed, so update
	if(old_area.default_gravity != new_area.default_gravity)
		refresh_gravity()

/mob/living/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()

	if(!old_turf || !new_turf || SSmapping.gravity_by_z_level[old_turf.z] != SSmapping.gravity_by_z_level[new_turf.z])
		refresh_gravity()

/// Living Mob use event based gravity
/// We check here to ensure we haven't dropped any gravity changes
/mob/living/proc/gravity_setup()
	on_negate_gravity(src)
	refresh_gravity()

/// Handles gravity effects. Call if something about our gravity has potentially changed!
/mob/living/proc/refresh_gravity()
	var/old_grav_state = gravity_state
	gravity_state = has_gravity()
	if(gravity_state == old_grav_state)
		return

	update_gravity(gravity_state)

	if(gravity_state > STANDARD_GRAVITY)
		gravity_animate()
	else if(old_grav_state > STANDARD_GRAVITY)
		remove_filter("gravity")

/mob/living/mob_negates_gravity()
	return HAS_TRAIT_FROM(src, TRAIT_IGNORING_GRAVITY, IGNORING_GRAVITY_NEGATION)

/mob/living/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return
	if(mover.throwing)
		var/mob/thrower = mover.throwing.get_thrower()
		return (!density || (body_position == LYING_DOWN) || (thrower == src && !ismob(mover)))
	if(buckled == mover)
		return TRUE
	if(ismob(mover) && (mover in buckled_mobs))
		return TRUE
	return !mover.density || body_position == LYING_DOWN

/mob/living/update_config_movespeed()
	update_move_intent_slowdown()
	return ..()

/mob/living/proc/update_move_intent_slowdown()
	add_movespeed_modifier((move_intent == MOVE_INTENT_WALK)? /datum/movespeed_modifier/config_walk_run/walk : /datum/movespeed_modifier/config_walk_run/run)

/mob/living/proc/update_turf_movespeed(turf/open/turf)
	if(isopenturf(turf) && !HAS_TRAIT(turf, TRAIT_TURF_IGNORE_SLOWDOWN))
		if(turf.slowdown != current_turf_slowdown)
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/turf_slowdown, multiplicative_slowdown = turf.slowdown)
			current_turf_slowdown = turf.slowdown
	else if(current_turf_slowdown)
		remove_movespeed_modifier(/datum/movespeed_modifier/turf_slowdown)
		current_turf_slowdown = 0

/mob/living/proc/update_pull_movespeed()
	SEND_SIGNAL(src, COMSIG_LIVING_UPDATING_PULL_MOVESPEED)

	if(pulling)
		if(isliving(pulling))
			var/mob/living/L = pulling
			if(!slowed_by_drag || L.body_position == STANDING_UP || L.buckled || grab_state >= GRAB_AGGRESSIVE)
				remove_movespeed_modifier(/datum/movespeed_modifier/bulky_drag)
				return
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/bulky_drag, multiplicative_slowdown = PULL_PRONE_SLOWDOWN)
			return
		if(isobj(pulling))
			var/obj/structure/S = pulling
			if(!slowed_by_drag || !S.drag_slowdown)
				remove_movespeed_modifier(/datum/movespeed_modifier/bulky_drag)
				return
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/bulky_drag, multiplicative_slowdown = S.drag_slowdown)
			return
	remove_movespeed_modifier(/datum/movespeed_modifier/bulky_drag)

/**
 * We want to relay the zmovement to the buckled atom when possible
 * and only run what we can't have on buckled.zMove() or buckled.can_z_move() here.
 * This way we can avoid esoteric bugs, copypasta and inconsistencies.
 */
/mob/living/zMove(dir, turf/target, z_move_flags = ZMOVE_FLIGHT_FLAGS)
	if(buckled)
		if(buckled.currently_z_moving)
			return FALSE
		if(!(z_move_flags & ZMOVE_ALLOW_BUCKLED))
			buckled.unbuckle_mob(src, force = TRUE, can_fall = FALSE)
		else
			if(!target)
				target = can_z_move(dir, get_turf(src), null, z_move_flags, src)
				if(!target)
					return FALSE
			return buckled.zMove(dir, target, z_move_flags) // Return value is a loc.
	return ..()

/mob/living/can_z_move(direction, turf/start, turf/destination, z_move_flags = ZMOVE_FLIGHT_FLAGS, mob/living/rider)
	if(z_move_flags & ZMOVE_INCAPACITATED_CHECKS && incapacitated)
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(rider || src, span_warning("[rider ? src : "You"] can't do that right now!"))
		return FALSE
	if(!buckled || !(z_move_flags & ZMOVE_ALLOW_BUCKLED))
		if(!(z_move_flags & ZMOVE_FALL_CHECKS) && incorporeal_move && (!rider || rider.incorporeal_move))
			//An incorporeal mob will ignore obstacles unless it's a potential fall (it'd suck hard) or is carrying corporeal mobs.
			//Coupled with flying/floating, this allows the mob to move up and down freely.
			//By itself, it only allows the mob to move down.
			z_move_flags |= ZMOVE_IGNORE_OBSTACLES
		return ..()
	switch(SEND_SIGNAL(buckled, COMSIG_BUCKLED_CAN_Z_MOVE, direction, start, destination, z_move_flags, src))
		if(COMPONENT_RIDDEN_ALLOW_Z_MOVE) // Can be ridden.
			return buckled.can_z_move(direction, start, destination, z_move_flags, src)
		if(COMPONENT_RIDDEN_STOP_Z_MOVE) // Is a ridable but can't be ridden right now. Feedback messages already done.
			return FALSE
		else
			if(!(z_move_flags & ZMOVE_CAN_FLY_CHECKS) && !buckled.anchored)
				return buckled.can_z_move(direction, start, destination, z_move_flags, src)
			if(z_move_flags & ZMOVE_FEEDBACK)
				to_chat(src, span_warning("Unbuckle from [buckled] first."))
			return FALSE

/mob/set_currently_z_moving(value)
	if(buckled)
		return buckled.set_currently_z_moving(value)
	return ..()

/mob/living/keybind_face_direction(direction)
	if(stat > SOFT_CRIT)
		return
	return ..()
