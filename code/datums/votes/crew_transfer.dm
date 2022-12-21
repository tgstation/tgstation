#define CHOICE_TO_STAY "No, keep playing this round."
#define CHOICE_TO_CALL "Yes, call shuttle to initiate a crew transfer."

/// If the shuttle hasn't been called yet, and is callable, players can vote to initiate a crew transfer.
/datum/vote/transfer
	name = "Crew Transfer"
	default_choices = list(
		CHOICE_TO_STAY,
		CHOICE_TO_CALL
	)
	message = "Call the shuttle for a crew transfer."


/datum/vote/transfer/can_be_initiated(mob/by_who, forced)
	if(!..())
		return FALSE

	var/shuttle_refuel_delay = CONFIG_GET(number/shuttle_refuel_delay)
	if(world.time - SSticker.round_start_time < shuttle_refuel_delay)
		message = "It's too early to call the shuttle!"  // nice try kilo haters
		return FALSE

	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		message = "The round has already ended!"
		return FALSE

	if(EMERGENCY_AT_LEAST_DOCKED)
		message = "The shuttle has already arrived!"
		return FALSE

	if(EMERGENCY_PAST_POINT_OF_NO_RETURN)
		message = "The shuttle is guarenteed to arrive soon."
		return FALSE

	// Catch-all for if the above fail
	if(SSshuttle.emergency?.mode != SHUTTLE_IDLE)
		message = "The shuttle is not ready to be called yet, try again later."
		return FALSE

	message = initial(message)
	return TRUE

/datum/vote/transfer/finalize_vote(winning_option)
	if(winning_option != CHOICE_TO_CALL)
		return

	SSshuttle.admin_emergency_no_recall = TRUE  // this is how democracy works
	SSshuttle.emergency.request(reason = "Crew Transfer Requested.")

	message_admins("The players have voted to call the shuttle.")
	SSblackbox.record_feedback("tally", "vote_crew_transfer", 1, "Call Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#undef CHOICE_TO_STAY
#undef CHOICE_TO_CALL
