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
	message = "Override the current map vote."
	/// The number of times we have rocked the vote thus far.
	var/rocking_votes = 0

/datum/vote/rock_the_vote/toggle_votable(mob/toggler)
	if(!toggler)
		CRASH("[type] wasn't passed a \"toggler\" mob to toggle_votable.")
	if(!check_rights_for(toggler.client, R_ADMIN))
		return FALSE

	CONFIG_SET(flag/allow_rock_the_vote, !CONFIG_GET(flag/allow_rock_the_vote))
	return TRUE

/datum/vote/rock_the_vote/is_config_enabled()
	return CONFIG_GET(flag/allow_rock_the_vote)

/datum/vote/rock_the_vote/can_be_initiated(mob/by_who, forced)
	. = ..()

	if(!.)
		return FALSE

	if(!forced && !CONFIG_GET(flag/allow_rock_the_vote))
		message = "Rocking the vote is disabled by this server's configuration settings."
		return FALSE

	if(SSticker.current_state == GAME_STATE_FINISHED)
		message = "The game is finished, no map votes can be initiated."
		return FALSE

	if(rocking_votes >= CONFIG_GET(number/max_rocking_votes))
		message = "The maximum number of times to rock the vote has been reached."
		return FALSE

	if(SSmapping.map_vote_rocked)
		message = "The vote has already been rocked! Initiate a map vote!"
		return FALSE

	if(!SSmapping.map_voted)
		message = "Rocking the vote is disabled because no map has been voted on yet!"
		return FALSE

	if(SSmapping.map_force_chosen)
		message = "Rocking the vote is disabled because an admin has forcibly set the map!"
		return FALSE

	if(EMERGENCY_ESCAPED_OR_ENDGAMED && SSmapping.map_voted)
		message = "The emergency shuttle has already left the station and the next map has already been chosen!"
		return FALSE

	message = initial(message)
	return TRUE

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
