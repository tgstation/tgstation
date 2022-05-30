#define CHOICE_RESTART "Restart Round"
#define CHOICE_CONTINUE "Continue Playing"

/datum/vote/restart_vote
	name = "Restart"
	default_choices = list(
		CHOICE_RESTART,
		CHOICE_CONTINUE,
	)

/datum/vote/restart_vote/toggle_votable(mob/toggler)
	if(!toggler)
		CRASH("[type] wasn't passed a \"toggler\" mob to toggle_votable.")
	if(!check_rights_for(toggler.client, R_ADMIN))
		return FALSE

	CONFIG_SET(flag/allow_vote_restart, !CONFIG_GET(flag/allow_vote_restart))
	return TRUE

/datum/vote/restart_vote/is_config_enabled()
	return CONFIG_GET(flag/allow_vote_restart)

/datum/vote/restart_vote/can_be_initiated(mob/by_who, forced)
	. = ..()
	if(!.)
		return FALSE

	if(!forced && !CONFIG_GET(flag/allow_vote_restart))
		if(by_who)
			to_chat(by_who, span_warning("Restart voting is disabled."))
		return FALSE

	return TRUE

/datum/vote/restart_vote/get_vote_result(list/non_voters)
	if(!CONFIG_GET(flag/default_no_vote))
		// Default no votes will add non-voters to "Continue Playing"
		choices[CHOICE_CONTINUE] += length(non_voters)

	return ..()

/datum/vote/restart_vote/finalize_vote(winning_option)
	if(winning_option == CHOICE_CONTINUE)
		return

	if(winning_option == CHOICE_RESTART)
		for(var/client/online_admin as anything in GLOB.admins)
			if(online_admin.is_afk() || !check_rights_for(online_admin, R_SERVER))
				continue

			to_chat(world, span_boldannounce("Notice: A restart vote will not restart the server automatically because there are active admins on."))
			message_admins("A restart vote has passed, but there are active admins on with +SERVER, so it has been canceled. If you wish, you may restart the server.")
			return

		SSticker.Reboot("Restart vote successful.", "restart vote", 1)
		return

	CRASH("[type] wasn't passed a valid winning choice. (Got: [winning_option || "null"])")

#undef CHOICE_RESTART
#undef CHOICE_CONTINUE
