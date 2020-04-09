
// Level 1: Grapple level 2
// Level 2: Grapple 3 from Behind
// Level 3: Grapple 3 from Shadows

/datum/action/bloodsucker/targeted/lunge
	name = "Predatory Lunge"
	desc = "Spring at your target and aggressively grapple them without warning. Attacks from concealment or the rear may even knock them down."
	button_icon_state = "power_lunge"
	bloodcost = 10
	cooldown = 100
	target_range = 3
	power_activates_immediately = TRUE
	message_Trigger = ""//"Whom will you subvert to your will?"
	must_be_capacitated = TRUE
	bloodsucker_can_buy = TRUE


/datum/action/bloodsucker/targeted/lunge/CheckCanUse(display_error)
	if(!..(display_error))// DEFAULT CHECKS
		return FALSE
	// Being Grabbed
	if (owner.pulledby && owner.pulledby.grab_state >= GRAB_AGGRESSIVE)
		if (display_error)
			to_chat(owner, "<span class='warning'>You're being grabbed!</span>")
		return FALSE
	return TRUE


/datum/action/bloodsucker/targeted/lunge/CheckValidTarget(atom/A)
	return isliving(A)


/datum/action/bloodsucker/targeted/lunge/CheckCanTarget(atom/A, display_error)
	// Check: Self
	if (target == owner)
		return FALSE
	// Check: Range
	//if (!(target in view(target_range, get_turf(owner))))
	//	if (display_error)
	//		to_chat(owner, "<span class='warning'>Your victim is too far away.</span>")
	//	return FALSE
	// DEFAULT CHECKS (Distance)
	if (!..())
		return FALSE
	// Check: Turf
	var/mob/living/L = A
	if (!isturf(L.loc))
		return FALSE
	return TRUE

/datum/action/bloodsucker/targeted/lunge/FireTargetedPower(atom/A)
	// set waitfor = FALSE   <---- DONT DO THIS!We WANT this power to hold up ClickWithPower(), so that we can unlock the power when it's done.

	var/mob/living/user = owner
	var/mob/living/carbon/target = A
	var/turf/T = get_turf(target)

	// Clear Vars
	owner.pulling = null

	// Will we Knock them Down?
	var/do_knockdown = !is_A_facing_B(target,owner) || owner.alpha <= 0 || istype(owner.loc, /obj/structure/closet)
	// CAUSES: Target has their back to me, I'm invisible, or I'm in a Closet

	// Step One: Heatseek toward Target's Turf
	walk_towards(owner, T, 0.1, 10) // NOTE: this runs in the background! to cancel it, you need to use walk(owner.current,0), or give them a new path.
	var/safety = 10
	while(get_turf(owner) != T && safety > 0 && !(isliving(target) && target.Adjacent(owner)))
		user.mobility_flags &= ~MOBILITY_MOVE // No Motion Bro
		sleep(1)
		safety --

		// Did I get knocked down?
		if (owner && owner.incapacitated())
			if (!(user.mobility_flags & MOBILITY_STAND))
				var/send_dir = get_dir(owner, T)
				new /datum/forced_movement(owner, get_ranged_target_turf(owner, send_dir, 1), 1, FALSE)
				owner.spin(10)
			break


	// Step Two: Check if I'm at/adjectent to Target's CURRENT turf (not original...that was just a destination)
	if (target.Adjacent(owner))
		// LEVEL 2: If behind target, mute or unconscious!
		if (do_knockdown) // && level_current >= 1)
			target.Paralyze(15 + 10 * level_current,1)
		// Cancel Walk (we were close enough to contact them)
		walk(owner,0)
		//target.Paralyze(10,1)
		target.grabbedby(owner) 										// Taken from mutations.dm under changelings
		target.grippedby(owner, instant = TRUE) //instant aggro grab

		//	UNCONSCIOUS or MUTE!
		//owner.start_pulling(target,GRAB_AGGRESSIVE)    // GRAB_PASSIVE, GRAB_AGGRESSIVE, GRAB_NECK, GRAB_KILL

	//DeactivatePower()


/datum/action/bloodsucker/targeted/lunge/DeactivatePower(mob/living/user = owner, mob/living/target)
	..() // activate = FALSE
	user.update_mobility()
