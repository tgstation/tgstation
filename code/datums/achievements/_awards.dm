/datum/award
	var/name = "It's fucking nothing"
	var/desc = "You did it."
	var/icon = 'icons/misc/achievements.dmi'
	var/icon_state = "default"
	var/category = "Normal"

	///What ID do we use on the hub?
	var/hub_id

///This proc loads the achievement data from the hub.
/datum/award/proc/load(key)
	return

///This saves the changed data to the hub.
/datum/award/proc/save(key, value)
	return

///Achievements are one-off awards for usually doing cool things.
/datum/award/achievement
	name = "achievement"

///Can be overriden for achievement specific events
/datum/award/proc/on_unlock(mob/user)
	return

/datum/award/achievement/save(key,value)
	set waitfor = FALSE //Polling is latent so we don't wait for this proc
	if(!SSachievements.hub_enabled)
		return
	
	if(!hub_id || !key)
		return
	if(value)
		world.SetMedal(hub_id, key, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))
	else
		world.ClearMedal(hub_id, key, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))

/datum/award/achievement/load(key)
	set waitfor = FALSE //Polling is latent so we don't wait for this proc
	. = ..()
	//Fallback
	if(!SSachievements.hub_enabled)
		return FALSE
	if(!hub_id)
		CRASH("Achievement without valid hub_id")
	
	var/raw = world.GetMedal(hub_id, key, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))
	return isnull(raw) ? FALSE : raw

/datum/award/achievement/on_unlock(mob/user)
	to_chat(user, "<span class='greenannounce'><B>Achievement unlocked: [name]!</B></span>")

///Scores are for leaderboarded things, such as killcount of a specific boss
/datum/award/score
	name = "score"

/datum/award/score/save(key,value)
	set waitfor = FALSE //Polling is latent so we don't wait for this proc
	if(!SSachievements.hub_enabled)
		return
	
	if(!hub_id || !key)
		return

	var/list/R = list()
	R[hub_id] = value
	world.SetScores(key,R,CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))

/datum/award/score/load(key)
	set waitfor = FALSE //Polling is latent so we don't wait for this proc
	. = ..()
	//Fallback
	if(!SSachievements.hub_enabled)
		return FALSE
	if(!hub_id)
		CRASH("Achievement without valid hub_id")
	
	var/list/raw = world.GetScores(key, hub_id, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))
	return isnull(raw) ? 0 : raw[hub_id]
