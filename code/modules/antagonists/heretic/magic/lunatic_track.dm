/datum/action/cooldown/lunatic_track
	name = "Moonlight Echo"
	desc = "Track your ringleader."
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "moon_smile"
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
	var/balloon_message = generate_balloon_message(tracked_mob)
	if(tracked_mob.stat == DEAD)
		balloon_message = "they're dead, " + balloon_message

	return balloon_message

/// Create the text for the balloon message
/datum/action/cooldown/lunatic_track/proc/generate_balloon_message(mob/living/carbon/human/tracked_mob)
	var/balloon_message = "error text!"
	var/turf/their_turf = get_turf(tracked_mob)
	var/turf/our_turf = get_turf(owner)
	var/their_z = their_turf?.z
	var/our_z = our_turf?.z

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

	// Early returns here if we don't need to tell them the z-levels
	if(our_z == their_z)
		return balloon_message

	if(is_mining_level(their_z))
		balloon_message = "on lavaland!"
		return balloon_message

	if(is_away_level(their_z) || is_secret_level(their_z))
		balloon_message = "beyond the gateway!"
		return balloon_message

	// We already checked if they are on lavaland or gateway, so if they arent there or on the station we can early return
	if(!is_station_level(their_z))
		balloon_message = "on another plane!"
		return balloon_message

	// They must be on station because we have checked every other z-level, and since we arent on station we should go there
	if(!is_station_level(our_z))
		balloon_message = "on station!"
		return balloon_message

	if(our_z > their_z)
		balloon_message = "below you!"
		return balloon_message

	if(our_z < their_z)
		balloon_message = "above you!"
		return balloon_message

	return balloon_message
