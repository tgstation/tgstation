SUBSYSTEM_DEF(polling)
	name = "Polling"
	flags = SS_BACKGROUND | SS_NO_INIT
	wait = 1 SECONDS
	runlevels = RUNLEVEL_GAME
	/// List of polls currently ongoing, to be checked on next fire()
	var/list/datum/candidate_poll/currently_polling
	/// Number of polls performed since the start
	var/total_polls = 0

/datum/controller/subsystem/polling/fire()
	if(!currently_polling) // if polls_active is TRUE then this shouldn't happen, but still..
		currently_polling = list()

	for(var/datum/candidate_poll/running_poll as anything in currently_polling)
		if(running_poll.time_left() <= 0)
			polling_finished(running_poll)

/datum/controller/subsystem/polling/proc/poll_candidates(question, role, check_jobban, poll_time = 30 SECONDS, ignore_category = null, flash_window = TRUE, list/group = null, pic_source, role_name_text)
	if(group.len == 0)
		return list()
	if(role && !role_name_text)
		role_name_text = role
	if(role_name_text && !question)
		question = "Do you want to play as [full_capitalize(role_name_text)]?"
	if(!question)
		question = "Do you want to play as a special role?"
	log_game("Polling candidates [role_name_text ? "for [role_name_text]" : "\"[question]\""] for [DisplayTimeText(poll_time)] seconds")

	// Start firing
	total_polls++

	var/jumpable = isatom(pic_source) ? pic_source : null

	var/datum/candidate_poll/new_poll = new(role_name_text, question, poll_time, ignore_category, jumpable)
	LAZYADD(currently_polling, new_poll)

	var/category = "[new_poll.poll_key]_poll_alert"

	for(var/mob/candidate_mob as anything in group)
		// Universal opt-out for all players.
		if((!candidate_mob.client.prefs.read_preference(/datum/preference/toggle/ghost_roles)))
			continue
		// Opt-out for admins whom are currently adminned.
		if((!candidate_mob.client.prefs.read_preference(/datum/preference/toggle/ghost_roles_as_admin)) && candidate_mob.client.holder)
			continue
		if(!is_eligible(candidate_mob, role, check_jobban, ignore_category))
			continue

		SEND_SOUND(candidate_mob, 'sound/misc/notice2.ogg')
		if(flash_window)
			window_flash(candidate_mob.client)

		// If we somehow send two polls for the same mob type, but with a duration on the second one shorter than the time left on the first one,
		// we need to keep the first one's timeout rather than use the shorter one
		var/atom/movable/screen/alert/poll_alert/current_alert = LAZYACCESS(candidate_mob.alerts, category)
		var/alert_time = poll_time
		var/alert_poll = new_poll
		if(current_alert && current_alert.timeout > (world.time + poll_time - world.tick_lag))
			alert_time = current_alert.timeout - world.time + world.tick_lag
			alert_poll = current_alert.poll

		// Send them an on-screen alert
		var/atom/movable/screen/alert/poll_alert/poll_alert_button = candidate_mob.throw_alert(category, /atom/movable/screen/alert/poll_alert, timeout_override = alert_time, no_anim = TRUE)
		if(!poll_alert_button)
			continue

		poll_alert_button.icon = ui_style2icon(candidate_mob.client?.prefs?.read_preference(/datum/preference/choiced/ui_style))
		poll_alert_button.desc = "[question]"
		poll_alert_button.show_time_left = TRUE
		poll_alert_button.poll = alert_poll
		poll_alert_button.poll.alert_button = poll_alert_button
		poll_alert_button.set_role_overlay()
		poll_alert_button.update_stacks_overlay()

		// Sign up inheritance and stacking
		var/inherited_sign_up = FALSE
		for(var/existing_poll in currently_polling)
			var/datum/candidate_poll/other_poll = existing_poll
			if(new_poll != other_poll && new_poll.poll_key == other_poll.poll_key)
				// If there's already a poll for an identical mob type ongoing and the client is signed up for it, sign them up for this one
				if(!inherited_sign_up && (candidate_mob in other_poll.signed_up) && new_poll.sign_up(candidate_mob, TRUE))
					inherited_sign_up = TRUE

		// Image to display
		var/image/poll_image
		if(pic_source)
			if(!ispath(pic_source))
				var/atom/the_pic_source = pic_source
				var/old_layer = the_pic_source.layer
				var/old_plane = the_pic_source.plane
				the_pic_source.plane = poll_alert_button.plane
				the_pic_source.layer = FLOAT_LAYER
				poll_alert_button.add_overlay(the_pic_source)
				the_pic_source.layer = old_layer
				the_pic_source.plane = old_plane
			else
				poll_image = image(pic_source, layer = FLOAT_LAYER)
		else
			// Just use a generic image
			poll_image = image('icons/effects/effects.dmi', icon_state = "static", layer = FLOAT_LAYER)

		if(poll_image)
			poll_image.plane = poll_alert_button.plane
			poll_alert_button.add_overlay(poll_image)

		// Chat message
		var/act_jump = ""
		if(isatom(pic_source) && isobserver(candidate_mob))
			act_jump = "<a href='?src=[REF(poll_alert_button)];jump=1'>\[Teleport]</a>"
		var/act_signup = "<a href='?src=[REF(poll_alert_button)];signup=1'>\[Sign Up]</a>"
		var/act_never = ""
		if(ignore_category)
			act_never = "<a href='?src=[REF(poll_alert_button)];never=1'>\[Never For This Round]</a>"
		to_chat(candidate_mob, span_boldnotice(examine_block("Now looking for candidates [role_name_text ? "to play as \an [role_name_text]." : "\"[question]\""] [act_jump] [act_signup] [act_never]")))

		// Start processing it so it updates visually the timer
		START_PROCESSING(SSprocessing, poll_alert_button)

	// Sleep until the time is up
	UNTIL(new_poll.finished)
	return new_poll.signed_up

/datum/controller/subsystem/polling/proc/poll_ghost_candidates(question, role, check_jobban, poll_time = 30 SECONDS, ignore_category = null, flashwindow = TRUE, pic_source, role_name_text)
	var/list/candidates = list()
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return candidates

	for(var/mob/dead/observer/ghost_player in GLOB.player_list)
		candidates += ghost_player

	return poll_candidates(question, role, check_jobban, poll_time, ignore_category, flashwindow, candidates, pic_source, role_name_text)

/datum/controller/subsystem/polling/proc/poll_ghost_candidates_for_mob(question, role, check_jobban, poll_time = 30 SECONDS, mob/target_mob, ignore_category = null, flashwindow = TRUE, pic_source, role_name_text)
	var/static/list/mob/currently_polling_mobs = list()

	if(currently_polling_mobs.Find(target_mob))
		return list()

	currently_polling_mobs += target_mob

	var/list/possible_candidates = poll_ghost_candidates(question, role, check_jobban, poll_time, ignore_category, flashwindow, pic_source, role_name_text)

	currently_polling_mobs -= target_mob
	if(!target_mob || QDELETED(target_mob) || !target_mob.loc)
		return list()

	return possible_candidates

/datum/controller/subsystem/polling/proc/poll_ghost_candidates_for_mobs(question, role, check_jobban, poll_time = 30 SECONDS, list/mobs, ignore_category = null, flashwindow = TRUE, pic_source, role_name_text)
	var/list/candidate_list = poll_ghost_candidates(question, role, check_jobban, poll_time, ignore_category, flashwindow, pic_source, role_name_text)

	for(var/mob/potential_mob as anything in mobs)
		if(QDELETED(potential_mob) || !potential_mob.loc)
			mobs -= potential_mob

	if(!length(mobs))
		return list()

	return candidate_list

/datum/controller/subsystem/polling/proc/is_eligible(mob/potential_candidate, role, check_jobban, the_ignore_category)
	if(isnull(potential_candidate.key) || isnull(potential_candidate.client))
		return FALSE
	if(the_ignore_category)
		if(potential_candidate.ckey in GLOB.poll_ignore[the_ignore_category])
			return FALSE
	if(role)
		if(!(role in potential_candidate.client.prefs.be_special))
			return FALSE
		var/required_time = GLOB.special_roles[role] || 0
		if(potential_candidate.client && potential_candidate.client.get_remaining_days(required_time) > 0)
			return FALSE

	if(check_jobban)
		if(is_banned_from(potential_candidate.ckey, list(check_jobban, ROLE_SYNDICATE)))
			return FALSE

	return TRUE

/datum/controller/subsystem/polling/proc/polling_finished(datum/candidate_poll/finishing_poll)
	// Trim players who aren't eligible anymore
	var/length_pre_trim = length(finishing_poll.signed_up)
	finishing_poll.trim_candidates()
	log_game("Candidate poll [finishing_poll.role ? "for [finishing_poll.role]" : "\"[finishing_poll.question]\""] finished. [length_pre_trim] players signed up, [length(finishing_poll.signed_up)] after trimming")
	finishing_poll.finished = TRUE
	finishing_poll.alert_button.update_stacks_overlay()
	currently_polling -= finishing_poll

/datum/controller/subsystem/polling/stat_entry(msg)
	msg += "Active: [length(currently_polling)] | Total: [total_polls]"
	var/datum/candidate_poll/soonest_to_complete = get_next_poll_to_finish()
	if(soonest_to_complete)
		msg += " | Next: [DisplayTimeText(soonest_to_complete.time_left())] ([length(soonest_to_complete.signed_up)] candidates)"
	return ..()

/datum/controller/subsystem/polling/proc/get_next_poll_to_finish()
	var/lowest_time_left = INFINITY
	var/next_poll_to_finish
	for(var/datum/candidate_poll/poll as anything in currently_polling)
		var/time_left = poll.time_left()
		if(time_left >= lowest_time_left)
			continue
		lowest_time_left = time_left
		next_poll_to_finish = poll

	if(isnull(next_poll_to_finish))
		return FALSE

	return next_poll_to_finish
