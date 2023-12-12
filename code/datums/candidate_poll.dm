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

/datum/candidate_poll/proc/sign_up(mob/the_candidate, silent = FALSE)
	if(!istype(the_candidate) || !the_candidate.key || !the_candidate.client)
		return FALSE
	if(the_candidate in signed_up)
		if(!silent)
			to_chat(the_candidate, span_warning("You have already signed up for this!"))
		return FALSE
	if(time_left() <= 0)
		if(!silent)
			to_chat(the_candidate, span_danger("Sorry, you were too late for the consideration!"))
			SEND_SOUND(the_candidate, 'sound/machines/buzz-sigh.ogg')
		return FALSE

	signed_up += the_candidate
	if(!silent)
		to_chat(the_candidate, span_notice("You have signed up for [role]! A candidate will be picked randomly soon."))
		// Sign them up for any other polls with the same mob type
		for(var/existing_poll in SSpolling.currently_polling)
			var/datum/candidate_poll/the_existing_poll = existing_poll
			if(src != the_existing_poll && hash == the_existing_poll.hash && !(the_candidate in the_existing_poll.signed_up))
				the_existing_poll.sign_up(the_candidate, TRUE)
	if(alert_button)
		alert_button.update_candidates_number_overlay()
	return TRUE

/datum/candidate_poll/proc/remove_candidate(mob/the_candidate, silent = FALSE)
	if(!istype(the_candidate) || !the_candidate.key || !the_candidate.client)
		return FALSE
	if(!(the_candidate in signed_up))
		if(!silent)
			to_chat(the_candidate, span_warning("You aren't signed up for this!"))
		return FALSE

	if(time_left() <= 0)
		if(!silent)
			to_chat(the_candidate, span_danger("It's too late to unregister yourself, selection has already begun!"))
		return FALSE

	signed_up -= the_candidate
	if(!silent)
		to_chat(the_candidate, span_danger("You have been unregistered as a candidate for [role]. You can sign up again before the poll ends."))

		for(var/existing_poll in SSpolling.currently_polling)
			var/datum/candidate_poll/the_existing_poll = existing_poll
			if(src != the_existing_poll && hash == the_existing_poll.hash && (the_candidate in the_existing_poll.signed_up))
				the_existing_poll.remove_candidate(the_candidate, TRUE)
	if(alert_button)
		alert_button.update_candidates_number_overlay()
	return TRUE

/datum/candidate_poll/proc/never_for_this_round(mob/the_candidate, undoing = FALSE)
	if(!undoing)
		var/list/ignore_list = GLOB.poll_ignore[ignoring_category]
		if(!ignore_list)
			GLOB.poll_ignore[ignoring_category] = list()
		GLOB.poll_ignore[ignoring_category] += the_candidate.ckey
		to_chat(the_candidate, span_danger("Choice registered: Never for this round."))
		remove_candidate(the_candidate, silent = TRUE)
		return
	GLOB.poll_ignore[ignoring_category] -= the_candidate.ckey
	to_chat(the_candidate, span_notice("Choice registered: Eligible for this round"))

/datum/candidate_poll/proc/trim_candidates()
	list_clear_nulls(signed_up)
	for(var/mob/the_candidate as anything in signed_up)
		if(isnull(the_candidate.key) || isnull(the_candidate.client))
			signed_up -= the_candidate

/datum/candidate_poll/proc/time_left()
	return duration - (world.time - time_started)
