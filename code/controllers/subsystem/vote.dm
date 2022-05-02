SUBSYSTEM_DEF(vote)
	name = "Vote"
	wait = 1 SECONDS
	flags = SS_KEEP_TIMING|SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	/// A list of all generated action buttons
	var/list/datum/action/generated_actions = list()
	/// All votes that we can possible vote for.
	var/list/datum/vote/possible_votes = list()
	/// The vote we're currently voting on.
	var/datum/vote/current_vote
	/// String name of whoever initiated the vote.
	/// Usually a ckey, but can be anything (ex: "the server", "automated vote")
	var/initiator
	/// A list of all ckeys who have voted for the current vote.
	var/list/voted = list()
	/// A list of all ckeys currently voting for the current vote.
	var/list/voting = list()

/datum/controller/subsystem/vote/Initialize(start_timeofday)
	for(var/vote_type as anything in subtypesof(/datum/vote))
		var/datum/vote/vote = new vote_type()
		if(!vote.is_accessible_vote())
			qdel(vote)
			continue

		possible_votes[vote.name] = vote

	return ..()


// Called by master_controller
/datum/controller/subsystem/vote/fire()
	if(!mode)
		return
	current_vote.time_remaining = round((current_vote.started_time + CONFIG_GET(number/vote_period) - world.time) / 10)
	if(current_vote.time_remaining < 0)
		process_vote_result()
		SStgui.close_uis(src)
		reset()

/// Resets all of our vars after votes conclude / are cancelled.
/datum/controller/subsystem/vote/proc/reset()
	voted.Cut()
	voting.Cut()
	current_vote?.reset()
	current_vote = null
	initiator = null

	for(var/datum/action/vote/voting_action as anything in generated_actions)
		if(!QDELETED(voting_action))
			voting_action.remove_from_client()
			voting_action.Remove(voting_action.owner)

	generated_actions.Cut()

/**
 * Process the results of the vote.
 * Collects all the winners, breaks any ties that occur,
 * prints the results of the vote to the world,
 * and finally follows through with the effects of the vote.
 *
 */
/datum/controller/subsystem/vote/proc/process_vote_result()

	// First collect all the non-voters we have.
	var/list/non_voters = GLOB.directory.Copy() - voted
	// Remove AFK or clientless non-voters.
	for(var/non_voter_ckey in non_voters)
		var/client/non_voter_client = non_voters[non_voter_ckey]
		if(!non_voter_client || non_voter_client.is_afk())
			non_voters -= non_voter_ckey

	// Now get the result of the vote.
	// This is a list, as we could have a tie (multiple winners).
	var/list/winners = current_vote.get_vote_result(non_voters)

	// Now we should determine who actually won the vote.
	var/final_winner
	// 1 winner? That's the winning option
	if(length(winners) == 1)
		final_winner = winners[1]

	// More than 1 winner? Tiebreaker between all the winners
	else if(length(winners) > 1)
		final_winner = current_vote.tiebreaker(winners)

	// Announce the results of the vote to the world.
	var/to_display = current_vote.get_result_text(winners, final_winner, non_voters)

	log_vote(to_display)
	to_chat(world, span_infoplain(span_purple("\n[to_display]")))

	// Finally, finailze the vote, doing any effects on vote completion
	current_vote.finalize_vote(final_winner)

/datum/controller/subsystem/vote/proc/submit_vote(mob/voter, their_vote)
	if(!current_vote)
		return

	if(CONFIG_GET(flag/no_dead_vote) && voter.stat == DEAD && !voter.client?.holder)
		return
	if(!voter.ckey)
		return

	// If user has already voted, remove their specific vote
	if(voter.ckey in current_vote.choices_by_ckey)
		var/their_old_vote = current_vote.choices_by_ckey[voter.ckey]
		current_vote.choices[their_old_vote]--

	else
		voted += voter.ckey

	current_vote.choices_by_ckey[voter.ckey] = their_vote
	current_vote.choices[their_vote]++

/datum/controller/subsystem/vote/proc/initiate_vote(datum/vote/to_vote, vote_initiator_name, mob/vote_initiator, forced = FALSE)

	// Check if we have unlimited voting power.
	// Admins (or forced votes) will be forced through regardless if there's an ongoing vote,
	// if voting is on cooldown, or regardless if a vote is config disabled in some cases
	var/unlimited_vote_power = forced
	if(vote_initiator)
		unlimited_vote_power ||= !!GLOB.admin_datums[vote_initiator.ckey]

	if(current_vote && !unlimited_vote_power)
		if(vote_initiator)
			to_chat(vote_initiator, span_warning("There is already a vote in progress! Please wait for it to finish."))
		return FALSE

	if(!istype(to_vote))
		if(vote_initiator)
			to_chat(vote_initiator, span_warning("Invalid voting choice."))
		return FALSE

	if(!to_vote.can_be_initiated(vote_initiator, unlimited_vote_power))
		return FALSE

	// Ensures we're all set to begin
	reset()

	if(!to_vote.create_vote(vote_initiator))
		return FALSE

	current_vote = to_vote
	initiator = vote_initiator_name

	var/duration = CONFIG_GET(number/vote_period)
	var/to_display = current_vote.initiate_vote(initiator, duration)

	log_vote(to_display)
	to_chat(world, span_infoplain(span_purple("\n[span_bold(to_display)]\n\
		Type <b>vote</b> or click <a href='byond://winset?command=vote'>here</a> to place your votes.\n\
		You have [DisplayTimeText(duration)] to vote.")))

	for(var/client/new_voter as anything in GLOB.clients)
		var/datum/action/vote/voting_action = new()
		voting_action.name = "Vote: [current_vote.override_question || current_vote.name]"
		voting_action.Grant(new_voter.mob)

		new_voter.player_details.player_actions += voting_action
		generated_actions += voting_action

		if(new_voter.prefs.toggles & SOUND_ANNOUNCEMENTS)
			SEND_SOUND(new_voter, sound('sound/misc/bloop.ogg'))

	return TRUE

/datum/controller/subsystem/vote/ui_state()
	return GLOB.always_state

/datum/controller/subsystem/vote/ui_interact(mob/user, datum/tgui/ui)
	// Tracks who is voting
	voting |= user.client?.ckey
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Vote")
		ui.open()

/datum/controller/subsystem/vote/ui_data(mob/user)
	var/list/data = list()

	var/is_lower_admin = !!user.client?.holder
	var/is_upper_admin = check_rights_for(user.client, R_ADMIN)

	data["lower_admin"] = is_lower_admin
	data["upper_admin"] = is_upper_admin
	data["voting"] = is_lower_admin ? voting : list()

	if(current_vote)
		data["mode"] = current_vote.name
		data["question"] = current_vote.override_question
		data["time_remaining"] = current_vote.time_remaining
		data["selected_choice"] = current_vote.choices_by_ckey[user.client?.ckey]
		for(var/key in current_vote.choices)
			data["choices"] += list(list(
				"name" = key,
				"votes" = choices[key]
			))

	else
		var/list/all_vote_data = list()
		for(var/vote_name in possible_votes)
			var/datum/vote/vote = possible_votes[vote_name]
			all_vote_data += list(list(
				"name" = vote_name
				"can_be_initiated" = vote.can_be_initiated()
				"config" = vote.config_key
			))

		data["possible_votes"] = list(all_vote_data)

	return data

/datum/controller/subsystem/vote/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/mob/voter = usr

	switch(action)
		if("cancel")
			if(!voter.client?.holder)
				return

			voter.log_message("[key_name_admin(voter)] cancelled a vote.", LOG_ADMIN)
			message_admins("[key_name_admin(voter)] has cancelled the current vote.")
			reset()
			return TRUE

		if("toggle_vote")
			var/datum/vote/selected = possible_votes[params["vote_name"]]
			if(!istype(selected))
				return

			selected.toggle_votable(voter)
			return TRUE

		if("call_vote")
			var/datum/vote/selected = possible_votes[params["vote_name"]]
			if(!istype(selected))
				return

			return initiate_vote(selected, voter.key, voter)

		if("vote")
			return submit_vote(voter, params["vote_option"])

/datum/controller/subsystem/vote/ui_close(mob/user)
	voting -= user.client?.ckey

/// Mob level verb that allows players to vote on the current vote.
/mob/verb/vote()
	set category = "OOC"
	set name = "Vote"

	SSvote.ui_interact(usr)

/// Datum action given to mobs that allows players to vote on the current vote.
/datum/action/vote
	name = "Vote!"
	button_icon_state = "vote"

/datum/action/vote/IsAvailable()
	return TRUE // Democracy is always available to the free people

/datum/action/vote/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	owner.vote()
	Remove(owner)

// We also need to remove our action from the player actions when we're cleaning up.
/datum/action/vote/Remove(mob/removed_from)
	if(removed_from.client)
		removed_from.client?.player_details.player_actions -= src

	else if(removed_from.ckey)
		var/datum/player_details/associated_details = GLOB.player_details[removed_from.ckey]
		associated_details?.player_actions -= src

	return ..()
