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

	load_metadata(achievements_by_db_id)

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

///For now, this only loads the metadata of each achievement for the purpose of loading the times_achieved variable.
/datum/controller/subsystem/achievements/proc/load_metadata(list/achievements_by_db_id)
	if(!achievements_by_db_id)
		achievements_by_db_id = list()
		for(var/datum/award/achievement/instance as anything in achievements)
			achievements_by_db_id[instance.database_id] = instance
	///Looks at the metadata table and gets the number of times the achievement has been awarded.
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT achievement_key,times_achieved FROM [format_table_name("achievement_metadata")] WHERE achievement_type = '[TYPE_ACHIEVEMENT]'")

	if(!query.Execute())
		var/message = "Error retrieving achievement metadata for the achievements subsystem."
		log_sql(message)
		log_admin("[message] You can fix this by VVing the achievements and calling load_metadata() or count_achievements_achieved().")
		qdel(query)
		return
	///Try loading the value. If it's null, chances are all times_achieved columns are still empty and unpopulated.
	var/doing_it_the_slow_way = FALSE
	while(query.NextRow())
		var/id = query.item[1]
		var/datum/award/achievement/instance = id ? achievements_by_db_id[id] : null
		if(!instance)
			continue
		var/times = query.item[2]
		if(isnull(times))
			doing_it_the_slow_way = TRUE
			break
		instance.times_achieved = times
	qdel(query)

	if(doing_it_the_slow_way)
		count_achievements_achieved()


/**
 * This is going to add a dozen seconds and some to the subsystem initialization time.
 * So, it should only be called the first time the times achieved counter is added or
 * for debugging if shit hit the fan and the query from the above proc some-fucking-how failed.
 *
 * Get a column of achievements that've been unlocked from the db, count how many are of each type,
 * then store the results in the 'times_achieved' var of the corresponding achievements.
 */
/datum/controller/subsystem/achievements/proc/count_achievements_achieved(list/achievements_by_db_id)
	if(!achievements_by_db_id)
		achievements_by_db_id = list()
		for(var/datum/award/achievement/instance as anything in achievements)
			achievements_by_db_id[instance.database_id] = instance
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

	///Make sure the metadata is updated at the end of the round, so we don't have to call this again.
	for(var/achievement_type in achievements)
		var/datum/award/achievement/instance = achievements[achievement_type]
		instance.times_achieved_update = TRUE

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
		var/version = current_metadata[A.database_id]
		if(A.should_update_metadata(version))
			to_update += A.get_metadata_row()

	if(to_update.len)
		SSdbcore.MassInsert(format_table_name("achievement_metadata"),to_update,duplicate_key = TRUE)
