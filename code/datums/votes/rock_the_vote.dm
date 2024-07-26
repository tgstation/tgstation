#define CHOICE_TO_ROCK "Yes, re-do the map vote."
#define CHOICE_NOT_TO_ROCK "No, keep the currently selected map."

/// If a map vote is called before the emergency shuttle leaves the station, the players can call another vote to re-run the vote on the shuttle leaving.
/datum/vote/rock_the_vote
	name = "Rock the Vote"
	override_question = "Rock the Vote?"
	contains_vote_in_name = TRUE //lol
	default_choices = list(
		CHOICE_TO_ROCK,
		CHOICE_NOT_TO_ROCK,
	)
	default_message = "Override the current map vote."
	/// The number of times we have rocked the vote thus far.
	var/rocking_votes = 0

/datum/vote/rock_the_vote/toggle_votable()
	CONFIG_SET(flag/allow_rock_the_vote, !CONFIG_GET(flag/allow_rock_the_vote))

/datum/vote/rock_the_vote/is_config_enabled()
	return CONFIG_GET(flag/allow_rock_the_vote)

/datum/vote/rock_the_vote/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .

	if(SSticker.current_state == GAME_STATE_FINISHED)
		return "The game is finished, no map votes can be initiated."

	if(rocking_votes >= CONFIG_GET(number/max_rocking_votes))
		return "The maximum number of times to rock the vote has been reached."

	if(SSmapping.map_vote_rocked)
		return "The vote has already been rocked! Initiate a map vote!"

	if(!SSmapping.map_voted)
		return "Rocking the vote is disabled because no map has been voted on yet!"

	if(SSmapping.map_force_chosen)
		return "Rocking the vote is disabled because an admin has forcibly set the map!"

	if(EMERGENCY_ESCAPED_OR_ENDGAMED && SSmapping.map_voted)
		return "The emergency shuttle has already left the station and the next map has already been chosen!"

	return VOTE_AVAILABLE

/datum/vote/rock_the_vote/finalize_vote(winning_option)
	rocking_votes++
	if(winning_option == CHOICE_NOT_TO_ROCK)
		return

	if(winning_option == CHOICE_TO_ROCK)
		to_chat(world, span_boldannounce("The vote has been rocked! Players are now able to re-run the map vote once more."))
		message_admins("The players have successfully rocked the vote.")
		SSmapping.map_vote_rocked = TRUE
		return

	CRASH("[type] wasn't passed a valid winning choice. (Got: [winning_option || "null"])")

#undef CHOICE_TO_ROCK
#undef CHOICE_NOT_TO_ROCK
