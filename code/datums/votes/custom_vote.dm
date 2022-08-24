/// The max amount of options someone can have in a custom vote.
#define MAX_CUSTOM_VOTE_OPTIONS 10

/datum/vote/custom_vote
	name = "Custom"

// Custom votes ares always accessible.
/datum/vote/custom_vote/is_accessible_vote()
	return TRUE

/datum/vote/custom_vote/reset()
	default_choices = null
	override_question = null
	return ..()

/datum/vote/custom_vote/can_be_initiated(mob/by_who, forced = FALSE)
	. = ..()
	if(!.)
		return FALSE

	// Custom votes can only be created if they're forced to be made.
	// (Either an admin makes it, or otherwise.)
	return forced

/datum/vote/custom_vote/create_vote(mob/vote_creator)
	override_question = tgui_input_text(vote_creator, "What is the vote for?", "Custom Vote")
	if(!override_question)
		return FALSE

	default_choices = list()
	for(var/i in 1 to MAX_CUSTOM_VOTE_OPTIONS)
		var/option = tgui_input_text(vote_creator, "Please enter an option, or hit cancel to finish. [MAX_CUSTOM_VOTE_OPTIONS] max.", "Options", max_length = MAX_NAME_LEN)
		if(!vote_creator?.client)
			return FALSE
		if(!option)
			break

		default_choices += capitalize(option)

	if(!length(default_choices))
		return FALSE

	return ..()

/datum/vote/custom_vote/initiate_vote(initiator, duration)
	. = ..()
	. += "\n[override_question]"

// There are no winners or losers for custom votes
/datum/vote/custom_vote/get_winner_text(list/all_winners, real_winner, list/non_voters)
	return "[span_bold("Did not vote:")] [length(non_voters)]"

#undef MAX_CUSTOM_VOTE_OPTIONS
