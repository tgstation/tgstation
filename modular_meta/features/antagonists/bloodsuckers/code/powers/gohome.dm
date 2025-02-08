#define GOHOME_START 0
#define GOHOME_FLICKER_ONE 2
#define GOHOME_FLICKER_TWO 4
#define GOHOME_TELEPORT 6

/**
 * Given to Bloodsuckers near Sol if they have a Coffin claimed.
 * Teleports them to their Coffin after a delay.
 * Makes them drop everything if someone witnesses the act.
 */
/datum/action/cooldown/bloodsucker/gohome
	name = "Vanishing Act"
	desc = "As dawn aproaches, disperse into mist and return directly to your Lair.<br><b>WARNING:</b> You will drop <b>ALL</b> of your possessions if observed by mortals."
	button_icon_state = "power_gohome"
	active_background_icon_state = "vamp_power_off_oneshot"
	base_background_icon_state = "vamp_power_off_oneshot"
	power_explanation = "Vanishing Act: \n\
		Activating Vanishing Act will, after a short delay, teleport the user to their claimed coffin. \n\
		The power will cancel out if the claimed coffin is somehow destroyed. \n\
		Immediately after activating, lights around the user will begin to flicker. \n\
		Once the user teleports to their coffin, a rat or bat will appear at their prior location."
	power_flags = BP_AM_TOGGLE|BP_AM_SINGLEUSE|BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_STAKED
	purchase_flags = NONE
	bloodcost = 100
	constant_bloodcost = 2
	cooldown_time = 100 SECONDS
	///What stage of the teleportation are we in
	var/teleporting_stage = GOHOME_START
	///The types of mobs that will drop post-teleportation.
	var/static/list/spawning_mobs = list(
		/mob/living/basic/mouse = 3,
		/mob/living/basic/bat = 1,
	)

/datum/action/cooldown/bloodsucker/gohome/can_use(mob/living/carbon/user, trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	/// Have No Lair (NOTE: You only got this power if you had a lair, so this means it's destroyed)
	if(!istype(bloodsuckerdatum_power) || !bloodsuckerdatum_power.claimed_coffin)
		owner.balloon_alert(owner, "coffin was destroyed!")
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/gohome/ActivatePower(trigger_flags)
	. = ..()
	owner.balloon_alert(owner, "preparing to teleport...")

/datum/action/cooldown/bloodsucker/gohome/process(seconds_per_tick)
	. = ..()
	if(!.)
		return FALSE

	switch(teleporting_stage)
		if(GOHOME_START)
			INVOKE_ASYNC(src, PROC_REF(flicker_lights), 3, 20)
		if(GOHOME_FLICKER_ONE)
			INVOKE_ASYNC(src, PROC_REF(flicker_lights), 4, 40)
		if(GOHOME_FLICKER_TWO)
			INVOKE_ASYNC(src, PROC_REF(flicker_lights), 4, 60)
		if(GOHOME_TELEPORT)
			INVOKE_ASYNC(src, PROC_REF(teleport_to_coffin))
	teleporting_stage++

/datum/action/cooldown/bloodsucker/gohome/ContinueActive(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!isturf(owner.loc))
		return FALSE
	if(!bloodsuckerdatum_power.claimed_coffin)
		user.balloon_alert(user, "coffin destroyed!")
		to_chat(owner, span_warning("Your coffin has been destroyed! You no longer have a destination."))
		return FALSE
	return TRUE

///Flickers the lights in a flicker range around the owner and plays a beat that all nearby players can hear.
/datum/action/cooldown/bloodsucker/gohome/proc/flicker_lights(flicker_range, beat_volume)
	for(var/obj/machinery/light/nearby_lights in view(flicker_range, get_turf(owner)))
		nearby_lights.flicker(5)
	playsound(get_turf(owner), 'sound/effects/singlebeat.ogg', beat_volume, 1)

/**
 * teleport_to_coffin
 *
 * Checks if anyone is able to physically see the user, and if there is then we'll drop everything on them.
 * We'll then throw some smoke up, spawn a vampirical creature,
 * then lastly teleport the user to their coffin (properly, so it's closed up for Sol/Torpor).
 */
/datum/action/cooldown/bloodsucker/gohome/proc/teleport_to_coffin()
	var/drop_item = FALSE
	var/turf/current_turf = get_turf(owner)
	var/mob/living/carbon/user = owner
	// If we aren't in the dark, anyone watching us will cause us to drop out stuff
	if(current_turf && current_turf.lighting_object && current_turf.get_lumcount() >= 0.2)
		for(var/mob/living/watchers in viewers(world.view, get_turf(owner)) - owner)
			if(!watchers.client)
				continue
			if(issilicon(watchers) || isdrone(watchers) || isbot(watchers))
				continue
			if(watchers.is_blind())
				continue
			if(!IS_BLOODSUCKER(watchers) && !IS_VASSAL(watchers))
				drop_item = TRUE
				break
	// Drop all necessary items (handcuffs, legcuffs, items if seen)
	if(drop_item)
		for(var/obj/item/literally_everything in user.get_all_gear())
			owner.dropItemToGround(literally_everything, TRUE)

	playsound(current_turf, 'sound/effects/magic/summon_karp.ogg', 60, 1)

	var/datum/effect_system/steam_spread/bloodsucker/puff = new(user.loc)
	puff.set_up(3, 0, current_turf)
	puff.start()

	var/mob/living/basic/new_mob = pick_weight(spawning_mobs)
	new new_mob(current_turf)

	user.set_resting(TRUE, TRUE, FALSE)
	do_teleport(owner, bloodsuckerdatum_power.claimed_coffin, no_effects = TRUE, forced = TRUE, channel = TELEPORT_CHANNEL_QUANTUM)
	bloodsuckerdatum_power.claimed_coffin.close(owner)
	bloodsuckerdatum_power.claimed_coffin.take_contents()

	DeactivatePower()

/datum/effect_system/steam_spread/bloodsucker
	effect_type = /obj/effect/particle_effect/fluid/smoke/vampsmoke

#undef GOHOME_START
#undef GOHOME_FLICKER_ONE
#undef GOHOME_FLICKER_TWO
#undef GOHOME_TELEPORT
