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
	/// the linked alert buttons
	var/list/atom/movable/screen/alert/poll_alert/alert_buttons = list()
	/// The world.time at which the poll was created
	var/time_started
	/// Whether the polling is finished
	var/finished = FALSE
	/// Used to categorize in the alerts system and identify polls of same question+role so we can stack the alert buttons
	var/poll_key
	///Response messages sent in specific key areas for full customization of polling.
	var/list/response_messages = list(
		POLL_RESPONSE_SIGNUP = "You have signed up for %ROLE%! A candidate will be picked randomly soon.",
		POLL_RESPONSE_ALREADY_SIGNED = "You have already signed up for this!",
		POLL_RESPONSE_NOT_SIGNED = "You aren't signed up for this!",
		POLL_RESPONSE_TOO_LATE_TO_UNREGISTER = "It's too late to unregister yourself, selection has already begun!",
		POLL_RESPONSE_UNREGISTERED = "You have been unregistered as a candidate for %ROLE%. You can sign up again before the poll ends.",
	)
	var/list/chosen_candidates = list()

/datum/candidate_poll/New(
	polled_role,
	polled_question,
	poll_duration,
	poll_ignoring_category,
	poll_jumpable,
	list/custom_response_messages = list(),
)
	role = polled_role
	question = polled_question
	duration = poll_duration
	ignoring_category = poll_ignoring_category
	jump_to_me = poll_jumpable
	signed_up = list()
	time_started = world.time
	poll_key = "[question]_[role ? role : "0"]"
	if(custom_response_messages.len)
		response_messages = custom_response_messages
	for(var/individual_message in response_messages)
		response_messages[individual_message] = replacetext(response_messages[individual_message], "%ROLE%", role)
	return ..()

/datum/candidate_poll/Destroy()
	if(src in SSpolling.currently_polling)
		SSpolling.polling_finished(src)
		return QDEL_HINT_IWILLGC // the above proc will call QDEL_IN(src, 0.5 SECONDS)
	jump_to_me = null
	signed_up = null
	return ..()

/datum/candidate_poll/proc/clear_alert_ref(atom/movable/screen/alert/poll_alert/source)
	SIGNAL_HANDLER
	alert_buttons -= source

/datum/candidate_poll/proc/sign_up(mob/candidate, silent = FALSE)
	if(!istype(candidate) || isnull(candidate.key) || isnull(candidate.client))
		return FALSE
	if(candidate in signed_up)
		if(!silent)
			to_chat(candidate, span_warning(response_messages[POLL_RESPONSE_ALREADY_SIGNED]))
		return FALSE
	if(time_left() <= 0)
		if(!silent)
			to_chat(candidate, span_danger("Sorry, you were too late for the consideration!"))
			SEND_SOUND(candidate, 'sound/machines/buzz/buzz-sigh.ogg')
		return FALSE

	signed_up += candidate

	log_ghost_poll("Player [candidate.key] signed candidate poll", data = list(
		"player key" = candidate.key,
		"role name" = role,
		"poll question" = question,
	))

	if(!silent)
		to_chat(candidate, span_notice(response_messages[POLL_RESPONSE_SIGNUP]))
		// Sign them up for any other polls with the same mob type
		for(var/datum/candidate_poll/existing_poll as anything in SSpolling.currently_polling)
			if(src != existing_poll && poll_key == existing_poll.poll_key && !(candidate in existing_poll.signed_up))
				existing_poll.sign_up(candidate, TRUE)
	for(var/atom/movable/screen/alert/poll_alert/linked_button as anything in alert_buttons)
		linked_button.update_candidates_number_overlay()
	return TRUE

/datum/candidate_poll/proc/remove_candidate(mob/candidate, silent = FALSE)
	if(!istype(candidate) || isnull(candidate.key) || isnull(candidate.client))
		return FALSE
	if(!(candidate in signed_up))
		if(!silent)
			to_chat(candidate, span_warning(response_messages[POLL_RESPONSE_NOT_SIGNED]))
		return FALSE

	if(time_left() <= 0)
		if(!silent)
			to_chat(candidate, span_danger(response_messages[POLL_RESPONSE_TOO_LATE_TO_UNREGISTER]))
		return FALSE

	signed_up -= candidate

	log_ghost_poll("Player [candidate.key] removed from poll candidacy", data = list(
		"player key" = candidate.key,
		"role name" = role,
		"poll question" = question,
	))

	if(!silent)
		to_chat(candidate, span_danger(response_messages[POLL_RESPONSE_UNREGISTERED]))

		for(var/datum/candidate_poll/existing_poll as anything in SSpolling.currently_polling)
			if(src != existing_poll && poll_key == existing_poll.poll_key && (candidate in existing_poll.signed_up))
				existing_poll.remove_candidate(candidate, TRUE)
	for(var/atom/movable/screen/alert/poll_alert/linked_button as anything in alert_buttons)
		linked_button.update_candidates_number_overlay()
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


/// Print to chat which candidate was selected
/datum/candidate_poll/proc/announce_chosen(list/poll_recipients)
	if(!length(chosen_candidates))
		return
	for(var/mob/chosen in chosen_candidates)
		var/client/chosen_client = chosen.client
		if(isnull(chosen_client))
			continue
		// The chosen one is still a ghost that's about to be deleted, so the link goes through a tracker that waits for the body they get
		var/datum/poll_winner_tracker/tracker = new(chosen_client)
		for(var/mob/poll_recipient as anything in poll_recipients)
			to_chat(poll_recipient, span_ooc("[isobserver(poll_recipient) ? "<a href=byond://?src=[REF(tracker)];follow=1>(F)</a>" : null][span_warning(" [full_capitalize(role)] Poll: ")][key_name(chosen_client, include_name = FALSE)] was selected."))

/// How long a tracker waits for the chosen candidate to be put into a body before giving up
#define POLL_WINNER_BODY_WAIT (30 SECONDS)

/**
 * Remembers the body a chosen candidate was put into as a result of a poll, so that observers can follow it from the announcement.
 * Only the first mob they log into after being chosen counts, any body they move to afterwards is not tracked.
 */
/datum/poll_winner_tracker
	/// The body the chosen candidate was put into, null until that happens
	var/datum/weakref/body_ref

/datum/poll_winner_tracker/New(client/winner)
	SSpolling.winner_trackers += src
	RegisterSignal(winner, COMSIG_CLIENT_MOB_LOGIN, PROC_REF(on_winner_login))
	addtimer(CALLBACK(src, PROC_REF(stop_waiting), WEAKREF(winner)), POLL_WINNER_BODY_WAIT)

/datum/poll_winner_tracker/proc/on_winner_login(client/source, mob/new_body)
	SIGNAL_HANDLER
	body_ref = WEAKREF(new_body)
	UnregisterSignal(source, COMSIG_CLIENT_MOB_LOGIN)

/// The candidate was never given a body, stop listening so that we don't latch onto something unrelated later
/datum/poll_winner_tracker/proc/stop_waiting(datum/weakref/winner_ref)
	var/client/winner = winner_ref.resolve()
	if(!isnull(winner))
		UnregisterSignal(winner, COMSIG_CLIENT_MOB_LOGIN)

/datum/poll_winner_tracker/Topic(href, href_list)
	. = ..()
	if(!href_list["follow"])
		return
	var/mob/dead/observer/ghost = usr
	if(!istype(ghost))
		return
	var/mob/body = body_ref?.resolve()
	if(isnull(body) || body == ghost)
		return
	ghost.ManualFollow(body)

#undef POLL_WINNER_BODY_WAIT
