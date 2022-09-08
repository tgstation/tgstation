#define CHOICE_RESTART "Restart Round"
#define CHOICE_CONTINUE "Continue Playing"

/datum/vote/restart_vote
	name = "Restart"
	default_choices = list(
		CHOICE_RESTART,
		CHOICE_CONTINUE,
	)
	message = "Vote to restart the ongoing round."

/// This proc checks to see if any admins are online for the purposes of this vote to see if it can pass. Returns TRUE if there are valid admins online (Has +SERVER and is not AFK), FALSE otherwise.
/datum/vote/restart_vote/proc/admins_present()
	for(var/client/online_admin as anything in GLOB.admins)
		if(online_admin.is_afk() || !check_rights_for(online_admin, R_SERVER))
			continue

		return TRUE

	return FALSE

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
		message = "Restart voting is disabled by server configuration settings."
		return FALSE

	// We still want players to be able to vote to restart even if valid admins are online. Let's update the message just so that the player is aware of this fact.
	// We don't want to lock-out the vote though, so we'll return TRUE.
	if(admins_present())
		message = "Regardless of the results of this vote, the round will not automatically restart because an admin is online."
		return TRUE

	message = initial(message)
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
		if(admins_present())
			to_chat(world, span_boldannounce("Notice: A restart vote will not restart the server automatically because there are active admins on."))
			message_admins("A restart vote has passed, but there are active admins on with +SERVER, so it has been canceled. If you wish, you may restart the server.")
			return

		SSticker.Reboot("Restart vote successful.", "restart vote", 1)
		return

	CRASH("[type] wasn't passed a valid winning choice. (Got: [winning_option || "null"])")

#undef CHOICE_RESTART
#undef CHOICE_CONTINUE
