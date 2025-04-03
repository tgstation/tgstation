/**
 *	# Assigning Sol
 *
 *	Sol is the sunlight, during this period, all Bloodsuckers must be in their coffin, else they burn.
 */

/// Start Sol, called when someone is assigned Bloodsucker
/datum/antagonist/bloodsucker/proc/check_start_sunlight()
	var/list/existing_suckers = get_antag_minds(/datum/antagonist/bloodsucker) - owner
	if(!length(existing_suckers))
		message_admins("New Sol has been created due to Bloodsucker assignment.")
		SSsunlight.can_fire = TRUE

/// End Sol, if you're the last Bloodsucker
/datum/antagonist/bloodsucker/proc/check_cancel_sunlight()
	var/list/existing_suckers = get_antag_minds(/datum/antagonist/bloodsucker) - owner
	if(!length(existing_suckers))
		message_admins("Sol has been deleted due to the lack of Bloodsuckers")
		SSsunlight.can_fire = FALSE

///Ranks the Bloodsucker up, called by Sol.
/datum/antagonist/bloodsucker/proc/sol_rank_up(atom/source)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(RankUp))

///Called when Sol is near starting.
/datum/antagonist/bloodsucker/proc/sol_near_start(atom/source)
	SIGNAL_HANDLER
	if(bloodsucker_lair_area && !(locate(/datum/action/cooldown/bloodsucker/gohome) in powers))
		BuyPower(new /datum/action/cooldown/bloodsucker/gohome)

///Called when Sol first ends.
/datum/antagonist/bloodsucker/proc/on_sol_end(atom/source)
	SIGNAL_HANDLER
	check_end_torpor()
	for(var/datum/action/cooldown/bloodsucker/power in powers)
		if(istype(power, /datum/action/cooldown/bloodsucker/gohome))
			RemovePower(power)

/// Cycle through all vamp antags and check if they're inside a closet.
/datum/antagonist/bloodsucker/proc/handle_sol()
	SIGNAL_HANDLER
	if(!owner || !owner.current)
		return

	if(!istype(owner.current.loc, /obj/structure))
		if(COOLDOWN_FINISHED(src, bloodsucker_spam_sol_burn))
			if(bloodsucker_level > 0)
				to_chat(owner, span_userdanger("The solar flare sets your skin ablaze!"))
			else
				to_chat(owner, span_userdanger("The solar flare scalds your neophyte skin!"))
			COOLDOWN_START(src, bloodsucker_spam_sol_burn, BLOODSUCKER_SPAM_SOL) //This should happen twice per Sol

		if(owner.current.fire_stacks <= 0)
			owner.current.fire_stacks = 0
		if(bloodsucker_level > 0)
			owner.current.adjust_fire_stacks(0.2 + bloodsucker_level / 10)
			owner.current.ignite_mob()
		owner.current.adjustFireLoss(2 + (bloodsucker_level / 2))
		owner.current.updatehealth()
		owner.current.add_mood_event("vampsleep", /datum/mood_event/daylight_2)
		return

	if(istype(owner.current.loc, /obj/structure/closet/crate/coffin)) // Coffins offer the BEST protection
		if(owner.current.am_staked() && COOLDOWN_FINISHED(src, bloodsucker_spam_sol_burn))
			to_chat(owner.current, span_userdanger("You are staked! Remove the offending weapon from your heart before sleeping."))
			COOLDOWN_START(src, bloodsucker_spam_sol_burn, BLOODSUCKER_SPAM_SOL) //This should happen twice per Sol
		if(!HAS_TRAIT(owner.current, TRAIT_NODEATH))
			check_begin_torpor(TRUE)
			owner.current.add_mood_event("vampsleep", /datum/mood_event/coffinsleep)
		dirty_area()
		return

	if(COOLDOWN_FINISHED(src, bloodsucker_spam_sol_burn)) // Closets offer SOME protection
		to_chat(owner, span_warning("Your skin sizzles. [owner.current.loc] doesn't protect well against UV bombardment."))
		COOLDOWN_START(src, bloodsucker_spam_sol_burn, BLOODSUCKER_SPAM_SOL) //This should happen twice per Sol
	owner.current.adjustFireLoss(0.5 + (bloodsucker_level / 4))
	owner.current.updatehealth()
	owner.current.add_mood_event("vampsleep", /datum/mood_event/daylight_1)

///Makes the area the bloodsucker is currently in dirty with cobweb and dirt.
/datum/antagonist/bloodsucker/proc/dirty_area()
	var/list/turf/area_turfs = get_area_turfs(get_area(owner.current))
	var/turf/turf_to_be_dirtied = pick(area_turfs)
	if(turf_to_be_dirtied && !turf_to_be_dirtied.density)
		var/turf/north_turf = get_step(turf_to_be_dirtied, NORTH)
		if(istype(north_turf, /turf/closed/wall))
			var/turf/west_turf = get_step(turf_to_be_dirtied, WEST)
			if(istype(west_turf, /turf/closed/wall))
				new /obj/effect/decal/cleanable/cobweb(turf_to_be_dirtied)
			var/turf/east_turf = get_step(turf_to_be_dirtied, EAST)
			if(istype(east_turf, /turf/closed/wall))
				new /obj/effect/decal/cleanable/cobweb/cobweb2(turf_to_be_dirtied)
		new /obj/effect/decal/cleanable/dirt(turf_to_be_dirtied)

/datum/antagonist/bloodsucker/proc/give_warning(atom/source, danger_level, vampire_warning_message, vassal_warning_message)
	SIGNAL_HANDLER
	if(!owner)
		return
	to_chat(owner, vampire_warning_message)

	switch(danger_level)
		if(DANGER_LEVEL_FIRST_WARNING)
			owner.current.playsound_local(null, 'modular_meta/features/antagonists/bloodsuckers/sounds/griffin_3.ogg', 50, 1)
		if(DANGER_LEVEL_SECOND_WARNING)
			owner.current.playsound_local(null, 'modular_meta/features/antagonists/bloodsuckers/sounds/griffin_5.ogg', 50, 1)
		if(DANGER_LEVEL_THIRD_WARNING)
			owner.current.playsound_local(null, 'sound/effects/alert.ogg', 75, 1)
		if(DANGER_LEVEL_SOL_ROSE)
			owner.current.playsound_local(null, 'sound/ambience/misc/ambimystery.ogg', 75, 1)
		if(DANGER_LEVEL_SOL_ENDED)
			owner.current.playsound_local(null, 'sound/music/antag/bloodcult/ghosty_wind.ogg', 90, 1)
