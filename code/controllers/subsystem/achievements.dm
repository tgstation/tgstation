SUBSYSTEM_DEF(achievements)
	name = "Achievements"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ACHIEVEMENTS
	var/achievements_enabled = FALSE

	///List of achievements
	var/list/datum/award/achievement/achievements = list()
	///The achievement with the highest amount of players that have unlocked it.
	var/datum/award/achievement/most_unlocked_achievement
	///List of scores
	var/list/datum/award/score/scores = list()
	///List of all awards
	var/list/datum/award/awards = list()

/datum/controller/subsystem/achievements/Initialize()
	if(!SSdbcore.Connect())
		return SS_INIT_NO_NEED
	achievements_enabled = TRUE

	var/list/achievements_by_db_id = list()
	for(var/achievement in subtypesof(/datum/award/achievement))
		var/datum/award/achievement/instance = new achievement
		achievements[achievement] = instance
		awards[achievement] = instance
		if(instance.database_id)
			achievements_by_db_id[instance.database_id] = instance

	/**
	 * Get a column of achievements that've been unlocked from the db and count how many are of each,
	 * then store the results in the 'times_achieved' var of the relative achievements.
	 * Lastly, set 'most_unlocked_achievement' to the achievement instance with highest 'times_achieved'.
	 */
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT achievement_key FROM [format_table_name("achievements")] WHERE value > 0"
	)
	if(query.Execute(async = TRUE))
		while(query.NextRow())
			var/id = query.item[1]
			var/datum/award/achievement/instance = id ? achievements_by_db_id[id] : null
			if(!instance)
				continue
			instance.times_achieved++
	qdel(query)

	for(var/achievement_type in achievements)
		var/datum/award/achievement/instance = achievements[achievement_type]
		if(most_unlocked_achievement?.times_achieved < instance.times_achieved)
			most_unlocked_achievement = instance

	for(var/T in subtypesof(/datum/award/score))
		var/instance = new T
		scores[T] = instance
		awards[T] = instance

	update_metadata()

	for(var/i in GLOB.clients)
		var/client/C = i
		if(!C.player_details.achievements.initialized)
			C.player_details.achievements.InitializeData()

	return SS_INIT_SUCCESS

/datum/controller/subsystem/achievements/Shutdown()
	save_achievements_to_db()

/datum/controller/subsystem/achievements/proc/save_achievements_to_db()
	var/list/cheevos_to_save = list()
	for(var/ckey in GLOB.player_details)
		var/datum/player_details/PD = GLOB.player_details[ckey]
		if(!PD || !PD.achievements)
			continue
		cheevos_to_save += PD.achievements.get_changed_data()
	if(!length(cheevos_to_save))
		return
	SSdbcore.MassInsert(format_table_name("achievements"),cheevos_to_save,duplicate_key = TRUE)

//Update the metadata if any are behind
/datum/controller/subsystem/achievements/proc/update_metadata()
	var/list/current_metadata = list()
	//select metadata here
	var/datum/db_query/Q = SSdbcore.NewQuery("SELECT achievement_key,achievement_version FROM [format_table_name("achievement_metadata")]")
	if(!Q.Execute(async = TRUE))
		qdel(Q)
		return
	else
		while(Q.NextRow())
			current_metadata[Q.item[1]] = text2num(Q.item[2])
		qdel(Q)

	var/list/to_update = list()
	for(var/T in awards)
		var/datum/award/A = awards[T]
		if(!A.database_id)
			continue
		if(!current_metadata[A.database_id] || current_metadata[A.database_id] < A.achievement_version)
			to_update += list(A.get_metadata_row())

	if(to_update.len)
		SSdbcore.MassInsert(format_table_name("achievement_metadata"),to_update,duplicate_key = TRUE)
