/* Level 1: Speed to location
 * Level 2: Dodge Bullets
 * Level 3: Stun People Passed
 */

/datum/action/cooldown/bloodsucker/targeted/haste
	name = "Immortal Haste"
	desc = "Dash somewhere with supernatural speed. Those in your path may be knocked away, stunned, or left empty-handed."
	button_icon_state = "power_speed"
	power_explanation = "Immortal Haste:\n\
		Click a location to immediately dash towards it.\n\
		The power will not work if you are lying down, not under gravitational force, or are aggressively grabbed.\n\
		Anyone in your way during your Haste will be knocked down.\n\
		Higher levels will increase the knockdown dealt to enemies."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|VASSAL_CAN_BUY
	bloodcost = 6
	cooldown_time = 12 SECONDS
	target_range = 15
	power_activates_immediately = TRUE
	///List of all people hit by our power, so we don't hit them again.
	var/list/hit = list()

/datum/action/cooldown/bloodsucker/targeted/haste/can_use(mob/living/carbon/user, trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	// Being Grabbed
	if(user.pulledby && user.pulledby.grab_state >= GRAB_AGGRESSIVE)
		user.balloon_alert(user, "you're being grabbed!")
		return FALSE
	if(!user.has_gravity(user.loc)) //We dont want people to be able to use this to fly around in space
		user.balloon_alert(user, "you cannot dash while floating!")
		return FALSE
	if(user.body_position == LYING_DOWN)
		user.balloon_alert(user, "you must be standing to tackle!")
		return FALSE
	return TRUE

/// Anything will do, if it's not me or my square
/datum/action/cooldown/bloodsucker/targeted/haste/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return target_atom.loc != owner.loc

/// This is a non-async proc to make sure the power is "locked" until this finishes.
/datum/action/cooldown/bloodsucker/targeted/haste/FireTargetedPower(atom/target_atom)
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	var/mob/living/user = owner
	var/turf/targeted_turf = isturf(target_atom) ? target_atom : get_turf(target_atom)
	// Pulled? Not anymore.
	user.pulledby?.stop_pulling()
	// Go to target turf
	// DO NOT USE WALK TO.
	owner.balloon_alert(owner, "you dash into the air!")
	playsound(get_turf(owner), 'sound/items/weapons/punchmiss.ogg', 25, 1, -1)
	var/safety = get_dist(user, targeted_turf) * 3 + 1
	var/consequetive_failures = 0
	while(--safety && (get_turf(user) != targeted_turf))
		var/success = step_towards(user, targeted_turf) //This does not try to go around obstacles.
		if(!success)
			success = step_to(user, targeted_turf) //this does
		if(!success)
			consequetive_failures++
			if(consequetive_failures >= 3) //if 3 steps don't work
				break //just stop
		else
			consequetive_failures = 0 //reset so we can keep moving
		if(user.resting || user.incapacitated) //actually down? stop.
			break
		if(success) //don't sleep if we failed to move.
			sleep(world.tick_lag)

/datum/action/cooldown/bloodsucker/targeted/haste/power_activated_sucessfully()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	hit.Cut()

/datum/action/cooldown/bloodsucker/targeted/haste/proc/on_move()
	for(var/mob/living/hit_living in dview(1, get_turf(owner)) - owner)
		if(hit.Find(hit_living))
			continue
		hit += hit_living
		playsound(hit_living, "sound/items/weapons/punch[rand(1,4)].ogg", 15, 1, -1)
		hit_living.Knockdown(10 + level_current * 4)
		hit_living.spin(10, 1)
