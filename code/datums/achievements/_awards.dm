/datum/award
	///Name of the achievement, If null it won't show up in the achievement browser. (Handy for inheritance trees)
	var/name
	var/desc = "You did it."
	///The icon state for this award. The icon file is found in ui_icons/achievements.
	var/icon = "default"

	var/category = "Normal"

	///What ID do we use in db, limited to 32 characters
	var/database_id
	//Bump this up if you're changing outdated table identifier and/or achievement type
	var/achievement_version = 2

	//Value returned on db connection failure, in case we want to differ 0 and nonexistent later on
	var/default_value = FALSE

	///Whether the award has to be loaded before or after other awards on [/datum/achievement_data/load_all_achievements()]
	var/load_priority = AWARD_PRIORITY_DEFAULT

///This proc loads the achievement data from the hub.
/datum/award/proc/load(key)
	if(!SSdbcore.Connect())
		return default_value
	if(!key || !database_id || !name)
		return default_value
	var/raw_value = get_raw_value(key)
	return parse_value(raw_value)

///This saves the changed data to the hub.
/datum/award/proc/get_changed_rows(key, value)
	if(!database_id || !key || !name)
		return
	return list(
		"ckey" = key,
		"achievement_key" = database_id,
		"value" = value,
	)

/datum/award/proc/get_metadata_row()
	return list(
		"achievement_key" = database_id,
		"achievement_version" = achievement_version,
		"achievement_type" = "award",
		"achievement_name" = name,
		"achievement_description" = desc,
	)

///Get raw numerical achievement value from the database
/datum/award/proc/get_raw_value(key)
	var/datum/db_query/Q = SSdbcore.NewQuery(
		"SELECT value FROM [format_table_name("achievements")] WHERE ckey = :ckey AND achievement_key = :achievement_key",
		list("ckey" = key, "achievement_key" = database_id)
	)
	if(!Q.Execute(async = TRUE))
		qdel(Q)
		return 0
	var/result = 0
	if(Q.NextRow())
		result = text2num(Q.item[1])
	qdel(Q)
	return result

//Should return sanitized value for achievement cache
/datum/award/proc/parse_value(raw_value, list/data)
	return default_value

///Can be overriden for achievement specific events
/datum/award/proc/on_unlock(mob/user)
	return

///Achievements are one-off awards for usually doing cool things.
/datum/award/achievement
	desc = "Achievement for epic people"
	icon = "" // This should warn contributors that do not declare an icon when contributing new achievements.

/datum/award/achievement/get_metadata_row()
	. = ..()
	.["achievement_type"] = "achievement"

/datum/award/achievement/parse_value(raw_value, list/data)
	return raw_value > 0

/datum/award/achievement/on_unlock(mob/user)
	. = ..()
	to_chat(user, span_greenannounce("<B>Achievement unlocked: [name]!</B>"))
	user.client.give_award(/datum/award/score/achievements_score, user, 1)

///Scores are for leaderboarded things, such as killcount of a specific boss
/datum/award/score
	desc = "you did it sooo many times."
	category = "Scores"
	default_value = 0

	var/track_high_scores = TRUE
	var/list/high_scores = list()

/datum/award/score/New()
	. = ..()
	if(track_high_scores)
		LoadHighScores()

/datum/award/score/get_metadata_row()
	. = ..()
	.["achievement_type"] = "score"

/datum/award/score/proc/LoadHighScores()
	var/datum/db_query/Q = SSdbcore.NewQuery(
		"SELECT ckey,value FROM [format_table_name("achievements")] WHERE achievement_key = :achievement_key ORDER BY value DESC LIMIT 50",
		list("achievement_key" = database_id)
	)
	if(!Q.Execute(async = TRUE))
		qdel(Q)
		return
	else
		while(Q.NextRow())
			var/key = Q.item[1]
			var/score = text2num(Q.item[2])
			high_scores[key] = score
		qdel(Q)

/datum/award/score/parse_value(raw_value, list/data)
	return isnum(raw_value) ? raw_value : 0

///Defining this here 'cause it's the first score a player should see in the Scores category.
/datum/award/score/achievements_score
	name = "Achievements Unlocked"
	desc = "Don't worry, metagaming is all that matters."
	icon = "elephant" //Obey the reference
	database_id = ACHIEVEMENTS_SCORE
	load_priority = AWARD_PRIORITY_LAST //See below

/**
 * If the raw value is not numerical, it's likely this is the first time the score is being loaded for a ckey.
 * So, let's start counting how many achievements have been unlocked so far and return its value instead,
 * which is why this award should always be loaded last.
 */
/datum/award/score/achievements_score/parse_value(raw_value, list/data)
	if(isnum(raw_value))
		return raw_value
	. = 0
	for(var/award_type in data)
		if(ispath(award_type, /datum/award/achievement) && data[award_type])
			.++
	return .
