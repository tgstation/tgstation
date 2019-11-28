SUBSYSTEM_DEF(achievements)
	name = "Achievements"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ACHIEVEMENTS
	var/achievements_enabled = FALSE

	///List of achievements
	var/list/datum/award/achievement/achievements = list()
	///List of scores
	var/list/datum/award/score/scores = list()
	///List of all awards
	var/list/datum/award/awards = list()

/datum/controller/subsystem/achievements/Initialize(timeofday)
	if(!SSdbcore.Connect())
		return
	achievements_enabled = TRUE

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
	save_achievements_to_db()
	
/datum/controller/subsystem/achievements/proc/save_achievements_to_db()
	var/list/cheevos_to_save = list()
	for(var/ckey in GLOB.player_details)
		var/datum/player_details/PD = GLOB.player_details[ckey]
		if(!PD || !PD.achievements)
			continue
		cheevos_to_save += PD.achievements.get_changed_data()
	
	SSdbcore.MassInsert(format_table_name("achievements"),cheevos_to_save,duplicate_key = TRUE)
