/datum/vote/var/has_desc = FALSE

/datum/vote/proc/return_desc(vote_name)
	return ""

/datum/vote/storyteller
	name = "Storyteller"
	message = "Vote for the storyteller!"
	has_desc = TRUE


/datum/vote/storyteller/New()
	. = ..()
	default_choices = list()
	default_choices = SSgamemode.storyteller_vote_choices()


/datum/vote/storyteller/return_desc(vote_name)
	return SSgamemode.storyteller_desc(vote_name)

/datum/vote/storyteller/create_vote()
	. = ..()
	if((length(choices) == 1)) // Only one choice, no need to vote. Let's just auto-rotate it to the only remaining map because it would just happen anyways.
		var/de_facto_winner = choices[1]
		SSgamemode.storyteller_vote_result(de_facto_winner)
		to_chat(world, span_boldannounce("The storyteller vote has been skipped because there is only one storyteller left to vote for. The map has been changed to [de_facto_winner]."))
		return FALSE

/datum/vote/storyteller/finalize_vote(winning_option)
	SSgamemode.storyteller_vote_result(winning_option)
