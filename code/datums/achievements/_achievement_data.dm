///Datum that handles
/datum/achievement_data
	var/key
	///Up to date list of all achievements and their info.
	var/data = list() 
	///Original status of achievement.
	var/original_cached_data = list()
	///All icons for the UI of achievements
	var/list/AchievementIcons = null

/datum/achievement_data/New(key)
	src.key = key

	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/achievements)
	AchievementIcons = list()
	for (var/x in SSachievements.achievements)
		var/list/SL = list()
		SL["id"] = x.name
		SL["htmltag"] = assets.icon_tag(x.icon)
		AchievementIcons += list(SL)

///Saves any out-of-date achievements to the hub.
/datum/achievement_data/proc/save()
	for(var/T in data)
		var/datum/award/A = SSachievements.awards[T]
		
		if(data[T] != original_cached_data[T])//If our data from before is not the same as now, save it to the hub. This check prevents unnecesary polling.
			A.save(key,data[T])

///Loads data for all achievements to the caches.
/datum/achievement_data/proc/load_all()
	for(var/T in subtypesof(/datum/award))
		get_data(T)

/datum/achievement_data/proc/load_all_achievements()
	for(var/T in subtypesof(/datum/award/achievement))
		get_data(T)

///Gets the data for a specific achievement and caches it
/datum/achievement_data/proc/get_data(achievement_type)
	var/datum/award/A = SSachievements.awards[achievement_type]
	if(!data[achievement_type])
		data[achievement_type] = A.load(key)
		original_cached_data[achievement_type] = data[achievement_type]

///Unlocks an achievement of a specific type.
/datum/achievement_data/proc/unlock(achievement_type, mob/user)
	var/datum/award/A = SSachievements.awards[achievement_type]
	get_data(achievement_type) //Get the current status first
	if(istype(A, /datum/award/achievement))
		data[achievement_type] = TRUE
		A.on_unlock(user) //Only on default achievement, as scores keep going up.
	else if(istype(A, /datum/award/score))
		data[achievement_type] += 1

///Getter for the status/score of an achievement
/datum/achievement_data/proc/get_achievement_status(achievement_type)
	return data[achievement_type]

///Resets an achievement to default values.
/datum/achievement_data/proc/reset(achievement_type)
	var/datum/award/A = SSachievements.awards[achievement_type]
	get_data(achievement_type)
	if(istype(A, /datum/award/achievement))
		data[achievement_type] = FALSE
	else if(istype(A, /datum/award/score))
		data[achievement_type] = 0

/datum/achievement_data/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = default_state) // Remember to use the appropriate state.
  ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
  if(!ui)
	load_all_achievements() //Only necesary if we havn't used UI before
    ui = new(user, src, ui_key, "achievements", name, 300, 300, master_ui, state)
    ui.open()

/datum/achievement_data/ui_data(mob/user)
	data["categories"] = list("Bosses", "Misc")
	for(var/achievement_type in data)
		var/list/this = list()
		this["name"] = SSachievements.achievements[achievement_type].name
		this["desc"] = SSachievements.achievements[achievement_type].desc
		data["achievements"] += list(this)

	//Made at init, always stays the same
	data["achievementicons"] = AchievementIcons

	return data

/datum/achievement_data/ui_act(action, params)
  if(..())
    return

/client/verb/checkachievements()
	set category = "OOC"
	set name = "Check achievements"
	set desc = "See all of your achievements!"

	player_details.achievements.load_all()
	player_details.achievements.ui_interact(usr)



