/// The datum that describes one instance of candidate polling
/datum/candidate_poll
	/// The role the poll is for
	var/role
	/// The question asked to potential candidates
	var/question
	/// The duration of the poll
	var/duration
	/// the atom observers can jump/teleport to
	var/atom/jump_to_me
	/// Never For This Round category
	var/ignoring_category
	/// The players who signed up to this poll
	var/list/mob/signed_up
	/// the linked alert button
	var/atom/movable/screen/alert/poll_alert/alert_button
	/// The world.time at which the poll was created
	var/time_started
	/// Whether the polling is finished
	var/finished = FALSE
	/// Used to categorize in the alerts system and identify polls of same question+role so we can stack the alert buttons
	var/poll_key

/datum/candidate_poll/New(polled_role, polled_question, poll_duration, poll_ignoring_category, poll_jumpable)
	role = polled_role
	question = polled_question
	duration = poll_duration
	ignoring_category = poll_ignoring_category
	jump_to_me = poll_jumpable
	signed_up = list()
	time_started = world.time
	poll_key = "[question]_[role ? role : "0"]"
	return ..()

/datum/candidate_poll/Destroy()
	QDEL_NULL(alert_button)
	jump_to_me = null
	signed_up.Cut()
	return ..()

/datum/candidate_poll/proc/sign_up(mob/candidate, silent = FALSE)
	if(!istype(candidate) || isnull(candidate.key) || isnull(candidate.client))
		return FALSE
	if(candidate in signed_up)
		if(!silent)
			to_chat(candidate, span_warning("You have already signed up for this!"))
		return FALSE
	if(time_left() <= 0)
		if(!silent)
			to_chat(candidate, span_danger("Sorry, you were too late for the consideration!"))
			SEND_SOUND(candidate, 'sound/machines/buzz-sigh.ogg')
		return FALSE

	signed_up += candidate
	if(!silent)
		to_chat(candidate, span_notice("You have signed up for [role]! A candidate will be picked randomly soon."))
		// Sign them up for any other polls with the same mob type
		for(var/datum/candidate_poll/existing_poll as anything in SSpolling.currently_polling)
			if(src != existing_poll && poll_key == existing_poll.poll_key && !(candidate in existing_poll.signed_up))
				existing_poll.sign_up(candidate, TRUE)
	if(alert_button)
		alert_button.update_candidates_number_overlay()
		alert_button.update_signed_up_overlay()
	return TRUE

/datum/candidate_poll/proc/remove_candidate(mob/candidate, silent = FALSE)
	if(!istype(candidate) || isnull(candidate.key) || isnull(candidate.client))
		return FALSE
	if(!(candidate in signed_up))
		if(!silent)
			to_chat(candidate, span_warning("You aren't signed up for this!"))
		return FALSE

	if(time_left() <= 0)
		if(!silent)
			to_chat(candidate, span_danger("It's too late to unregister yourself, selection has already begun!"))
		return FALSE

	signed_up -= candidate
	if(!silent)
		to_chat(candidate, span_danger("You have been unregistered as a candidate for [role]. You can sign up again before the poll ends."))

		for(var/datum/candidate_poll/existing_poll as anything in SSpolling.currently_polling)
			if(src != existing_poll && poll_key == existing_poll.poll_key && (candidate in existing_poll.signed_up))
				existing_poll.remove_candidate(candidate, TRUE)
	if(alert_button)
		alert_button.update_candidates_number_overlay()
		alert_button.update_signed_up_overlay()
	return TRUE

/datum/candidate_poll/proc/do_never_for_this_round(mob/candidate)
	var/list/ignore_list = GLOB.poll_ignore[ignoring_category]
	if(!ignore_list)
		GLOB.poll_ignore[ignoring_category] = list()
	GLOB.poll_ignore[ignoring_category] += candidate.ckey
	to_chat(candidate, span_danger("Choice registered: Never for this round."))
	remove_candidate(candidate, silent = TRUE)

/datum/candidate_poll/proc/undo_never_for_this_round(mob/candidate)
	GLOB.poll_ignore[ignoring_category] -= candidate.ckey
	to_chat(candidate, span_notice("Choice registered: Eligible for this round"))

/datum/candidate_poll/proc/trim_candidates()
	list_clear_nulls(signed_up)
	for(var/mob/candidate as anything in signed_up)
		if(isnull(candidate.key) || isnull(candidate.client))
			signed_up -= candidate

/datum/candidate_poll/proc/time_left()
	return duration - (world.time - time_started)
