/atom/movable
	/// Whether the atom allows mobs to be buckled to it. Can be ignored in [/atom/movable/proc/buckle_mob()] if force = TRUE
	var/can_buckle = FALSE
	/// Bed-like behaviour, forces mob.lying = buckle_lying if not set to [NO_BUCKLE_LYING].
	var/buckle_lying = NO_BUCKLE_LYING
	/// Bed-like behaviour, sets mob dir to buckle_dir if not set to [BUCKLE_MATCH_DIR]. If set to [BUCKLE_MATCH_DIR], makes mob dir match ours.
	var/buckle_dir = BUCKLE_MATCH_DIR
	/// Require people to be handcuffed before being able to buckle. eg: pipes
	var/buckle_requires_restraints = FALSE
	/// The mobs currently buckled to this atom
	var/list/mob/living/buckled_mobs = null //list()
	/// The maximum number of mob/livings allowed to be buckled to this atom at once
	var/max_buckled_mobs = 1
	/// Whether things buckled to this atom can be pulled while they're buckled
	var/buckle_prevents_pull = FALSE

//Interaction
/atom/movable/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(can_buckle && has_buckled_mobs())
		if(length(buckled_mobs) > 1)
			var/mob/living/unbuckled = tgui_input_list(user, "Who do you wish to unbuckle?", "Unbuckle", sort_names(buckled_mobs))
			if(isnull(unbuckled))
				return
			if(user_unbuckle_mob(unbuckled,user))
				return TRUE
		else
			if(user_unbuckle_mob(buckled_mobs[1],user))
				return TRUE

//literally just the above extension of attack_hand(), but for silicons instead (with an adjacency check, since attack_robot() being called doesn't mean that you're adjacent to something)
/atom/movable/attack_robot(mob/living/user)
	. = ..()
	if(.)
		return
	if(Adjacent(user) && can_buckle && has_buckled_mobs())
		if(length(buckled_mobs) > 1)
			var/mob/living/unbuckled = tgui_input_list(user, "Who do you wish to unbuckle?", "Unbuckle", sort_names(buckled_mobs))
			if(isnull(unbuckled))
				return
			return user_unbuckle_mob(unbuckled,user)
		else
			return user_unbuckle_mob(buckled_mobs[1], user)

/atom/movable/mouse_drop_receive(mob/living/M, mob/user, params)
	return mouse_buckle_handling(M, user)

/**
 * Does some typechecks and then calls user_buckle_mob
 *
 * Arguments:
 * M - The mob being buckled to src
 * user - The mob buckling M to src
 */
/atom/movable/proc/mouse_buckle_handling(mob/living/M, mob/living/user)
	if(can_buckle && istype(M) && istype(user))
		return user_buckle_mob(M, user, check_loc = FALSE)

/**
 * Returns TRUE if there are mobs buckled to this atom and FALSE otherwise
 */
/atom/movable/proc/has_buckled_mobs()
	if(length(buckled_mobs))
		return TRUE
	return FALSE

/**
 * Set a mob as buckled to src
 *
 * If you want to have a mob buckling another mob to something, or you want a chat message sent, use user_buckle_mob instead.
 * Arguments:
 * M - The mob to be buckled to src
 * force - Set to TRUE to ignore src's can_buckle and M's can_buckle_to
 * check_loc - Set to FALSE to allow buckling from adjacent turfs, or TRUE if buckling is only allowed with src and M on the same turf.
 * buckle_mob_flags- Used for riding cyborgs and humans if we need to reserve an arm or two on either the rider or the ridden mob.
 * ignore_self - If set to TRUE, this will not do a check to see if the user can move into the turf of the mob and will just automatically mount them.
 */
/atom/movable/proc/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE, buckle_mob_flags= NONE)
	if(!buckled_mobs)
		buckled_mobs = list()

	if(!is_buckle_possible(M, force, check_loc))
		return FALSE

	// This signal will check if the mob is mounting this atom to ride it. There are 3 possibilities for how this goes
	// 1. This movable doesn't have a ridable element and can't be ridden, so nothing gets returned, so continue on
	// 2. There's a ridable element but we failed to mount it for whatever reason (maybe it has no seats left, for example), so we cancel the buckling
	// 3. There's a ridable element and we were successfully able to mount, so keep it going and continue on with buckling
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_PREBUCKLE, M, force, buckle_mob_flags) & COMPONENT_BLOCK_BUCKLE)
		return FALSE

	if(M.pulledby)
		if(buckle_prevents_pull)
			M.pulledby.stop_pulling()
		else if(isliving(M.pulledby))
			var/mob/living/L = M.pulledby
			L.reset_pull_offsets(M, TRUE)

	if(anchored)
		ADD_TRAIT(M, TRAIT_NO_FLOATING_ANIM, BUCKLED_TRAIT)
	if(!length(buckled_mobs))
		RegisterSignal(src, COMSIG_MOVABLE_SET_ANCHORED, PROC_REF(on_set_anchored))
	M.set_buckled(src)
	buckled_mobs |= M
	M.throw_alert(ALERT_BUCKLED, /atom/movable/screen/alert/buckled)
	M.set_glide_size(glide_size)

	M.Move(loc)
	if(buckle_dir == BUCKLE_MATCH_DIR)
		M.setDir(dir)
	else
		M.setDir(buckle_dir)

	//Something has unbuckled us in reaction to the above movement
	if(!M.buckled)
		return FALSE

	post_buckle_mob(M)

	SEND_SIGNAL(src, COMSIG_MOVABLE_BUCKLE, M, force)
	SEND_SIGNAL(M, COMSIG_MOB_BUCKLED, src)
	return TRUE

/obj/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	. = ..()
	if(.)
		if(resistance_flags & ON_FIRE) //Sets the mob on fire if you buckle them to a burning atom/movableect
			M.adjust_fire_stacks(1)
			M.ignite_mob()

/**
 * Set a mob as unbuckled from src
 *
 * The mob must actually be buckled to src or else bad things will happen.
 * Arguments:
 * buckled_mob - The mob to be unbuckled
 * force - TRUE if we should ignore buckled_mob.can_buckle_to
 */
/atom/movable/proc/unbuckle_mob(mob/living/buckled_mob, force = FALSE, can_fall = TRUE)
	if(!isliving(buckled_mob))
		CRASH("Non-living [buckled_mob] thing called unbuckle_mob() for source.")
	if(buckled_mob.buckled != src)
		CRASH("[buckled_mob] called unbuckle_mob() for source while having buckled as [buckled_mob.buckled].")
	if(!force && !buckled_mob.can_buckle_to)
		return
	. = buckled_mob
	buckled_mob.set_buckled(null)
	buckled_mob.set_anchored(initial(buckled_mob.anchored))
	buckled_mob.clear_alert(ALERT_BUCKLED)
	buckled_mob.set_glide_size(DELAY_TO_GLIDE_SIZE(buckled_mob.cached_multiplicative_slowdown))
	buckled_mobs -= buckled_mob
	if(anchored)
		REMOVE_TRAIT(buckled_mob, TRAIT_NO_FLOATING_ANIM, BUCKLED_TRAIT)
	if(!length(buckled_mobs))
		UnregisterSignal(src, COMSIG_MOVABLE_SET_ANCHORED)
	SEND_SIGNAL(src, COMSIG_MOVABLE_UNBUCKLE, buckled_mob, force)
	SEND_SIGNAL(buckled_mob, COMSIG_MOB_UNBUCKLED, src)

	if(can_fall)
		var/turf/location = buckled_mob.loc
		if(istype(location) && !buckled_mob.currently_z_moving)
			location.zFall(buckled_mob)

	post_unbuckle_mob(.)

	if(!QDELETED(buckled_mob) && !buckled_mob.currently_z_moving && isturf(buckled_mob.loc)) // In the case they unbuckled to a flying movable midflight.
		var/turf/pitfall = buckled_mob.loc
		pitfall?.zFall(buckled_mob)

/atom/movable/proc/on_set_anchored(atom/movable/source, anchorvalue)
	SIGNAL_HANDLER
	for(var/_buckled_mob in buckled_mobs)
		if(!_buckled_mob)
			continue
		var/mob/living/buckled_mob = _buckled_mob
		if(anchored)
			ADD_TRAIT(buckled_mob, TRAIT_NO_FLOATING_ANIM, BUCKLED_TRAIT)
		else
			REMOVE_TRAIT(buckled_mob, TRAIT_NO_FLOATING_ANIM, BUCKLED_TRAIT)

/**
 * Call [/atom/movable/proc/unbuckle_mob] for all buckled mobs
 */
/atom/movable/proc/unbuckle_all_mobs(force=FALSE)
	if(!has_buckled_mobs())
		return
	for(var/m in buckled_mobs)
		unbuckle_mob(m, force)

//Handle any extras after buckling
//Called on buckle_mob()
/atom/movable/proc/post_buckle_mob(mob/living/buckled_mob)

//same but for unbuckle
/atom/movable/proc/post_unbuckle_mob(mob/living/unbuckled_mob)

/**
 * Simple helper proc that runs a suite of checks to test whether it is possible or not to buckle the target mob to src.
 *
 * Returns FALSE if any conditions that should prevent buckling are satisfied. Returns TRUE otherwise.
 * Called from [/atom/movable/proc/buckle_mob] and [/atom/movable/proc/is_user_buckle_possible].
 * Arguments:
 * * target - Target mob to check against buckling to src.
 * * force - Whether or not the buckle should be forced. If TRUE, ignores src's can_buckle var and target's can_buckle_to
 * * check_loc - TRUE if target and src have to be on the same tile, FALSE if they are allowed to just be adjacent
 */
/atom/movable/proc/is_buckle_possible(mob/living/target, force = FALSE, check_loc = TRUE)
	// Make sure target is mob/living
	if(!istype(target))
		return FALSE

	// No bucking you to yourself.
	if(target == src)
		return FALSE

	// Check if the target to buckle isn't INSIDE OF A WALL
	if(!isopenturf(loc) || !isopenturf(target.loc))
		return FALSE

	// Check if the target to buckle isn't A SOLID OBJECT (not including vehicles)
	var/turf/ground = get_turf(src)
	if(ground.is_blocked_turf(exclude_mobs = TRUE, source_atom = src))
		return FALSE

	// Check if this atom can have things buckled to it.
	if(!can_buckle && !force)
		return FALSE

	// If we're checking the loc, make sure the target is on the thing we're bucking them to.
	if(check_loc && !target.Adjacent(src))
		return FALSE

	// Make sure the target isn't already buckled to something.
	if(target.buckled)
		return FALSE

	// Make sure this atom can still have more things buckled to it.
	if(LAZYLEN(buckled_mobs) >= max_buckled_mobs)
		return FALSE

	// Stacking buckling leads to lots of jank and issues, better to just nix it entirely
	if(target.has_buckled_mobs())
		return FALSE

	// If the buckle requires restraints, make sure the target is actually restrained.
	if(buckle_requires_restraints && !HAS_TRAIT(target, TRAIT_RESTRAINED))
		return FALSE

	//If buckling is forbidden for the target, cancel
	if(!target.can_buckle_to && !force)
		return FALSE

	return TRUE

/**
 * Simple helper proc that runs a suite of checks to test whether it is possible or not for user to buckle target mob to src.
 *
 * Returns FALSE if any conditions that should prevent buckling are satisfied. Returns TRUE otherwise.
 * Called from [/atom/movable/proc/user_buckle_mob].
 * Arguments:
 * * target - Target mob to check against buckling to src.
 * * user - The mob who is attempting to buckle the target to src.
 * * check_loc - TRUE if target and src have to be on the same tile, FALSE if buckling is allowed from adjacent tiles
 */
/atom/movable/proc/is_user_buckle_possible(mob/living/target, mob/user, check_loc = TRUE)
	// Standard adjacency and other checks.
	if(!Adjacent(user) || !Adjacent(target) || !isturf(user.loc) || user.incapacitated() || target.anchored)
		return FALSE

	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		if(carbon_user.usable_hands <= 0)
			return FALSE

	// In buckling even possible in the first place?
	if(!is_buckle_possible(target, FALSE, check_loc))
		return FALSE

	return TRUE

/**
 * Handles a mob buckling another mob to src and sends a visible_message
 *
 * Basically exists to do some checks on the user and then call buckle_mob where the real buckling happens.
 * First, checks if the buckle is valid and cancels if it isn't.
 * Second, checks if src is on a different turf from the target; if it is, does a do_after and another check for sanity
 * Finally, calls [/atom/movable/proc/buckle_mob] to buckle the target to src then gives chat feedback
 * Arguments:
 * * M - The target mob/living being buckled to src
 * * user - The other mob that's buckling M to src
 * * check_loc - TRUE if src and M have to be on the same turf, false otherwise
 */
/atom/movable/proc/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	// Is buckling even possible? Do a full suite of checks.
	if(!is_user_buckle_possible(M, user, check_loc))
		return FALSE

	add_fingerprint(user)

	// If the mob we're attempting to buckle is not stood on this atom's turf and it isn't the user buckling themselves,
	// we'll try it with a 2 second do_after delay.
	if(M != user && (get_turf(M) != get_turf(src)))
		M.visible_message(span_warning("[user] starts buckling [M] to [src]!"),\
			span_userdanger("[user] starts buckling you to [src]!"),\
			span_hear("You hear metal clanking."))
		if(!do_after(user, 2 SECONDS, M))
			return FALSE

		// Sanity check before we attempt to buckle. Is everything still in a kosher state for buckling after the 3 seconds have elapsed?
		// Covers situations where, for example, the chair was moved or there's some other issue.
		if(!is_user_buckle_possible(M, user, check_loc))
			return FALSE

	. = buckle_mob(M, check_loc = check_loc)
	if(.)
		if(M == user)
			M.visible_message(span_notice("[M] buckles [M.p_them()]self to [src]."),\
				span_notice("You buckle yourself to [src]."),\
				span_hear("You hear metal clanking."))
		else
			M.visible_message(span_warning("[user] buckles [M] to [src]!"),\
				span_warning("[user] buckles you to [src]!"),\
				span_hear("You hear metal clanking."))
/**
 * Handles a user unbuckling a mob from src and sends a visible_message
 *
 * Basically just calls unbuckle_mob, sets fingerprint, and sends a visible_message
 * about the user unbuckling the mob
 * Arguments:
 * buckled_mob - The mob/living to unbuckle
 * user - The mob unbuckling buckled_mob
 */
/atom/movable/proc/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(!(buckled_mob in buckled_mobs) || !user.CanReach(buckled_mob))
		return
	var/mob/living/M = unbuckle_mob(buckled_mob)
	if(M)
		if(M != user)
			M.visible_message(span_notice("[user] unbuckles [M] from [src]."),\
				span_notice("[user] unbuckles you from [src]."),\
				span_hear("You hear metal clanking."))
		else
			M.visible_message(span_notice("[M] unbuckles [M.p_them()]self from [src]."),\
				span_notice("You unbuckle yourself from [src]."),\
				span_hear("You hear metal clanking."))
		add_fingerprint(user)
		if(isliving(M.pulledby))
			var/mob/living/L = M.pulledby
			L.set_pull_offsets(M, L.grab_state)
	return M
