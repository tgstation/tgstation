
#define GET_VOTE_CONFIG(key) CONFIG_GET(flag/##key)
#define SET_VOTE_CONFIG(key, value) CONFIG_SET(flag/##key, value)

/**
 * # Vote Singleton
 *
 * A singleton datum that represents a type of vote for the voting subsystem.
 */
/datum/vote
	// Default / overridable values
	/// The name of the vote.
	var/name
	/// If supplied, an override question will be displayed instead of the name of the vote.
	var/override_question
	/// A list of default choices we have for this vote.
	var/list/default_choices
	/// If this vote's availability is config based, this is it's config key.
	var/config_key

	// Internal values used when tracking ongoing votes
	// Don't mess with these, change the above values / override procs for subtypes.
	/// An assoc list of [all choices] to [number of votes in the current running vote].
	var/list/choices = list()
	/// A assoc list of [ckey] to [what they voted for in the current running vote].
	var/list/choices_by_ckey = list()
	/// The world time this vote was started.
	var/started_time
	/// The time remaining in this vote's run.
	var/time_remaining

/**
 * Used to determine if this vote is a possible
 * vote type for the vote subsystem.
 *
 * If FALSE is returned, this vote singleton
 * will not be created when the vote subsystem initializes,
 * meaning no one will be able to hold this vote.
 */
/datum/vote/proc/is_accessible_vote()
	return !!length(default_choices)

/**
 * Resets our vote to it's defualt state.
 */
/datum/vote/proc/reset()
	choices.Cut()
	choices_by_ckey.Cut()
	started_time = null
	time_remaining = null

/**
 * Checks if the passed mob can initiate this vote.
 *
 * Return TRUE if the mob can begin the vote,
 * allowing anyone to actually vote on it.
 * Return FALSE if the mob cannot initiate the vote,
 * such as if the vote is admin only.
 */
/datum/vote/proc/can_be_initiated(mob/by_who, forced = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	if(!MC_RUNNING(init_stage))
		if(by_who)
			to_chat(by_who, span_warning("You cannot start vote now, the server is not done initializing."))
		return FALSE

	if(started_time)
		var/next_allowed_time = (started_time + CONFIG_GET(number/vote_delay))
		if(next_allowed_time > world.time && !forced)
			if(by_who)
				to_chat(by_who, span_warning("A vote was initiated recently. You must wait [DisplayTimeText(next_allowed_time - world.time)] before a new vote can be started!"))
			return FALSE


	if(!forced && config_key && !GET_VOTE_CONFIG(config_key))
		return FALSE

	return TRUE

/datum/vote/proc/create_vote()
	return TRUE

/datum/vote/proc/initiate_vote(initiator, duration)
	started_time = world.time
	time_remaining = round(duration / 10)

	for(var/key in default_choices)
		choices[key] = 0

	return "[capitalize(name)] vote started by [initiator || "Central Command"]."

/datum/vote/proc/toggle_votable(mob/toggler)
	if(!config_key)
		return
	if(!check_rights_for(toggler?.client, R_ADMIN))
		return

	SET_VOTE_CONFIG(config_key, !GET_VOTE_CONFIG(config_key))

/**
 * Gets the result of the vote.
 *
 * Returns a list of all options that won.
 * If there were no votes at all, the list will be length = 0, non-null.
 * If only one option one, the list will be length = 1.
 * If there was a tie, the list will be length > 1.
 */
/datum/vote/proc/get_vote_result(list/non_voters)
	RETURN_TYPE(/list)

	var/list/winners = list()
	var/highest_vote = 0

	for(var/option in choices)

		var/vote_count = choices[option]
		// If we currently have no winners...
		if(!length(winners))
			// And the current option has any votes, it's the new highest.
			if(vote_count > 0)
				winners += option
				highest_vote = vote_count
			continue

		// If we're greater than, and NOT equal to, the highest vote,
		// we are the new supreme winner - clear all others
		if(vote_count > highest_vote)
			winners.Cut()
			winners += option
			highest_vote = vote_count

		// If we're equal to the highest vote, we tie for winner
		else if(vote_count == highest_vote)
			winners += option

	return winners

/datum/vote/proc/get_result_text(list/all_winners, real_winner, list/non_voters)
	if(length(all_winners) <= 0 || !real_winner)
		return span_bold("Vote Result: Inconclusive - No Votes!")

	var/returned_text = ""
	if(override_question)
		returned_text += span_bold(override_question)
	else
		returned_text += span_bold("[capitalize(name)] Vote")

	for(var/option in choices)
		returned_text += "\n[span_bold(option)]: [choices[option]]"

	returned_text += get_winner_text(all_winners, real_winner, non_voters)

	return returned_text

/datum/vote/proc/get_winner_text(list/all_winners, real_winner, list/non_voters)
	var/returned_text = ""
	if(length(all_winners) > 1)
		returned_text += "\n[span_bold("Vote Tied Between:")]"
		for(var/a_winner in all_winners)
			text += "\n\t[a_winner]"

	returned_text += span_bold("Vote Result: [real_winner]")
	return returned_text

/**
 * How this vote handles a tiebreaker between multiple winners.
 */
/datum/vote/proc/tiebreaker(list/winners)
	return pick(winners)

/datum/vote/proc/finalize_vote(winning_option)
	return

#undef GET_VOTE_CONFIG
#undef SET_VOTE_CONFIG
