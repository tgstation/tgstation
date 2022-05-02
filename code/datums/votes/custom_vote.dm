#define MAX_CUSTOM_VOTE_OPTIONS 10

/datum/vote/custom_vote
	name = "custom vote"

/datum/vote/custom_vote/reset()
	default_choices = null
	override_question = null
	return ..()

/datum/vote/custom_vote/create_vote(mob/vote_creator)

	override_question = tgui_input_text(vote_creator, "What is the vote for?", "Custom Vote")
	if(!override_question)
		return FALSE

	for(var/i in 1 to MAX_CUSTOM_VOTE_OPTIONS)
		var/option = tgui_input_text(vote_creator, "Please enter an option, or hit cancel to finish. [MAX_CUSTOM_VOTE_OPTIONS] max.", "Options", max_length = MAX_NAME_LEN)
		if(!vote_creator?.client)
			return FALSE
		if(!option)
			break

		default_choices += capitalize(option)

	return !!length(default_choices)

/datum/vote/custom_vote/initiate_vote(initiator, duration)
	. = ..()
	. += "\n[override_question]"

/datum/vote/custom_vote/get_winner_text(list/all_winners, real_winner, list/non_voters)
	return "[span_bold("Did not vote:")] [length(non_voters)]"

#undef MAX_CUSTOM_VOTE_OPTIONS
