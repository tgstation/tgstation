/datum/action/cooldown/lunatic_track
	name = "Moonlight Echo"
	desc = "Track your ringleader."
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_heretic"
	button_icon_state = "moon_smile"
	ranged_mousepointer = 'icons/effects/mouse_pointers/moon_target.dmi'
	cooldown_time = 4 SECONDS

/datum/action/cooldown/lunatic_track/Grant(mob/granted)
	if(!IS_LUNATIC(granted))
		return

	return ..()

/datum/action/cooldown/lunatic_track/Activate(atom/target)
	var/datum/antagonist/lunatic/lunatic_datum = IS_LUNATIC(owner)
	var/mob/living/carbon/human/ascended_heretic = lunatic_datum.ascended_body
	if(!(ascended_heretic))
		owner.balloon_alert(owner, "what cruel fate, your master is gone...")
		StartCooldown(1 SECONDS)
		return FALSE
	playsound(owner, 'sound/effects/singlebeat.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	owner.balloon_alert(owner, get_balloon_message(ascended_heretic))

	if(ascended_heretic.stat == DEAD)
		to_chat(owner, span_hierophant("[ascended_heretic] is dead. Weep for the lie has struck out."))

	StartCooldown()
	return TRUE


/// Gets the balloon message for the heretic we are tracking.
/datum/action/cooldown/lunatic_track/proc/get_balloon_message(mob/living/carbon/human/tracked_mob)
	var/balloon_message = "error text!"
	var/turf/their_turf = get_turf(tracked_mob)
	var/turf/our_turf = get_turf(owner)
	var/their_z = their_turf?.z
	var/our_z = our_turf?.z

	// One of us is in somewhere we shouldn't be
	if(!our_z || !their_z)
		// "Hell if I know"
		balloon_message = "on another plane!"

	// They're not on the same z-level as us
	else if(our_z != their_z)
		// They're on the station
		if(is_station_level(their_z))
			// We're on a multi-z station
			if(is_station_level(our_z))
				if(our_z > their_z)
					balloon_message = "below you!"
				else
					balloon_message = "above you!"
			// We're off station, they're not
			else
				balloon_message = "on station!"

		// Mining
		else if(is_mining_level(their_z))
			balloon_message = "on lavaland!"

		// In the gateway
		else if(is_away_level(their_z) || is_secret_level(their_z))
			balloon_message = "beyond the gateway!"

		// They're somewhere we probably can't get too - sacrifice z-level, centcom, etc
		else
			balloon_message = "on another plane!"

	// They're on the same z-level as us!
	else
		var/dist = get_dist(our_turf, their_turf)
		var/dir = get_dir(our_turf, their_turf)

		switch(dist)
			if(0 to 15)
				balloon_message = "very near, [dir2text(dir)]!"
			if(16 to 31)
				balloon_message = "near, [dir2text(dir)]!"
			if(32 to 127)
				balloon_message = "far, [dir2text(dir)]!"
			else
				balloon_message = "very far!"

	if(tracked_mob.stat == DEAD)
		balloon_message = "they're dead, " + balloon_message

	return balloon_message
