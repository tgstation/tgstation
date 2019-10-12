#define ACHIEVEMENT_DEFAULT "default"
#define ACHIEVEMENT_SCORE "score"

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

GLOBAL_LIST_INIT(achievement_cache, init_achievements())

/proc/init_achievements()
	. = list()
	for(var/T in subtypesof(/datum/achievement))
		.[T] = new T

/datum/achievement_data
	var/key
	var/data = list() //Current value
	var/store_value = list() //Store value compared on save to cut down on needless hub calls.

/datum/achievement_data/New(key)
	src.key = key

/datum/achievement_data/proc/save()
	for(var/T in data)
		var/datum/achievement/A = GLOB.achievement_cache[T]
		if(data[T] != store_value[T])
			A.save(key,data[T])

/datum/achievement_data/proc/load_all()
	for(var/T in subtypesof(/datum/achievement))
		get_data(T)

/datum/achievement_data/proc/get_data(achievement_type)
	var/datum/achievement/A = GLOB.achievement_cache[achievement_type]
	if(!data[achievement_type])
		data[achievement_type] = A.load(key)
		store_value[achievement_type] = data[achievement_type]

/datum/achievement_data/proc/show_catalog()
	return

/datum/achievement_data/proc/unlock(achievement_type)
	var/datum/achievement/A = GLOB.achievement_cache[achievement_type]
	get_data(achievement_type)
	switch(A.achievement_type)
		if(ACHIEVEMENT_DEFAULT)
			data[achievement_type] = TRUE
		if(ACHIEVEMENT_SCORE)
			data[achievement_type] += 1

/datum/achievement_data/proc/reset(achievement_type)
	var/datum/achievement/A = GLOB.achievement_cache[achievement_type]
	get_data(achievement_type)
	switch(A.achievement_type)
		if(ACHIEVEMENT_DEFAULT)
			data[achievement_type] = FALSE
		if(ACHIEVEMENT_SCORE)
			data[achievement_type] = 0

/mob/verb/test_values()
	client.player_details.achievements.get_data(/datum/achievement/meme)
	to_chat(world,"Testval : [client.player_details.achievements.data[/datum/achievement/meme]]")

/mob/verb/unlock_meme()
	client.player_details.achievements.unlock(/datum/achievement/meme)


/datum/achievement
	var/name = "It's fucking nothing"
	var/desc = "You did it."
	//var/icon = 'icons/misc/medals.dmi'
	var/icon_state = "cheese"

	var/achievement_type = ACHIEVEMENT_DEFAULT //Default - TRUE/FALSE only, Score - Any number
	//Implementation details
	var/hub_id

/datum/achievement/proc/load(key)
	//Fallback
	if(!SSmedals.hub_enabled)
		switch(achievement_type)
			if(ACHIEVEMENT_DEFAULT)
				return FALSE
			if(ACHIEVEMENT_SCORE)
				return 0
		CRASH("Invalid achievement_type")
	
	if(!hub_id)
		CRASH("Achievement without hub_id")
	
	switch(achievement_type)
		if(ACHIEVEMENT_DEFAULT)
			var/raw = world.GetMedal(hub_id, key, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))
			return isnull(raw) ? FALSE : raw
		if(ACHIEVEMENT_SCORE)
			var/list/raw = world.GetScores(key, hub_id, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))
			return isnull(raw) ? 0 : raw[hub_id]

/datum/achievement/proc/save(key,value)
	if(!SSmedals.hub_enabled)
		return
	
	if(!hub_id || !key)
		return

	switch(achievement_type)
		if(ACHIEVEMENT_DEFAULT)
			if(value)
				world.SetMedal(hub_id, key, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))
			else
				world.ClearMedal(hub_id, key, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))
		if(ACHIEVEMENT_SCORE)
			var/list/R = list()
			R[hub_id] = value
			world.SetScores(key,R,CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))

/datum/achievement/meme
	name = "Meme achivement"
	desc = "WOW"

	hub_id = "meme"

/datum/achievement/scoretest
	name = "Dumbass Score"
	desc = "WEW"

	achievement_type = ACHIEVEMENT_SCORE
	hub_id = "scoretest"