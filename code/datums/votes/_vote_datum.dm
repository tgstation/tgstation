
/**
 * # Vote Singleton
 *
 * A singleton datum that represents a type of vote for the voting subsystem.
 */
/datum/vote
	/// The name of the vote.
	var/name
	/// If supplied, an override question will be displayed instead of the name of the vote.
	var/override_question
	/// The sound effect played to everyone when this vote is initiated.
	var/vote_sound = 'sound/misc/bloop.ogg'
	/// A list of default choices we have for this vote.
	var/list/default_choices
	/// Does the name of this vote contain the word "vote"?
	var/contains_vote_in_name = FALSE
	/// What message do we want to pass to the player-side vote panel as a tooltip?
	var/message = "Click to initiate a vote."

	// Internal values used when tracking ongoing votes.
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
 * Resets our vote to its default state.
 */
/datum/vote/proc/reset()
	SHOULD_CALL_PARENT(TRUE)

	choices.Cut()
	choices_by_ckey.Cut()
	started_time = null
	time_remaining = null

/**
 * If this vote has a config associated, toggles it between enabled and disabled.
 * Returns TRUE on a successful toggle, FALSE otherwise
 */
/datum/vote/proc/toggle_votable(mob/toggler)
	return FALSE

/**
 * If this vote has a config associated, returns its value (True or False, usually).
 * If it has no config, returns -1.
 */
/datum/vote/proc/is_config_enabled()
	return -1

/**
 * Checks if the passed mob can initiate this vote.
 *
 * Return TRUE if the mob can begin the vote, allowing anyone to actually vote on it.
 * Return FALSE if the mob cannot initiate the vote.
 */
/datum/vote/proc/can_be_initiated(mob/by_who, forced = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	if(started_time)
		var/next_allowed_time = (started_time + CONFIG_GET(number/vote_delay))
		if(next_allowed_time > world.time && !forced)
			message = "A vote was initiated recently. You must wait [DisplayTimeText(next_allowed_time - world.time)] before a new vote can be started!"
			return FALSE

	message = initial(message)
	return TRUE

/**
 * Called prior to the vote being initiated.
 *
 * Return FALSE to prevent the vote from being initiated.
 */
/datum/vote/proc/create_vote(mob/vote_creator)
	SHOULD_CALL_PARENT(TRUE)

	for(var/key in default_choices)
		choices[key] = 0

	return TRUE

/**
 * Called when this vote is actually initiated.
 *
 * Return a string - the text displayed to the world when the vote is initiated.
 */
/datum/vote/proc/initiate_vote(initiator, duration)
	SHOULD_CALL_PARENT(TRUE)

	started_time = world.time
	time_remaining = round(duration / 10)

	return "[contains_vote_in_name ? "[capitalize(name)]" : "[capitalize(name)] vote"] started by [initiator || "Central Command"]."

/**
 * Gets the result of the vote.
 *
 * non_voters - a list of all ckeys who didn't vote in the vote.
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

/**
 * Gets the resulting text displayed when the vote is completed.
 *
 * all_winners - list of all options that won. Can be multiple, in the event of ties.
 * real_winner - the option that actually won.
 * non_voters - a list of all ckeys who didn't vote in the vote.
 *
 * Return a formatted string of text to be displayed to everyone.
 */
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

	returned_text += "\n"
	returned_text += get_winner_text(all_winners, real_winner, non_voters)

	return returned_text

/**
 * Gets the text that displays the winning options within the result text.
 *
 * all_winners - list of all options that won. Can be multiple, in the event of ties.
 * real_winner - the option that actually won.
 * non_voters - a list of all ckeys who didn't vote in the vote.
 *
 * Return a formatted string of text to be displayed to everyone.
 */
/datum/vote/proc/get_winner_text(list/all_winners, real_winner, list/non_voters)
	var/returned_text = ""
	if(length(all_winners) > 1)
		returned_text += "\n[span_bold("Vote Tied Between:")]"
		for(var/a_winner in all_winners)
			returned_text += "\n\t[a_winner]"

	returned_text += span_bold("\nVote Result: [real_winner]")
	return returned_text

/**
 * How this vote handles a tiebreaker between multiple winners.
 */
/datum/vote/proc/tiebreaker(list/winners)
	return pick(winners)

/**
 * Called when a vote is actually all said and done.
 * Apply actual vote effects here.
 */
/datum/vote/proc/finalize_vote(winning_option)
	return
