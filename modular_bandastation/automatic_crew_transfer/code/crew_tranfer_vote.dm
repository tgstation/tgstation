#define CHOICE_INITIATE_CREW_TRANSFER "Initiate Crew Transfer"
#define CHOICE_CONTINUE "Continue Playing"

/datum/vote/crew_transfer
	name = "Crew Transfer"
	default_choices = list(
		CHOICE_INITIATE_CREW_TRANSFER,
		CHOICE_CONTINUE,
	)
	default_message = "Голосование за вызов шаттла"

/datum/vote/crew_transfer/toggle_votable()
	CONFIG_SET(flag/allow_crew_transfer_vote, !CONFIG_GET(flag/allow_crew_transfer_vote))

/datum/vote/crew_transfer/is_config_enabled()
	return CONFIG_GET(flag/allow_crew_transfer_vote)

/datum/vote/crew_transfer/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .

	switch(SSticker.current_state)
		if(GAME_STATE_PLAYING)
			if(!EMERGENCY_IDLE_OR_RECALLED)
				return "Шаттл не может быть вызван."

			return VOTE_AVAILABLE
		if(GAME_STATE_FINISHED)
			return "Раунд уже закончен."
		else
			return "Раунд еще не начался."

/datum/vote/crew_transfer/finalize_vote(winning_option)
	switch(winning_option)
		if(CHOICE_CONTINUE)
			return
		if(CHOICE_INITIATE_CREW_TRANSFER)
			initiate_tranfer()
			return
		else
			CRASH("[type] wasn't passed a valid winning choice. (Got: [winning_option || "null"])")

/datum/vote/crew_transfer/proc/initiate_tranfer()
	PRIVATE_PROC(TRUE)

	if(!EMERGENCY_IDLE_OR_RECALLED)
		log_admin("Shuttle can't be called by automatic crew transfer vote because it's already in use or disabled.")
		message_admins(span_adminnotice("Shuttle can't be called by automatic crew transfer vote because it's already in use or disabled."))
		return

	SSshuttle.admin_emergency_no_recall = TRUE
	SSshuttle.emergency.mode = SHUTTLE_IDLE
	SSshuttle.emergency.request(reason = " Автоматическое окончание смены")

	log_admin("Shuttle called due to automatic crew transfer vote.")
	message_admins(span_adminnotice("Shuttle called due to automatic crew transfer vote."))

#undef CHOICE_INITIATE_CREW_TRANSFER
#undef CHOICE_CONTINUE
