SUBSYSTEM_DEF(ghost_spawns)
	name = "Ghost Spawns"
	init_order = INIT_ORDER_EVENTS
	flags = SS_BACKGROUND
	wait = 1 SECONDS
	runlevels = RUNLEVEL_GAME
	offline_implications = "Ghosts will no longer be able to respawn as event mobs (Blob, etc..). Shuttle call recommended."

	/// List of polls currently ongoing, to be checked on next fire()
	var/list/datum/candidate_poll/currently_polling
	/// Whether there are active polls or not
	var/polls_active = FALSE
	/// Number of polls performed since the start
	var/total_polls = 0
	/// The poll that's closest to finishing
	var/datum/candidate_poll/next_poll_to_finish

/datum/controller/subsystem/ghost_spawns/fire()
	if(!polls_active)
		return
	if(!currently_polling) // if polls_active is TRUE then this shouldn't happen, but still..
		currently_polling = list()

	for(var/poll in currently_polling)
		var/datum/candidate_poll/P = poll
		if(P.time_left() <= 0)
			polling_finished(P)

/**
  * Polls for candidates with a question and a preview of the role
  *
  * This proc replaces /proc/pollCandidates.
  * Should NEVER be used in a proc that has waitfor set to FALSE/0 (due to #define UNTIL)
  * Arguments:
  * * question - The question to ask to potential candidates
  * * role - The role to poll for. Should be a ROLE_x enum. If set, potential candidates who aren't eligible will be ignored
  * * antag_age_check - Whether to filter out potential candidates who don't have an old enough account
  * * poll_time - How long to poll for in deciseconds
  * * ignore_respawnability - Whether to ignore the player's respawnability
  * * min_hours - The amount of hours needed for a potential candidate to be eligible
  * * flash_window - Whether the poll should flash a potential candidate's game window
  * * check_antaghud - Whether to filter out potential candidates who enabled AntagHUD
  * * source - The atom, atom prototype, icon or mutable appearance to display as an icon in the alert
  */
/datum/controller/subsystem/ghost_spawns/proc/poll_candidates(question = "Would you like to play a special role?", role, antag_age_check = FALSE, poll_time = 30 SECONDS, ignore_respawnability = FALSE, min_hours = 0, flash_window = TRUE, check_antaghud = TRUE, source)
	log_debug("Polling candidates [role ? "for [get_roletext(role)]" : "\"[question]\""] for [poll_time / 10] seconds")

	// Start firing
	polls_active = TRUE
	total_polls++

	var/datum/candidate_poll/P = new(role, question, poll_time)
	LAZYADD(currently_polling, P)

	// We're the poll closest to completion
	if(!next_poll_to_finish || poll_time < next_poll_to_finish.time_left())
		next_poll_to_finish = P

	var/category = "[P.hash]_notify_action"

	for(var/mob/dead/observer/M in (ignore_respawnability ? GLOB.player_list : GLOB.respawnable_list))
		if(!is_eligible(M))
			continue

		SEND_SOUND(M, 'sound/misc/notice2.ogg')
		if(flash_window)
			window_flash(M.client)

		// If we somehow send two polls for the same mob type, but with a duration on the second one shorter than the time left on the first one,
		// we need to keep the first one's timeout rather than use the shorter one
		var/obj/screen/alert/notify_action/current_alert = LAZYACCESS(M.alerts, category)
		var/alert_time = poll_time
		var/alert_poll = P
		if(current_alert && current_alert.timeout > (world.time + poll_time - world.tick_lag))
			alert_time = current_alert.timeout - world.time + world.tick_lag
			alert_poll = current_alert.poll

		// Send them an on-screen alert
		var/obj/screen/alert/notify_action/A = M.throw_alert(category, /obj/screen/alert/notify_action, timeout_override = alert_time, no_anim = TRUE)
		if(!A)
			continue

		A.icon = ui_style2icon(M.client?.prefs.UI_style)
		A.name = "Looking for candidates"
		A.desc = "[question]\n\n(expires in [poll_time / 10] seconds)"
		A.show_time_left = TRUE
		A.poll = alert_poll

		// Sign up inheritance and stacking
		var/inherited_sign_up = FALSE
		var/num_stack = 1
		for(var/existing_poll in currently_polling)
			var/datum/candidate_poll/P2 = existing_poll
			if(P != P2 && P.hash == P2.hash)
				// If there's already a poll for an identical mob type ongoing and the client is signed up for it, sign them up for this one
				if(!inherited_sign_up && (M in P2.signed_up) && P.sign_up(M, TRUE))
					A.display_signed_up()
					inherited_sign_up = TRUE
				// This number is used to display the number of polls the alert regroups
				num_stack++
		if(num_stack > 1)
			A.display_stacks(num_stack)

		// Image to display
		var/image/I
		if(source)
			if(!ispath(source))
				var/atom/S = source
				var/old_layer = S.layer
				var/old_plane = S.plane

				S.layer = FLOAT_LAYER
				S.plane = FLOAT_PLANE
				A.overlays += S
				S.layer = old_layer
				S.plane = old_plane
			else
				I = image(source, layer = FLOAT_LAYER, dir = SOUTH)
		else
			// Just use a generic image
			I = image('icons/effects/effects.dmi', icon_state = "static", layer = FLOAT_LAYER, dir = SOUTH)

		if(I)
			I.layer = FLOAT_LAYER
			I.plane = FLOAT_PLANE
			A.overlays += I

		// Start processing it so it updates visually the timer
		START_PROCESSING(SSprocessing, A)
		A.process()

	// Sleep until the time is up
	UNTIL(P.finished)
	return P.signed_up

/**
  * Returns whether an observer is eligible to be an event mob
  *
  * Arguments:
  * * M - The mob to check eligibility
  * * role - The role to check eligibility for. Checks 1. the client has enabled the role 2. the account's age for this role if antag_age_check is TRUE
  * * antag_age_check - Whether to check the account's age or not for the given role.
  * * role_text - The role's clean text. Used for checking job bans to determine eligibility
  * * min_hours - The amount of minimum hours the client needs before being eligible
  * * check_antaghud - Whether to consider a client who enabled AntagHUD ineligible or not
  */
/datum/controller/subsystem/ghost_spawns/proc/is_eligible(mob/M, role, antag_age_check, role_text, min_hours, check_antaghud)
	. = FALSE
	if(!M.key || !M.client)
		return
	if(role)
		if(!(role in M.client.prefs.be_special))
			return
		if(antag_age_check)
			if(!player_old_enough_antag(M.client, role))
				return
	if(role_text)
		if(jobban_isbanned(M, role_text) || jobban_isbanned(M, "Syndicate"))
			return
	if(config.use_exp_restrictions && min_hours)
		if(M.client.get_exp_type_num(EXP_TYPE_LIVING) < min_hours * 60)
			return
	if(check_antaghud && cannotPossess(M))
		return

	return TRUE

/**
  * Called by the subsystem when a poll's timer runs out
  *
  * Can be called manually to finish a poll prematurely
  * Arguments:
  * * P - The poll to finish
  */
/datum/controller/subsystem/ghost_spawns/proc/polling_finished(datum/candidate_poll/P)
	// Trim players who aren't eligible anymore
	var/len_pre_trim = length(P.signed_up)
	P.trim_candidates()
	log_debug("Candidate poll [P.role ? "for [get_roletext(P.role)]" : "\"[P.question]\""] finished. [len_pre_trim] players signed up, [length(P.signed_up)] after trimming")

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

/datum/controller/subsystem/ghost_spawns/stat_entry(msg)
	msg += "Active: [length(currently_polling)] | Total: [total_polls]"
	if(next_poll_to_finish)
		msg += " | Next: [DisplayTimeText(next_poll_to_finish.time_left())] ([length(next_poll_to_finish.signed_up)] candidates)"
	..(msg)

// The datum that describes one instance of candidate polling
/datum/candidate_poll
	var/role // The role the poll is for
	var/question // The question asked to observers
	var/duration // The duration of the poll
	var/list/mob/dead/observer/signed_up // The players who signed up to this poll
	var/time_started // The world.time at which the poll was created
	var/finished = FALSE // Whether the polling is finished
	var/hash // Used to categorize in the alerts system

/datum/candidate_poll/New(polled_role, polled_question, poll_duration)
	role = polled_role
	question = polled_question
	duration = poll_duration
	signed_up = list()
	time_started = world.time
	hash = copytext(md5("[question]_[role ? role : "0"]"), 1, 7)
	return ..()

/**
  * Attempts to sign a (controlled) mob up
  *
  * Will fail if the mob is already signed up or the poll's timer ran out.
  * Does not check for eligibility
  * Arguments:
  * * M - The (controlled) mob to sign up
  * * silent - Whether no messages should appear or not. If not TRUE, signing up to this poll will also sign the mob up for identical polls
  */
/datum/candidate_poll/proc/sign_up(mob/dead/observer/M, silent = FALSE)
	. = FALSE
	if(!istype(M) || !M.key || !M.client)
		return
	if(M in signed_up)
		if(!silent)
			to_chat(M, "<span class='warning'>You have already signed up for this!</span>")
		return
	if(time_left() <= 0)
		if(!silent)
			to_chat(M, "<span class='danger'>Sorry, you were too late for the consideration!</span>")
			SEND_SOUND(M, 'sound/machines/buzz-sigh.ogg')
		return

	signed_up += M
	if(!silent)
		to_chat(M, "<span class='notice'>You have signed up for this role! A candidate will be picked randomly soon..</span>")
		// Sign them up for any other polls with the same mob type
		for(var/existing_poll in SSghost_spawns.currently_polling)
			var/datum/candidate_poll/P = existing_poll
			if(src != P && hash == P.hash && !(M in P.signed_up))
				P.sign_up(M, TRUE)

	return TRUE

/**
  * Deletes any candidates who may have disconnected from the list
  */
/datum/candidate_poll/proc/trim_candidates()
	listclearnulls(signed_up)
	for(var/mob in signed_up)
		var/mob/M = mob
		if(!M.key || !M.client)
			signed_up -= M

/**
  * Returns the time left for a poll
  */
/datum/candidate_poll/proc/time_left()
	return duration - (world.time - time_started)
