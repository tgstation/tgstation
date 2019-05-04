
// Level 1: Speed to location
// Level 2: Dodge Bullets
// Level 3: Stun People Passed

/datum/action/bloodsucker/targeted/haste
	name = "Immortal Haste"
	desc = "Sprint anywhere in the blink of an eye, slipping past open doors. Those nearby may be knocked away."
	button_icon_state = "power_speed"
	bloodcost = 6
	cooldown = 50
	target_range = 15
	power_activates_immediately = TRUE
	message_Trigger = ""//"Whom will you subvert to your will?"
	bloodsucker_can_buy = TRUE

	var/datum/martial_art/vamphaste/haste_cqc	// Assign this when




/datum/action/bloodsucker/targeted/haste/CheckCanUse(display_error)
	if(!..(display_error))// DEFAULT CHECKS
		return FALSE
	// Being Grabbed
	if (owner.pulledby && owner.pulledby.grab_state >= GRAB_AGGRESSIVE)
		if (display_error)
			to_chat(owner, "<span class='warning'>You're being grabbed!</span>")
		return FALSE
	// Not Correct State
	if (owner.incapacitated())
		if (display_error)
			to_chat(owner, "<span class='warning'>Not while you're incapacitated!</span>")
		return FALSE
	return TRUE


/datum/action/bloodsucker/targeted/haste/CheckValidTarget(atom/A)
	return isturf(A) || A.loc != owner.loc // Anything will do, if it's not me or my square


/datum/action/bloodsucker/targeted/haste/CheckCanTarget(mob/living/target,display_error)
	// Check: Range
	if (!(target in view(target_range, get_turf(owner))))
		return FALSE
	return TRUE



/datum/action/bloodsucker/targeted/haste/FireTargetedPower(atom/A)
	// set waitfor = FALSE   <---- DONT DO THIS!We WANT this power to hold up ClickWithPower(), so that we can unlock the power when it's done.

	var/mob/living/user = owner
	var/turf/T = isturf(A) ? A : get_turf(A)

	// Step One: Heatseek toward Target's Turf
	walk_to(owner, T, 0, 0.05, 20) // NOTE: this runs in the background! to cancel it, you need to use walk(owner.current,0), or give them a new path.
	playsound(get_turf(owner), 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	var/safety = 20
	while(get_turf(owner) != T && safety > 0 && !(isliving(target) && target.Adjacent(owner)))
		user.mobility_flags &= ~MOBILITY_MOVE // No Motion Bro
		safety --

		// Did I get knocked down?
		if (owner && owner.incapacitated())
			if (user.lying)
				var/send_dir = get_dir(owner, T)
				new /datum/forced_movement(owner, get_ranged_target_turf(owner, send_dir, 1), 1, FALSE)
				owner.spin(10)
			break

		// Spin/Stun people we pass.
		var/mob/living/newtarget = locate(/mob/living) in oview(1, owner)
		if (newtarget && newtarget != target)//!newtarget.IsKnockdown())
			if (rand(0,5) == 0)
				playsound(get_turf(newtarget), "sound/weapons/punch[rand(1,4)].ogg", 15, 1, -1)
				newtarget.Knockdown(10)
			newtarget.Stun(5)
			if(newtarget.IsStun())
				newtarget.spin(10,1)
		sleep(1)

	if (user)
		user.update_mobility()


/datum/action/bloodsucker/targeted/haste/DeactivatePower(mob/living/user = owner, mob/living/target)
	..() // activate = FALSE
	user.update_mobility()






/*
/datum/martial_art/vamphaste			// martial.dm
	name = "Vampiric Haste"
	id = "" //ID, used by mind/has_martialart
	streak = ""
	max_streak_length = 6
	current_target
	datum/martial_art/base // The permanent style. This will be null unless the martial art is temporary
	deflection_chance = 0 //Chance to deflect projectiles
	reroute_deflection = FALSE //Delete the bullet, or actually deflect it in some direction?
	block_chance = 0 //Chance to block melee attacks using items while on throw mode.
	restraining = 0 //used in cqc's disarm_act to check if the disarmed is being restrained and so whether they should be put in a chokehold or not
	help_verb
	no_guns = FALSE
	allow_temp_override = TRUE //if this martial art can be overridden by temporary martial arts
*/