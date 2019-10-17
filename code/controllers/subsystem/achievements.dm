SUBSYSTEM_DEF(achievements)
	name = "Achievements"
	flags = SS_NO_FIRE
	var/hub_enabled = FALSE

	///List of achievements
	var/list/achievements
	///List of scores
	var/list/scores
	///List of all awards
	var/list/awards

/datum/controller/subsystem/achievements/Initialize(timeofday)
	if(CONFIG_GET(string/medal_hub_address) && CONFIG_GET(string/medal_hub_password))
		hub_enabled = TRUE
	
	for(var/T in subtypesof(/datum/award/achievement))
		var/instance = new T
		achievements[T] = instance
		awards[T] = instance

	for(var/T in subtypesof(/datum/award/score))
		var/instance = new T
		scores[T] = instance
		awards[T] = instance

	return ..()

/datum/controller/subsystem/achievements/Shutdown()
	save_achievements_to_hub()
	
/datum/controller/subsystem/achievements/proc/save_achievements_to_hub()
	for(var/i in GLOB.clients)
		var/client/C = i
		C.player_details.achievements.save()
