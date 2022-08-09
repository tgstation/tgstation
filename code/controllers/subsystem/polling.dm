SUBSYSTEM_DEF(polling)
	name = "Polling"
	init_order = INIT_ORDER_EVENTS
	flags = SS_BACKGROUND
	wait = 1 SECONDS
	runlevels = RUNLEVEL_GAME

	/// List of polls currently ongoing, to be checked on next fire()
	var/list/datum/candidate_poll/currently_polling
	/// Whether there are active polls or not
	var/polls_active = FALSE
	/// Number of polls performed since the start
	var/total_polls = 0
	/// The poll that's closest to finishing
	var/datum/candidate_poll/next_poll_to_finish

/datum/controller/subsystem/polling/fire()
	if(!polls_active)
		return
	if(!currently_polling) // if polls_active is TRUE then this shouldn't happen, but still..
		currently_polling = list()

	for(var/poll in currently_polling)
		var/datum/candidate_poll/P = poll
		if(P.time_left() <= 0)
			polling_finished(P)

/datum/controller/subsystem/polling/proc/poll_candidates(question, role, jobban, poll_time = 30 SECONDS, ignore_category = null, flash_window = TRUE, list/group = null, pic_source, role_name_text)
	if(role && !role_name_text)
		role_name_text = role
	if(role_name_text && !question)
		question = "Do you want to play as [capitalize_each_word(role_name_text)]?"
	if(!question)
		question = "Do you want to play as a special role?"
	log_game("Polling candidates [role_name_text ? "for [role_name_text]" : "\"[question]\""] for [poll_time / 10] seconds")

	// Start firing
	polls_active = TRUE
	total_polls++

	var/jumpable = isatom(pic_source) ? pic_source : null

	var/datum/candidate_poll/P = new(role_name_text, question, poll_time, ignore_category, jumpable)
	LAZYADD(currently_polling, P)

	// We're the poll closest to completion
	if(!next_poll_to_finish || poll_time < next_poll_to_finish.time_left())
		next_poll_to_finish = P

	var/category = "[P.hash]_poll_alert"

	for(var/mob/candidate_mob as anything in group)
		// Universal opt-out for all players.
		if((!candidate_mob.client.prefs.read_preference(/datum/preference/toggle/ghost_roles)))
			continue
		// Opt-out for admins whom are currently adminned.
		if((!candidate_mob.client.prefs.read_preference(/datum/preference/toggle/ghost_roles_as_admin)) && candidate_mob.client.holder)
			continue
		if(!is_eligible(candidate_mob, role, jobban, ignore_category))
			continue

		SEND_SOUND(candidate_mob, 'sound/misc/notice2.ogg')
		if(flash_window)
			window_flash(candidate_mob.client)

		// If we somehow send two polls for the same mob type, but with a duration on the second one shorter than the time left on the first one,
		// we need to keep the first one's timeout rather than use the shorter one
		var/atom/movable/screen/alert/poll_alert/current_alert = LAZYACCESS(candidate_mob.alerts, category)
		var/alert_time = poll_time
		var/alert_poll = P
		if(current_alert && current_alert.timeout > (world.time + poll_time - world.tick_lag))
			alert_time = current_alert.timeout - world.time + world.tick_lag
			alert_poll = current_alert.poll

		// Send them an on-screen alert
		var/atom/movable/screen/alert/poll_alert/A = candidate_mob.throw_alert(category, /atom/movable/screen/alert/poll_alert, timeout_override = alert_time, no_anim = TRUE)
		if(!A)
			continue

		A.icon = ui_style2icon(candidate_mob.client?.prefs?.read_preference(/datum/preference/choiced/ui_style))
		A.desc = "[question]"
		A.show_time_left = TRUE
		A.poll = alert_poll
		A.poll.alert_button = A

		// Sign up inheritance and stacking
		var/inherited_sign_up = FALSE
		for(var/existing_poll in currently_polling)
			var/datum/candidate_poll/P2 = existing_poll
			if(P != P2 && P.hash == P2.hash)
				// If there's already a poll for an identical mob type ongoing and the client is signed up for it, sign them up for this one
				if(!inherited_sign_up && (candidate_mob in P2.signed_up) && P.sign_up(candidate_mob, TRUE))
					A.update_signed_up_alert()
					inherited_sign_up = TRUE

		// Image to display
		var/image/I
		if(pic_source)
			if(!ispath(pic_source))
				var/atom/PS = pic_source
				var/old_layer = PS.layer
				var/old_plane = PS.plane
				PS.plane = A.plane
				PS.layer = FLOAT_LAYER
				A.add_overlay(PS)
				PS.layer = old_layer
				PS.plane = old_plane
			else
				I = image(pic_source, layer = FLOAT_LAYER)
		else
			// Just use a generic image
			I = image('icons/effects/effects.dmi', icon_state = "static", layer = FLOAT_LAYER)

		if(I)
			I.plane = A.plane
			A.add_overlay(I)

		// Chat message
		var/act_jump = ""
		if(isatom(pic_source) && isobserver(candidate_mob))
			act_jump = "<a href='?src=[REF(A)];jump=1'>\[Teleport]</a>"
		var/act_signup = "<a href='?src=[REF(A)];signup=1'>\[Sign Up]</a>"
		var/act_never = ""
		if(ignore_category)
			act_never = "<a href='?src=[REF(A)];never=1'>\[Never For This Round]</a>"
		to_chat(candidate_mob, "<big>[span_boldnotice("Now looking for candidates [role_name_text ? "to play as \an [role_name_text]" : "\"[question]\""]. [act_jump] [act_signup] [act_never]")]</big>")

		// Start processing it so it updates visually the timer
		START_PROCESSING(SSprocessing, A)

	// Sleep until the time is up
	UNTIL(P.finished)
	return P.signed_up

/datum/controller/subsystem/polling/proc/poll_ghost_candidates(question, role, jobban, poll_time = 300, ignore_category = null, flashwindow = TRUE, pic_source, role_name_text)
	var/list/candidates = list()
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return candidates

	for(var/mob/dead/observer/ghost_player in GLOB.player_list)
		candidates += ghost_player

	return poll_candidates(question, role, jobban, poll_time, ignore_category, flashwindow, candidates, pic_source, role_name_text)

/datum/controller/subsystem/polling/proc/poll_ghost_candidates_for_mob(question, role, jobban, poll_time = 30 SECONDS, mob/target_mob, ignore_category = null, flashwindow = TRUE, pic_source, role_name_text)
	var/static/list/mob/currently_polling_mobs = list()

	if(currently_polling_mobs.Find(target_mob))
		return list()

	currently_polling_mobs += target_mob

	var/list/possible_candidates = poll_ghost_candidates(question, role, jobban, poll_time, ignore_category, flashwindow, pic_source, role_name_text)

	currently_polling_mobs -= target_mob
	if(!target_mob || QDELETED(target_mob) || !target_mob.loc)
		return list()

	return possible_candidates

/datum/controller/subsystem/polling/proc/poll_ghost_candidates_for_mobs(question, role, jobban, poll_time = 30 SECONDS, list/mobs, ignore_category = null, pic_source, role_name_text)
	var/list/candidate_list = poll_ghost_candidates(question, role, jobban, poll_time, ignore_category, pic_source, role_name_text)

	for(var/mob/potential_mob as anything in mobs)
		if(QDELETED(potential_mob) || !potential_mob.loc)
			mobs -= potential_mob

	if(!length(mobs))
		return list()

	return candidate_list

/datum/controller/subsystem/polling/proc/is_eligible(mob/M, role, jobban, the_ignore_category)
	if(!M.key || !M.client)
		return FALSE
	if(the_ignore_category)
		if(M.ckey in GLOB.poll_ignore[the_ignore_category])
			return FALSE
	if(role)
		if(!(role in M.client.prefs.be_special))
			return FALSE
		var/required_time = GLOB.special_roles[role] || 0
		if(M.client && M.client.get_remaining_days(required_time) > 0)
			return FALSE

	if(jobban)
		if(is_banned_from(M.ckey, list(jobban, ROLE_SYNDICATE)))
			return FALSE

	return TRUE

/datum/controller/subsystem/polling/proc/polling_finished(datum/candidate_poll/P)
	// Trim players who aren't eligible anymore
	var/len_pre_trim = length(P.signed_up)
	P.trim_candidates()
	log_game("Candidate poll [P.role ? "for [P.role]" : "\"[P.question]\""] finished. [len_pre_trim] players signed up, [length(P.signed_up)] after trimming")

	P.finished = TRUE
	currently_polling -= P

	// Determine which is the next poll closest the completion or "disable" firing if there's none
	if(!length(currently_polling))
		polls_active = FALSE
		next_poll_to_finish = null
	else if(P == next_poll_to_finish)
		next_poll_to_finish = null
		for(var/poll in currently_polling)
			var/datum/candidate_poll/P2 = poll
			if(!next_poll_to_finish || P2.time_left() < next_poll_to_finish.time_left())
				next_poll_to_finish = P2

/datum/controller/subsystem/polling/stat_entry(msg)
	msg += "Active: [length(currently_polling)] | Total: [total_polls]"
	if(next_poll_to_finish)
		msg += " | Next: [DisplayTimeText(next_poll_to_finish.time_left())] ([length(next_poll_to_finish.signed_up)] candidates)"
	return ..()

// The datum that describes one instance of candidate polling
/datum/candidate_poll
	var/role // The role the poll is for
	var/question // The question asked to observers
	var/duration // The duration of the poll
	var/atom/jump_to_me
	var/ignoring_category
	var/list/mob/signed_up // The players who signed up to this poll
	var/atom/movable/screen/alert/poll_alert/alert_button
	var/time_started // The world.time at which the poll was created
	var/finished = FALSE // Whether the polling is finished
	var/hash // Used to categorize in the alerts system

/datum/candidate_poll/New(polled_role, polled_question, poll_duration, poll_ignoring_category, poll_jumpable)
	role = polled_role
	question = polled_question
	duration = poll_duration
	ignoring_category = poll_ignoring_category
	jump_to_me = poll_jumpable
	signed_up = list()
	time_started = world.time
	hash = copytext(md5("[question]_[role ? role : "0"]"), 1, 7)
	return ..()

/datum/candidate_poll/proc/sign_up(mob/M, silent = FALSE)
	if(!istype(M) || !M.key || !M.client)
		return FALSE
	if(M in signed_up)
		if(!silent)
			to_chat(M, span_warning("You have already signed up for this!"))
		return FALSE
	if(time_left() <= 0)
		if(!silent)
			to_chat(M, span_danger("Sorry, you were too late for the consideration!"))
			SEND_SOUND(M, 'sound/machines/buzz-sigh.ogg')
		return FALSE

	signed_up += M
	if(!silent)
		to_chat(M, span_notice("You have signed up for [role]! A candidate will be picked randomly soon."))
		// Sign them up for any other polls with the same mob type
		for(var/existing_poll in SSpolling.currently_polling)
			var/datum/candidate_poll/P = existing_poll
			if(src != P && hash == P.hash && !(M in P.signed_up))
				P.sign_up(M, TRUE)
	if(alert_button)
		alert_button.update_candidates_number_overlay()
	return TRUE

/datum/candidate_poll/proc/remove_candidate(mob/M, silent = FALSE)
	if(!istype(M) || !M.key || !M.client)
		return FALSE
	if(!(M in signed_up))
		if(!silent)
			to_chat(M, span_warning("You aren't signed up for this!"))
		return FALSE

	if(time_left() <= 0)
		if(!silent)
			to_chat(M, span_danger("It's too late to unregister yourself, selection has already begun!"))
		return FALSE

	signed_up -= M
	if(!silent)
		to_chat(M, span_danger("You have been unregistered as a candidate for [role]. You can sign up again before the poll ends."))

		for(var/existing_poll in SSpolling.currently_polling)
			var/datum/candidate_poll/P = existing_poll
			if(src != P && hash == P.hash && (M in P.signed_up))
				P.remove_candidate(M, TRUE)
	if(alert_button)
		alert_button.update_candidates_number_overlay()
	return TRUE

/datum/candidate_poll/proc/never_for_this_round(mob/M, undoing = FALSE)
	if(!undoing)
		var/list/ignore_list = GLOB.poll_ignore[ignoring_category]
		if(!ignore_list)
			GLOB.poll_ignore[ignoring_category] = list()
		GLOB.poll_ignore[ignoring_category] += M.ckey
		to_chat(M, span_danger("Choice registered: Never for this round."))
		remove_candidate(M, silent = TRUE)
		return
	GLOB.poll_ignore[ignoring_category] -= M.ckey
	to_chat(M, span_notice("Choice registered: Eligible for this round"))

/datum/candidate_poll/proc/trim_candidates()
	list_clear_nulls(signed_up)
	for(var/mob in signed_up)
		var/mob/M = mob
		if(!M.key || !M.client)
			signed_up -= M

/datum/candidate_poll/proc/time_left()
	return duration - (world.time - time_started)
