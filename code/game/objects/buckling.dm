/atom/movable
	var/can_buckle = FALSE
	/// Bed-like behaviour, forces mob.lying = buckle_lying if not set to [NO_BUCKLE_LYING].
	var/buckle_lying = NO_BUCKLE_LYING
	var/buckle_requires_restraints = FALSE //require people to be handcuffed before being able to buckle. eg: pipes
	var/list/mob/living/buckled_mobs = null //list()
	var/max_buckled_mobs = 1
	var/buckle_prevents_pull = FALSE

//Interaction
/atom/movable/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(can_buckle && has_buckled_mobs())
		if(buckled_mobs.len > 1)
			var/unbuckled = input(user, "Who do you wish to unbuckle?","Unbuckle Who?") as null|mob in sortNames(buckled_mobs)
			if(user_unbuckle_mob(unbuckled,user))
				return TRUE
		else
			if(user_unbuckle_mob(buckled_mobs[1],user))
				return TRUE

/atom/movable/attackby(obj/item/W, mob/user, params)
	if(!can_buckle || !istype(W, /obj/item/riding_offhand) || !user.Adjacent(src))
		return ..()

	var/obj/item/riding_offhand/riding_item = W
	var/mob/living/carried_mob = riding_item.rider
	if(carried_mob == user) //Piggyback user.
		return
	user.unbuckle_mob(carried_mob)
	carried_mob.forceMove(get_turf(src))
	return mouse_buckle_handling(carried_mob, user)

//literally just the above extension of attack_hand(), but for silicons instead (with an adjacency check, since attack_robot() being called doesn't mean that you're adjacent to something)
/atom/movable/attack_robot(mob/living/user)
	. = ..()
	if(.)
		return
	if(Adjacent(user) && can_buckle && has_buckled_mobs())
		if(buckled_mobs.len > 1)
			var/unbuckled = input(user, "Who do you wish to unbuckle?","Unbuckle Who?") as null|mob in sortNames(buckled_mobs)
			if(user_unbuckle_mob(unbuckled,user))
				return TRUE
		else
			if(user_unbuckle_mob(buckled_mobs[1],user))
				return TRUE

/atom/movable/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	return mouse_buckle_handling(M, user)

/atom/movable/proc/mouse_buckle_handling(mob/living/M, mob/living/user)
	if(can_buckle && istype(M) && istype(user))
		if(user_buckle_mob(M, user))
			return TRUE

/atom/movable/proc/has_buckled_mobs()
	if(!buckled_mobs)
		return FALSE
	if(buckled_mobs.len)
		return TRUE

//procs that handle the actual buckling and unbuckling
/atom/movable/proc/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!buckled_mobs)
		buckled_mobs = list()

	if(!is_buckle_possible(M, force, check_loc))
		return FALSE

	M.buckling = src
	if(!M.can_buckle() && !force)
		if(M == usr)
			to_chat(M, "<span class='warning'>You are unable to buckle yourself to [src]!</span>")
		else
			to_chat(usr, "<span class='warning'>You are unable to buckle [M] to [src]!</span>")
		M.buckling = null
		return FALSE

	if(M.pulledby)
		if(buckle_prevents_pull)
			M.pulledby.stop_pulling()
		else if(isliving(M.pulledby))
			var/mob/living/L = M.pulledby
			L.reset_pull_offsets(M, TRUE)

	if(!check_loc && M.loc != loc)
		M.forceMove(loc)

	M.buckling = null
	M.set_buckled(src)
	M.setDir(dir)
	buckled_mobs |= M
	M.throw_alert("buckled", /obj/screen/alert/restrained/buckled)
	M.set_glide_size(glide_size)
	post_buckle_mob(M)

	SEND_SIGNAL(src, COMSIG_MOVABLE_BUCKLE, M, force)
	return TRUE

/obj/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	. = ..()
	if(.)
		if(resistance_flags & ON_FIRE) //Sets the mob on fire if you buckle them to a burning atom/movableect
			M.adjust_fire_stacks(1)
			M.IgniteMob()


/atom/movable/proc/unbuckle_mob(mob/living/buckled_mob, force = FALSE)
	if(!isliving(buckled_mob))
		CRASH("Non-living [buckled_mob] thing called unbuckle_mob() for source.")
	if(buckled_mob.buckled != src)
		CRASH("[buckled_mob] called unbuckle_mob() for source while having buckled as [buckled_mob.buckled].")
	if(!force && !buckled_mob.can_unbuckle())
		return
	. = buckled_mob
	buckled_mob.set_buckled(null)
	buckled_mob.set_anchored(initial(buckled_mob.anchored))
	buckled_mob.clear_alert("buckled")
	buckled_mob.set_glide_size(DELAY_TO_GLIDE_SIZE(buckled_mob.total_multiplicative_slowdown()))
	buckled_mobs -= buckled_mob
	SEND_SIGNAL(src, COMSIG_MOVABLE_UNBUCKLE, buckled_mob, force)

	post_unbuckle_mob(.)


/atom/movable/proc/unbuckle_all_mobs(force=FALSE)
	if(!has_buckled_mobs())
		return
	for(var/m in buckled_mobs)
		unbuckle_mob(m, force)

//Handle any extras after buckling
//Called on buckle_mob()
/atom/movable/proc/post_buckle_mob(mob/living/M)

//same but for unbuckle
/atom/movable/proc/post_unbuckle_mob(mob/living/M)

/**
  * Simple helper proc that runs a suite of checks to test whether it is possible or not to buckle the target mob to src.
  *
  * Returns FALSE if any conditions that should prevent buckling are satisfied. Returns TRUE otherwise.
  * Arguments:
  * * target - Target mob to check against buckling to src.
  * * force - Whether or not the buckle should be forced. If TRUE, ignores src's can_buckle var.
  * * check_loc - Whether to do a proximity check or not. The proximity check looks for target.loc == src.loc.
  */
/atom/movable/proc/is_buckle_possible(mob/living/target, force = FALSE, check_loc = TRUE)
	// Make sure target is mob/living
	if(!istype(target))
		return FALSE

	// No bucking you to yourself.
	if(target == src)
		return FALSE

	// Check if this atom can have things buckled to it.
	if(!can_buckle && !force)
		return FALSE

	// If we're checking the loc, make sure the target is on the thing we're bucking them to.
	if(check_loc && target.loc != loc)
		return FALSE

	// Make sure the target isn't already buckled to something.
	if(target.buckled)
		return FALSE

	// Make sure this atom can still have more things buckled to it.
	if(LAZYLEN(buckled_mobs) >= max_buckled_mobs)
		return FALSE

	// If the buckle requires restraints, make sure the target is actually restrained.
	if(buckle_requires_restraints && !HAS_TRAIT(target, TRAIT_RESTRAINED))
		return FALSE

	return TRUE

/**
  * Simple helper proc that runs a suite of checks to test whether it is possible or not for user to buckle target mob to src.
  *
  * Returns FALSE if any conditions that should prevent buckling are satisfied. Returns TRUE otherwise.
  * Arguments:
  * * target - Target mob to check against buckling to src.
  * * user - The mob who is attempting to buckle the target to src.
  * * check_loc - Whether to do a proximity check or not when calling is_buckle_possible().
  */
/atom/movable/proc/is_user_buckle_possible(mob/living/target, mob/user, check_loc = TRUE)
	// Standard adjacency and other checks.
	if(!Adjacent(user) || !Adjacent(target) || !isturf(user.loc) || user.incapacitated() || target.anchored)
		return FALSE

	// In buckling even possible in the first place?
	if(!is_buckle_possible(target, FALSE, check_loc))
		return FALSE

	// If the person attempting to buckle is stood on this atom's turf and they're not buckling themselves,
	// buckling shouldn't be possible as they're blocking it.
	if((target != user) && (get_turf(user) == get_turf(src)))
		to_chat(target, "<span class='warning'>You are unable to buckle [target] to [src] while it is blocked!</span>")
		return FALSE

	return TRUE

//Wrapper procs that handle sanity and user feedback
/atom/movable/proc/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	// Is buckling even possible? Do a full suite of checks.
	if(!is_user_buckle_possible(M, user, check_loc))
		return FALSE

	add_fingerprint(user)

	// If the mob we're attempting to buckle is not stood on this atom's turf and it isn't the user buckling themselves,
	// we'll try it with a 2 second do_after delay.
	if(M != user && (get_turf(M) != get_turf(src)))
		M.visible_message("<span class='warning'>[user] starts buckling [M] to [src]!</span>",\
			"<span class='userdanger'>[user] starts buckling you to [src]!</span>",\
			"<span class='hear'>You hear metal clanking.</span>")
		if(!do_after(user, 2 SECONDS, TRUE, M))
			return FALSE

		// Sanity check before we attempt to buckle. Is everything still in a kosher state for buckling after the 3 seconds have elapsed?
		// Covers situations where, for example, the chair was moved or there's some other issue.
		if(!is_user_buckle_possible(M, user, check_loc))
			return FALSE

	. = buckle_mob(M, check_loc = check_loc)
	if(.)
		if(M == user)
			M.visible_message("<span class='notice'>[M] buckles [M.p_them()]self to [src].</span>",\
				"<span class='notice'>You buckle yourself to [src].</span>",\
				"<span class='hear'>You hear metal clanking.</span>")
		else
			M.visible_message("<span class='warning'>[user] buckles [M] to [src]!</span>",\
				"<span class='warning'>[user] buckles you to [src]!</span>",\
				"<span class='hear'>You hear metal clanking.</span>")

/atom/movable/proc/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	var/mob/living/M = unbuckle_mob(buckled_mob)
	if(M)
		if(M != user)
			M.visible_message("<span class='notice'>[user] unbuckles [M] from [src].</span>",\
				"<span class='notice'>[user] unbuckles you from [src].</span>",\
				"<span class='hear'>You hear metal clanking.</span>")
		else
			M.visible_message("<span class='notice'>[M] unbuckles [M.p_them()]self from [src].</span>",\
				"<span class='notice'>You unbuckle yourself from [src].</span>",\
				"<span class='hear'>You hear metal clanking.</span>")
		add_fingerprint(user)
		if(isliving(M.pulledby))
			var/mob/living/L = M.pulledby
			L.set_pull_offsets(M, L.grab_state)
	return M
