#define CHOICE_RESTART "Restart Round"
#define CHOICE_CONTINUE "Continue Playing"

/datum/vote/restart_vote
	default_choices = list(
		CHOICE_RESTART,
		CHOICE_CONTINUE,
	)
	config_key = "allow_vote_restart"

/datum/vote/restart_vote/get_result(list/non_voters)
	if(!CONFIG_GET(flag/default_no_vote))
		choices[CHOICE_CONTINUE] += length(non_voters)

	return ..()

/datum/vote/restart_vote/finalize_vote(winning_option)
	if(winning_option == CHOICE_CONTINUE)
		return

	if(winning_option == CHOICE_RESTART)
		for(var/client/online_admin as anything in GLOB.admins | GLOB.deadmins)
			if(online_admin.is_afk() || !check_rights_for(online_admin, R_SERVER))
				continue

			to_chat(world, span_boldannounce("Notice: A restart vote will not restart the server automatically because there are active admins on."))
			message_admins("A restart vote has passed, but there are active admins on with +SERVER, so it has been canceled. If you wish, you may restart the server.")
			return

		SSticker.Reboot("Restart vote successful.", "restart vote", 1)
		return

	CRASH("[type] wasn't passed a valid winning choice. (Got: [winning_option])")

#undef CHOICE_RESTART
#undef CHOICE_CONTINUE
