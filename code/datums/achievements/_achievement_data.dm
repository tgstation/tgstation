///Datum that handles
/datum/achievement_data
	var/key
	///Up to date list of all achievements and their info.
	var/data = list() 
	///Original status of achievement.
	var/original_cached_data = list()

/datum/achievement_data/New(key)
	src.key = key

///Saves any out-of-date achievements to the hub.
/datum/achievement_data/proc/save()
	for(var/T in data)
		var/datum/achievement/A = GLOB.achievement_cache[T]
		
		if(data[T] != original_cached_data[T])//If our data from before is not the same as now, save it to the hub. This check prevents unnecesary polling.
			A.save(key,data[T])

///Loads data for all achievements to the caches.
/datum/achievement_data/proc/load_all()
	for(var/T in subtypesof(/datum/achievement))
		get_data(T)

///Gets the data for a specific achievement and caches it
/datum/achievement_data/proc/get_data(achievement_type)
	var/datum/achievement/A = GLOB.achievement_cache[achievement_type]
	if(!data[achievement_type])
		data[achievement_type] = A.load(key)
		original_cached_data[achievement_type] = data[achievement_type]

///Unlocks an achievement of a specific type.
/datum/achievement_data/proc/unlock(achievement_type, mob/user)
	var/datum/achievement/A = GLOB.achievement_cache[achievement_type]
	get_data(achievement_type) //Get the current status first
	switch(A.achievement_type)
		if(ACHIEVEMENT_DEFAULT)
			data[achievement_type] = TRUE
			A.on_unlock(user) //Only on default achievement, as scores keep going up.
		if(ACHIEVEMENT_SCORE)
			data[achievement_type] += 1

///Getter for the status/score of an achievement
/datum/achievement_data/proc/get_achievement_status(achievement_type)
	return data[achievement_type]

///Resets an achievement to default values.
/datum/achievement_data/proc/reset(achievement_type)
	var/datum/achievement/A = GLOB.achievement_cache[achievement_type]
	get_data(achievement_type)
	switch(A.achievement_type)
		if(ACHIEVEMENT_DEFAULT)
			data[achievement_type] = FALSE
		if(ACHIEVEMENT_SCORE)
			data[achievement_type] = 0



