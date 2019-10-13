/datum/achievement
	var/name = "It's fucking nothing"
	var/desc = "You did it."
	var/icon = 'icons/misc/achievements.dmi'
	var/icon_state = "default"

	///What type of achievement is this? Default (TRUE/FALSE) or score (Any number)
	var/achievement_type = ACHIEVEMENT_DEFAULT
	///What ID do we use on the hub?
	var/hub_id

///This proc loads the achievement data from the hub.
/datum/achievement/proc/load(key)
	set waitfor = FALSE //Polling is latent so we don't wait for this proc
	//Fallback
	if(!SSachievements.hub_enabled)
		switch(achievement_type)
			if(ACHIEVEMENT_DEFAULT)
				return FALSE
			if(ACHIEVEMENT_SCORE)
				return 0
		CRASH("Invalid achievement_type")
	
	if(!hub_id)
		CRASH("Achievement without valid hub_id")
	
	switch(achievement_type)
		if(ACHIEVEMENT_DEFAULT)
			var/raw = world.GetMedal(hub_id, key, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))
			return isnull(raw) ? FALSE : raw
		if(ACHIEVEMENT_SCORE)
			var/list/raw = world.GetScores(key, hub_id, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))
			return isnull(raw) ? 0 : raw[hub_id]


///This proc saves the achievement data to the hub.
/datum/achievement/proc/save(key,value)
	set waitfor = FALSE //Polling is latent so we don't wait for this proc
	if(!SSachievements.hub_enabled)
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
	CRASH("Invalid achievement_type")

/datum/achievement/proc/on_unlock(mob/user)
	to_chat(user, "<span class='greenannounce'><B>Achievement unlocked: [name]!</B></span>")
