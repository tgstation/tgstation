SUBSYSTEM_DEF(achievements)
	name = "Achievements"
	flags = SS_NO_FIRE
	var/hub_enabled = FALSE

	///List of non-score achievements
	var/list/normal_achievements

/datum/controller/subsystem/achievements/Initialize(timeofday)
	if(CONFIG_GET(string/medal_hub_address) && CONFIG_GET(string/medal_hub_password))
		hub_enabled = TRUE
	
	GLOB.achievement_cache = list()
	for(var/T in subtypesof(/datum/achievement))
		GLOB.achievement_cache[T] = new T

	for(var/T in GLOB.achievement_cache)
		var/datum/achievement/A = T
		if(A.achievement_type == ACHIEVEMENT_DEFAULT)
			normal_achievements += A

	return ..()

/datum/controller/subsystem/achievements/Shutdown()
	save_achievements_to_hub()
	
/datum/controller/subsystem/achievements/proc/save_achievements_to_hub()
	for(var/i in GLOB.clients)
		var/client/C = i
		C.player_details.achievements.save()

/mob/verb/test_values()
	client.player_details.achievements.get_data(/datum/achievement/meme)
	to_chat(world,"Testval : [client.player_details.achievements.data[/datum/achievement/meme]]")

/mob/verb/unlock_meme()
	client.player_details.achievements.unlock(/datum/achievement/meme)
