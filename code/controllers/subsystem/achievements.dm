SUBSYSTEM_DEF(achievements)
	name = "Achievements"
	wait = 5 MINUTES
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

/datum/controller/subsystem/achievements/fire(resumed)
	. = ..()
	save_achievements_to_hub()

/datum/controller/subsystem/achievements/Shutdown()
	save_achievements_to_hub()
	
/datum/controller/subsystem/achievements/proc/save_achievements_to_hub()
	for(var/i in GLOB.clients)
		var/client/C = i
		C.player_details.achievements.save()
