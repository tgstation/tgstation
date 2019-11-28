SUBSYSTEM_DEF(achievements)
	name = "Achievements"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ACHIEVEMENTS
	var/hub_enabled = FALSE

	///List of achievements
	var/list/datum/award/achievement/achievements = list()
	///List of scores
	var/list/datum/award/score/scores = list()
	///List of all awards
	var/list/datum/award/awards = list()

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

	for(var/i in GLOB.clients)
		var/client/C = i
		if(!C.player_details.achievements.initialized)
			C.player_details.achievements.InitializeData()

	return ..()

/datum/controller/subsystem/achievements/Shutdown()
	save_achievements_to_hub()
	
/datum/controller/subsystem/achievements/proc/save_achievements_to_hub()
	for(var/i in GLOB.clients)
		var/client/C = i
		C.player_details.achievements.save()
