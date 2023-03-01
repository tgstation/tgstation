/datum/action/cooldown/bloodsucker/targeted/lunge
	name = "Predatory Lunge"
	desc = "Spring at a humanoid to grapple them without warning, or tear the dead's heart out. Attacks from concealment or the rear may even knock them down if strong enough."
	button_icon_state = "power_lunge"
	power_explanation = "<b>Predatory Lunge</b>:\n\
		Click any player to instantly dash at them, aggressively grabbing them.\n\
		You cannot use the Power if you are aggressively grabbed.\n\
		If the target is wearing riot gear or is a Monster Hunter, you will merely passively grab them.\n\
		If grabbed from the darkness (Cloak of Darkness counts) with a power level at or above 4, will additionally knock the target down.\n\
		Higher levels will increase the knockdown dealt to enemies."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|VASSAL_CAN_BUY
	bloodcost = 10
	cooldown = 10 SECONDS
	target_range = 6
	power_activates_immediately = FALSE

/*
 *	Level 1: Grapple level 2
 *	Level 2: Grapple 3 from Behind
 *	Level 3: Grapple 3 from Shadows
 */

/datum/action/cooldown/bloodsucker/targeted/lunge/CheckCanUse(mob/living/carbon/user, silent = FALSE)
	. = ..()
	if(!.)
		return FALSE
	/// Are we being grabbed?
	if(user.pulledby && user.pulledby.grab_state >= GRAB_AGGRESSIVE)
		if(!silent)
			to_chat(user, span_warning("You're being grabbed!"))
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
	if(!(user.mobility_flags & MOBILITY_STAND) || user.IsImmobilized())
		to_chat(user, span_warning("You need to be standing and aware to lunge!"))
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/lunge/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/user = owner
	var/mob/living/carbon/target = target_atom
	var/turf/targeted_turf = get_turf(target)

	owner.face_atom(target_atom)
	if(level_current <= 3 && !prepare_target_lunge(target_atom))
		PowerActivatedSuccessfully()
		return
	user.Immobilize(10 SECONDS)
	var/safety = get_dist(user, targeted_turf) * 3 + 1
	var/consequetive_failures = 0
	while(--safety && !target.Adjacent(user))
		if(!step_to(user, targeted_turf))
			consequetive_failures++
		if(consequetive_failures >= 3) // If 3 steps don't work, just stop.
			break
	lunge_end(target)
	PowerActivatedSuccessfully()

/datum/action/cooldown/bloodsucker/targeted/lunge/proc/prepare_target_lunge(atom/target_atom)
	START_PROCESSING(SSprocessing, src)
	to_chat(owner, span_notice("You prepare to lunge!"))
	//animate them shake
	var/base_x = owner.pixel_x
	var/base_y = owner.pixel_y
	animate(owner, pixel_x = base_x, pixel_y = base_y, time = 1, loop = -1)
	for(var/i in 1 to 25)
		var/x_offset = base_x + rand(-3, 3)
		var/y_offset = base_y + rand(-3, 3)
		animate(pixel_x = x_offset, pixel_y = y_offset, time = 1)

	if(!do_after(owner, 4 SECONDS, extra_checks = CALLBACK(src, .proc/CheckCanTarget, target_atom)))
		animate(owner, pixel_x = base_x, pixel_y = base_y, time = 1)
		STOP_PROCESSING(SSprocessing, src)
		return FALSE
	animate(owner, pixel_x = base_x, pixel_y = base_y, time = 1)
	STOP_PROCESSING(SSprocessing, src)
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/lunge/process()
	if(prob(75))
		owner.spin(8, 1)
		owner.visible_message(
			span_warning("[owner] spins wildly!"),
			span_notice("You spin!"),
			)
		return

/datum/action/cooldown/bloodsucker/targeted/lunge/proc/lunge_end(atom/hit_atom)
	var/mob/living/user = owner
	var/mob/living/carbon/target = hit_atom
	var/turf/target_turf = get_turf(target)
// Am I next to my target to start giving the effects?
	if(!user.Adjacent(target))
		return
	// Did I slip or get knocked unconscious?
	if(!(user.mobility_flags & MOBILITY_STAND))
		var/send_dir = get_dir(user, target_turf)
		new /datum/forced_movement(user, get_ranged_target_turf(user, send_dir, 1), 1, FALSE)
		user.spin(10)
		return
	// Is my target a Monster hunter?
	var/mob/living/carbon/human/H = target
	if(IS_MONSTERHUNTER(target) || H.is_shove_knockdown_blocked())
		to_chat(owner, span_danger("You get pushed away!"))
		H.grabbedby(owner)
		return	

	to_chat(owner, span_danger("You lunge at [target]!"))
	if(target.stat == DEAD)
		var/obj/item/bodypart/chest = target.get_bodypart(BODY_ZONE_CHEST)
		var/datum/wound/slash/moderate/crit_wound = new
		crit_wound.apply_wound(chest)
		owner.visible_message(
			span_warning("[owner] tears into [target]'s chest!"),
			span_warning("You tear into [target]'s chest!"))
		var/obj/item/organ/internal/heart/myheart_now = locate() in target.internal_organs
		if(myheart_now)
			myheart_now.Remove(target)
			user.put_in_hands(myheart_now)
		return

	//Grab now
	target.grabbedby(owner)
	target.grippedby(owner, instant = TRUE)
	// Did we knock them down?
	if(level_current >= 4 && (owner.alpha <= 40))
		target.Knockdown(10 + level_current * 5)
		target.Paralyze(0.1)

/datum/action/cooldown/bloodsucker/targeted/lunge/DeactivatePower()
	var/mob/living/O = owner
	O.SetImmobilized(0)
	return ..()
