/datum/vote/storyteller
/datum/vote/storyteller/can_be_initiated(forced)
	choices = SSgamemode.storyteller_vote_choices()
	. = ..()
