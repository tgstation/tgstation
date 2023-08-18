#define CHOICE_TRANSFER "Initiate Crew Transfer"
#define CHOICE_CONTINUE "Continue Playing"

/datum/vote/transfer_vote
	name = "Transfer"
	default_choices = list(
		CHOICE_TRANSFER,
		CHOICE_CONTINUE,
	)
	message = "Vote for crew transfer."

/datum/vote/transfer_vote/toggle_votable(mob/toggler)
	if(!toggler)
		CRASH("[type] wasn't passed a \"toggler\" mob to toggle_votable.")

	if(!check_rights_for(toggler.client, R_ADMIN))
		return FALSE

	CONFIG_SET(flag/allow_vote_transfer, !CONFIG_GET(flag/allow_vote_transfer))
	return TRUE

/datum/vote/transfer_vote/is_config_enabled()
	return CONFIG_GET(flag/allow_vote_transfer)

/datum/vote/transfer_vote/can_be_initiated(mob/by_who, forced)
	. = ..()
	if(!.)
		return FALSE

	if(!forced && !CONFIG_GET(flag/allow_vote_transfer))
		message = "Transfer voting is disabled by server configuration settings."
		return FALSE

	message = initial(message)
	return TRUE

/datum/vote/transfer_vote/get_vote_result(list/non_voters)
	if(!CONFIG_GET(flag/default_no_vote))
		// Default no votes will add non-voters to "Continue Playing"
		choices[CHOICE_CONTINUE] += length(non_voters)

	return ..()

/datum/vote/transfer_vote/finalize_vote(winning_option)
	if(winning_option == CHOICE_CONTINUE)
		return

	if(winning_option == CHOICE_TRANSFER)
		SSovermap.request_jump()
		return

	CRASH("[type] wasn't passed a valid winning choice. (Got: [winning_option || "null"])")

#undef CHOICE_TRANSFER
#undef CHOICE_CONTINUE
