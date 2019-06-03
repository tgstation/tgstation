

/datum/action/bloodsucker/cloak
	name = "Cloak of Darkness"
	desc = "Blend into the shadows and become invisible to the untrained eye."
	button_icon_state = "power_cloak"
	bloodcost = 5
	cooldown = 50
	bloodsucker_can_buy = TRUE
	amToggle = TRUE
	warn_constant_cost = TRUE

	var/light_min = 0.5 	// If lum is above this, no good.
	var/remember_start_loc	// Where this power was activated, so it can be checked from ContinueActive
	// Level Up
	var/upgrade_canMove = FALSE	// Can I move around with this power?

/datum/action/bloodsucker/cloak/CheckCanUse(display_error)
	if(!..(display_error))// DEFAULT CHECKS
		return FALSE
	// Must be Dark
	var/turf/T = owner.loc
	if(istype(T) && T.get_lumcount() > light_min)
		to_chat(owner, "<span class='warning'>This area is not dark enough to blend in</span>")
		return FALSE
	return TRUE

/datum/action/bloodsucker/cloak/ActivatePower()

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	var/mob/living/user = owner
	remember_start_loc = user.loc

	// Freeze in Place (so you don't auto-cancel)
	user.mobility_flags &= ~MOBILITY_MOVE
	while (bloodsuckerdatum && ContinueActive(user))

		//if (!do_mob(user, user, 10, 0, 0, extra_checks=CALLBACK(src, .proc/ContinueActive, user, target)))
		//	return

		// Fade from sight
		owner.alpha = max(0, owner.alpha - min(75, 20 + 15 * level_current))
		bloodsuckerdatum.AddBloodVolume(-0.2)

		sleep(5)

/datum/action/bloodsucker/cloak/ContinueActive(mob/living/user, mob/living/target)
	if (!..())
		return FALSE
	// Must be CONSCIOUS
	if (user.stat > CONSCIOUS)
		to_chat(owner, "<span class='warning'>DEBUG: FAIL STAT </span>")
		return FALSE
	// Must be SAME LOCATION
	var/turf/T = owner.loc
	if (!upgrade_canMove && T != remember_start_loc)
		to_chat(owner, "<span class='warning'>DEBUG: FAIL MOVE [T] vs [remember_start_loc] </span>")
		return FALSE
	// Must be DARK
	if(istype(T) && T.get_lumcount() > light_min)
		to_chat(owner, "<span class='warning'>DEBUG: FAIL DARK</span>")
		return FALSE
	return TRUE


/datum/action/bloodsucker/cloak/DeactivatePower(mob/living/user = owner, mob/living/target)
	..()
	user.alpha = 255
