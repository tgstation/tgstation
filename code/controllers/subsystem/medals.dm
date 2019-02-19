SUBSYSTEM_DEF(medals)
	name = "Medals"
	flags = SS_NO_FIRE
	var/hub_enabled = FALSE

/datum/controller/subsystem/medals/Initialize(timeofday)
	if(CONFIG_GET(string/medal_hub_address) && CONFIG_GET(string/medal_hub_password))
		hub_enabled = TRUE
	return ..()

/datum/controller/subsystem/medals/proc/UnlockMedal(medal, client/player)
	set waitfor = FALSE
	if(!medal || !hub_enabled)
		return
	if(isnull(world.SetMedal(medal, player, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))))
		hub_enabled = FALSE
		log_game("MEDAL ERROR: Could not contact hub to award medal:[medal] player:[player.key]")
		message_admins("Error! Failed to contact hub to award [medal] medal to [player.key]!")
		return
	to_chat(player, "<span class='greenannounce'><B>Achievement unlocked: [medal]!</B></span>")


/datum/controller/subsystem/medals/proc/SetScore(score, client/player, increment, force)
	set waitfor = FALSE
	if(!score || !hub_enabled)
		return

	var/list/oldscore = GetScore(score, player, TRUE)
	if(increment)
		if(!oldscore[score])
			oldscore[score] = 1
		else
			oldscore[score] = (text2num(oldscore[score]) + 1)
	else
		oldscore[score] = force

	var/newscoreparam = list2params(oldscore)

	if(isnull(world.SetScores(player.ckey, newscoreparam, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))))
		hub_enabled = FALSE
		log_game("SCORE ERROR: Could not contact hub to set score. Score:[score] player:[player.key]")
		message_admins("Error! Failed to contact hub to set [score] score for [player.key]!")

/datum/controller/subsystem/medals/proc/GetScore(score, client/player, returnlist)
	if(!score || !hub_enabled)
		return

	var/scoreget = world.GetScores(player.ckey, score, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))
	if(isnull(scoreget))
		hub_enabled = FALSE
		log_game("SCORE ERROR: Could not contact hub to get score. Score:[score] player:[player.key]")
		message_admins("Error! Failed to contact hub to get score: [score] for [player.key]!")
		return
	. = params2list(scoreget)
	if(!returnlist)
		return .[score]

/datum/controller/subsystem/medals/proc/CheckMedal(medal, client/player)
	if(!medal || !hub_enabled)
		return

	if(isnull(world.GetMedal(medal, player, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))))
		hub_enabled = FALSE
		log_game("MEDAL ERROR: Could not contact hub to get medal:[medal] player: [player.key]")
		message_admins("Error! Failed to contact hub to get [medal] medal for [player.key]!")
		return
	to_chat(player, "[medal] is unlocked")

/datum/controller/subsystem/medals/proc/LockMedal(medal, client/player)
	if(!player || !medal || !hub_enabled)
		return
	var/result = world.ClearMedal(medal, player, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))
	switch(result)
		if(null)
			hub_enabled = FALSE
			log_game("MEDAL ERROR: Could not contact hub to clear medal:[medal] player:[player.key]")
			message_admins("Error! Failed to contact hub to clear [medal] medal for [player.key]!")
		if(TRUE)
			message_admins("Medal: [medal] removed for [player.key]")
		if(FALSE)
			message_admins("Medal: [medal] was not found for [player.key]. Unable to clear.")


/datum/controller/subsystem/medals/proc/ClearScore(client/player)
	if(isnull(world.SetScores(player.ckey, "", CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))))
		log_game("MEDAL ERROR: Could not contact hub to clear scores for [player.key]!")
		message_admins("Error! Failed to contact hub to clear scores for [player.key]!")
