/datum/vote
	var/name = ""
	var/initatable_by_players = FALSE
	var/list/choices

/datum/vote/New()
	set_initiatable()

/datum/vote/proc/set_initiatable()
	initatable_by_players = TRUE

/datum/vote/proc/can_be_initiated()
	return TRUE

/datum/vote/proc/initiate_vote()

/datum/vote/proc/get_result()

/datum/vote/proc/announce_result()

/datum/vote/proc/on_success()
