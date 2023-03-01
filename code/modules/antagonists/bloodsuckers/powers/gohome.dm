/datum/action/bloodsucker/gohome
	name = "Vanishing Act"
	desc = "As dawn aproaches, disperse into mist and return directly to your Lair.<br><b>WARNING:</b> You will drop <b>ALL</b> of your possessions if observed by mortals."
	button_icon_state = "power_gohome"
	background_icon_state_on = "vamp_power_off_oneshot"
	background_icon_state_off = "vamp_power_off_oneshot"
	power_explanation = "<b>Vanishing Act</b>: \n\
		Activating Vanishing Act will, after a short delay, teleport the user to their <b>Claimed Coffin</b>. \n\
		The power will cancel out if the <b>Claimed Coffin</b> is somehow destroyed. \n\
		Immediately after activating, lights around the user will begin to flicker. \n\
		Once the user teleports to their coffin, in their place will be a Rat or Bat."
	power_flags = BP_AM_SINGLEUSE|BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_STAKED|BP_CANT_USE_WHILE_INCAPACITATED
	// You only get this once you've claimed a lair and Sol is near.
	purchase_flags = NONE
	bloodcost = 100
	cooldown = 100 SECONDS

/datum/action/bloodsucker/gohome/CheckCanUse(mob/living/carbon/user)
	. = ..()
	if(!.)
		return FALSE
	/// Have No Lair (NOTE: You only got this power if you had a lair, so this means it's destroyed)
	if(!istype(bloodsuckerdatum_power) || !bloodsuckerdatum_power.coffin)
		to_chat(owner, span_warning("Your coffin has been destroyed!"))
		return FALSE
	return TRUE

/datum/action/bloodsucker/gohome/proc/flicker_lights(flicker_range, beat_volume)
	for(var/obj/machinery/light/nearby_lights in view(flicker_range, get_turf(owner)))
		nearby_lights.flicker(5)
	playsound(get_turf(owner), 'sound/effects/singlebeat.ogg', beat_volume, 1)

/// IMPORTANT: Check for lair at every step! It might get destroyed.
/datum/action/bloodsucker/gohome/ActivatePower()
	. = ..()
	to_chat(owner, span_notice("You focus on separating your consciousness from your physical form..."))
	/// STEP ONE: Flicker Lights
	flicker_lights(3, 20)
	sleep(50)
	flicker_lights(4, 40)
	sleep(50)
	flicker_lights(4, 60)
	for(var/obj/machinery/light/nearby_lights in view(6, get_turf(owner)))
		nearby_lights.flicker(5)
	playsound(get_turf(owner), 'sound/effects/singlebeat.ogg', 60, 1)
	/// STEP TWO: Lights OFF?
	/// CHECK: Still have Coffin?
	if(!bloodsuckerdatum_power.coffin)
		to_chat(owner, span_warning("Your coffin has been destroyed! You no longer have a destination."))
		return FALSE
	if(!owner)
		return
	/// SEEN?: (effects ONLY if there are witnesses! Otherwise you just POOF)

	/// Do Effects (seen by anyone)
	var/am_seen = FALSE
	/// Drop Stuff (seen by non-vamp)
	var/drop_item = FALSE
	// Only check if I'm not in a Locker or something.
	if(!isturf(owner.loc))
		return
	// A) Check for Darkness (we can just leave)
	var/turf/current_turf = get_turf(owner)
	if(current_turf && current_turf.lighting_object && current_turf.get_lumcount()>= 0.1)
		// B) Check for Viewers
		for(var/mob/living/watchers in viewers(world.view, get_turf(owner)) - owner)
			if(watchers.client && !watchers.has_unlimited_silicon_privilege && !watchers.eye_blind)
				am_seen = TRUE
				if(!IS_BLOODSUCKER(watchers) && !IS_VASSAL(watchers))
					drop_item = TRUE
					break
	/// LOSE CUFFS
	var/mob/living/carbon/user = owner
	if(user.handcuffed)
		var/obj/handcuffs = user.handcuffed
		user.dropItemToGround(handcuffs)
	if(user.legcuffed)
		var/obj/legcuffs = user.legcuffed
		user.dropItemToGround(legcuffs)
	/// SEEN!
	if(drop_item)
		// DROP: Clothes, held items, and cuffs etc
		// NOTE: Taken from unequip_everything() in inventory.dm. We need to
		// *force* all items to drop, so we had to just gut the code out of it.
		var/list/items = list()
		items |= user.get_equipped_items()
		for(var/belongings in items)
			user.dropItemToGround(belongings, TRUE)
		for(var/obj/item/held_posessions in owner.held_items) //drop_all_held_items()
			user.dropItemToGround(held_posessions, TRUE)
	/// POOF EFFECTS
	if(am_seen)
		playsound(get_turf(owner), 'sound/magic/summon_karp.ogg', 60, 1)
		var/datum/effect_system/steam_spread/puff = new /datum/effect_system/steam_spread()
		puff.effect_type = /obj/effect/particle_effect/smoke/vampsmoke
		puff.set_up(3, 0, get_turf(owner))
		puff.start()

	/// STEP FIVE: Create animal at prev location
	var/mob/living/simple_animal/SA = pick(/mob/living/simple_animal/mouse,/mob/living/simple_animal/mouse,/mob/living/simple_animal/mouse, /mob/living/simple_animal/hostile/retaliate/bat) //prob(300) /mob/living/simple_animal/mouse,
	new SA (owner.loc)
	/// TELEPORT: Move to Coffin & Close it!
	user.set_resting(TRUE, TRUE, FALSE)
	do_teleport(owner, bloodsuckerdatum_power.coffin, no_effects = TRUE, forced = TRUE, channel = TELEPORT_CHANNEL_QUANTUM)
	user.Stun(3 SECONDS, TRUE)
	/// CLOSE LID: If fail, force me in.
	if(!bloodsuckerdatum_power.coffin.close(owner))
		/// Puts me inside.
		bloodsuckerdatum_power.coffin.insert(owner)
		playsound(bloodsuckerdatum_power.coffin.loc, bloodsuckerdatum_power.coffin.close_sound, 15, 1, -3)
		bloodsuckerdatum_power.coffin.opened = FALSE
		bloodsuckerdatum_power.coffin.density = TRUE
		bloodsuckerdatum_power.coffin.update_icon()
		// Lock Coffin
		bloodsuckerdatum_power.coffin.LockMe(owner)
		bloodsuckerdatum_power.Check_Begin_Torpor(FALSE) // Are we meant to enter Torpor here?
