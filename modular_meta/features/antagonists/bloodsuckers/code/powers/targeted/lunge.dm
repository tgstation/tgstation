/datum/action/cooldown/bloodsucker/targeted/lunge
	name = "Predatory Lunge"
	desc = "Spring at your target to grapple them without warning, or tear their heart out if they're dead. Attacks from concealment or the rear may even knock them down if strong enough."
	button_icon_state = "power_lunge"
	power_explanation = "Predatory Lunge:\n\
		Click any person to start spinning wildly and, after a short delay, dash at them.\n\
		When the dash is complete you will have an aggressive hold on your target.\n\
		Monster Hunters and those with riot gear are protected and will only be passively grabbed.\n\
		You cannot use this power if you are already grabbing someone, or are being grabbed.\n\
		If you grab from behind, or from darkness (Cloak of Darkness works,) you will knock the target down.\n\
		If used on a dead body, you will tear its heart out.\n\
		Higher levels increase the knockdown dealt to enemies.\n\
		At level 4, you will no longer spin, but you will be limited to tackling from only 6 tiles away."
	power_flags = NONE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|VASSAL_CAN_BUY
	bloodcost = 10
	cooldown_time = 10 SECONDS
	power_activates_immediately = FALSE

/datum/action/cooldown/bloodsucker/targeted/lunge/upgrade_power()
	. = ..()
	//range is lowered when you get stronger.
	if(level_current > 3)
		target_range = 6

/datum/action/cooldown/bloodsucker/targeted/lunge/can_use(mob/living/carbon/user, trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	// Are we being grabbed?
	if(user.pulledby && user.pulledby.grab_state >= GRAB_AGGRESSIVE)
		owner.balloon_alert(user, "grabbed!")
		return FALSE
	if(user.pulling)
		owner.balloon_alert(user, "grabbing someone!")
		return FALSE
	return TRUE

/// Check: Are we lunging at a person?
/datum/action/cooldown/bloodsucker/targeted/lunge/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isliving(target_atom)

/datum/action/cooldown/bloodsucker/targeted/lunge/CheckCanTarget(atom/target_atom)
	// Default Checks
	. = ..()
	if(!.)
		return FALSE
	// Check: Turf
	var/mob/living/turf_target = target_atom
	if(!isturf(turf_target.loc))
		return FALSE
	// Check: can the Bloodsucker even move?
	var/mob/living/user = owner
	if(user.body_position == LYING_DOWN || HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/lunge/can_deactivate()
	return !(datum_flags & DF_ISPROCESSING) //only if you aren't lunging

/datum/action/cooldown/bloodsucker/targeted/lunge/FireTargetedPower(atom/target_atom)
	. = ..()
	owner.face_atom(target_atom)
	if(level_current > 3)
		do_lunge(target_atom)
		return

	prepare_target_lunge(target_atom)
	return TRUE

///Starts processing the power and prepares the lunge by spinning, calls lunge at the end of it.
/datum/action/cooldown/bloodsucker/targeted/lunge/proc/prepare_target_lunge(atom/target_atom)
	START_PROCESSING(SSprocessing, src)
	owner.balloon_alert(owner, "lunge started!")
	//animate them shake
	var/base_x = owner.base_pixel_x
	var/base_y = owner.base_pixel_y
	animate(owner, pixel_x = base_x, pixel_y = base_y, time = 1, loop = -1)
	for(var/i in 1 to 25)
		var/x_offset = base_x + rand(-3, 3)
		var/y_offset = base_y + rand(-3, 3)
		animate(pixel_x = x_offset, pixel_y = y_offset, time = 1)

	if(!do_after(owner, 4 SECONDS, timed_action_flags = (IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE|IGNORE_SLOWDOWNS), extra_checks = CALLBACK(src, PROC_REF(CheckCanTarget), target_atom)))
		end_target_lunge(base_x, base_y)

		return FALSE

	end_target_lunge()
	do_lunge(target_atom)
	return TRUE

///When preparing to lunge ends, this clears it up.
/datum/action/cooldown/bloodsucker/targeted/lunge/proc/end_target_lunge(base_x, base_y)
	animate(owner, pixel_x = base_x, pixel_y = base_y, time = 1)
	STOP_PROCESSING(SSprocessing, src)

/datum/action/cooldown/bloodsucker/targeted/lunge/process()
	if(!active) //If running SSfasprocess (on cooldown)
		return ..() //Manage our cooldown timers
	if(prob(75))
		owner.spin(8, 1)
		owner.balloon_alert_to_viewers("spins wildly!", "you spin!")
		return
	do_smoke(0, owner.loc, smoke_type = /obj/effect/particle_effect/fluid/smoke/transparent)

///Actually lunges the target, then calls lunge end.
/datum/action/cooldown/bloodsucker/targeted/lunge/proc/do_lunge(atom/hit_atom)
	var/turf/targeted_turf = get_turf(hit_atom)

	var/safety = get_dist(owner, targeted_turf) * 3 + 1
	var/consequetive_failures = 0
	while(--safety && !hit_atom.Adjacent(owner))
		if(!step_to(owner, targeted_turf))
			consequetive_failures++
		if(consequetive_failures >= 3) // If 3 steps don't work, just stop.
			break

	lunge_end(hit_atom, targeted_turf)

/datum/action/cooldown/bloodsucker/targeted/lunge/proc/lunge_end(atom/hit_atom, turf/target_turf)
	power_activated_sucessfully()
	// Am I next to my target to start giving the effects?
	if(!owner.Adjacent(hit_atom))
		return

	var/mob/living/user = owner
	var/mob/living/carbon/target = hit_atom

	// Did I slip or get knocked unconscious?
	if(user.body_position != STANDING_UP || user.incapacitated)
		user.spin(10)
		return

	owner.balloon_alert(owner, "you lunge at [target]!")
	if(target.stat == DEAD)
		var/obj/item/bodypart/chest = target.get_bodypart(BODY_ZONE_CHEST)
		var/datum/wound/slash/flesh/moderate/crit_wound = new
		crit_wound.apply_wound(chest)
		owner.visible_message(
			span_warning("[owner] tears into [target]'s chest!"),
			span_warning("You tear into [target]'s chest!"))

		var/obj/item/organ/heart/myheart_now = locate() in target.organs
		if(myheart_now)
			myheart_now.Remove(target)
			user.put_in_hands(myheart_now)

	else
		target.grabbedby(owner)
		target.grippedby(owner, instant = TRUE)
		// Did we knock them down?
		if(!is_source_facing_target(target, owner) || owner.alpha <= 40)
			target.Knockdown(10 + level_current * 5)
			target.Paralyze(0.1)

/datum/action/cooldown/bloodsucker/targeted/lunge/DeactivatePower()
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, BLOODSUCKER_TRAIT)
	return ..()
