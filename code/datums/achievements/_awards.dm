/datum/award
	///Name of the achievement, If null it won't show up in the achievement browser. (Handy for inheritance trees)
	var/name
	var/desc = "You did it."
	///The dmi icon file that holds the award's icon state.
	var/icon = ACHIEVEMENTS_SET
	///The icon state for this award.
	var/icon_state = "default"

	var/category = "Normal"

	///What ID do we use in db, limited to 32 characters
	var/database_id
	//Bump this up if you're changing outdated table identifier and/or achievement type
	var/achievement_version = 2

///This proc loads the achievement data from the hub.
/datum/award/proc/load(datum/achievement_data/holder)
	if(!SSdbcore.Connect())
		return default_value()
	if(!holder.owner_ckey || !database_id || !name)
		return default_value()
	var/value = parse_value(get_raw_value(holder.owner_ckey))
	holder.original_cached_data[type] = holder.data[type] = value
	return value

//Proc that returns a value upon db connection failure, in case we need different instances too.
/datum/award/proc/default_value()
	return FALSE

/datum/award/proc/unlock(mob/user, datum/achievement_data/holder, value = 1)
	return

/datum/award/proc/on_achievement_data_init(datum/achievement_data/holder, database_value)
	holder.original_cached_data[type] = holder.data[type] = parse_value(database_value)

///This saves the changed data to the hub.
/datum/award/proc/get_changed_rows(datum/achievement_data/holder)
	if(!database_id || !holder.owner_ckey || !name)
		return
	return list(
		"ckey" = holder.owner_ckey,
		"achievement_key" = database_id,
		"value" = holder.data[type],
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
/datum/award/proc/parse_value(raw_value)
	return default_value()

///Can be overridden for achievement specific events
/datum/award/proc/on_unlock(mob/user)
	return

///returns additional ui data for the Check Achievements menu
/datum/award/proc/get_ui_data(list/award_data, datum/achievement_data/holder)
	return list(
		"score" = FALSE,
		"achieve_info" = null,
		"achieve_tooltip" = null,
	)

///Achievements are one-off awards for usually doing cool things.
/datum/award/achievement
	desc = "Achievement for epic people"
	icon_state = "" // This should warn contributors that do not declare an icon when contributing new achievements.
	///How many players have earned this achievement
	var/times_achieved = 0

/datum/award/achievement/unlock(mob/user, datum/achievement_data/holder, value = 1)
	if(holder.data[type]) //You already unlocked it so don't bother running the unlock proc
		return
	holder.data[type] = TRUE
	on_unlock(user)

/datum/award/achievement/get_metadata_row()
	. = ..()
	.["achievement_type"] = "achievement"

/datum/award/achievement/get_ui_data(list/award_data, datum/achievement_data/holder)
	. = ..()
	.["achieve_info"] = "Unlocked by [times_achieved] players so far"
	if(!SSachievements.most_unlocked_achievement)
		.["achieve_tooltip"] = "No achievement has been unlocked yet. Be the first today!"
		return
	if(SSachievements.most_unlocked_achievement == src)
		.["achieve_tooltip"] = "This is the most unlocked achievement"
		return
	var/percent = FLOOR(times_achieved / SSachievements.most_unlocked_achievement.times_achieved * 100, 0.01)
	.["achieve_tooltip"] = "[(times_achieved && !percent) ? "Less than 0.01" : percent]% compared to the achievement unlocked by the most players: \"[SSachievements.most_unlocked_achievement.name])\""

/datum/award/achievement/parse_value(raw_value)
	return raw_value > 0

/datum/award/achievement/on_unlock(mob/user)
	. = ..()
	to_chat(user, span_greenannounce("<B>Achievement unlocked: [name]!</B>"))
	var/sound/sound_to_send = LAZYACCESS(GLOB.achievement_sounds, user.client.prefs.read_preference(/datum/preference/choiced/sound_achievement))
	if(sound_to_send)
		SEND_SOUND(user, sound_to_send)

	times_achieved++
	if(SSachievements.most_unlocked_achievement?.times_achieved < times_achieved)
		SSachievements.most_unlocked_achievement = src

	var/datum/achievement_report/new_report = new /datum/achievement_report()

	new_report.winner = "[(user.real_name == user.name) ? user.real_name : "[user.real_name], as [user.name]"]"
	new_report.cheevo = name
	if(user.ckey)
		new_report.winner_key = user.ckey
	else
		stack_trace("[name] achievement earned by [user], who did not have a ckey.")

	new_report.award_location = "[get_area_name(user)]"

	GLOB.achievements_unlocked += new_report

///Scores are for leaderboarded things, such as killcount of a specific boss
/datum/award/score
	desc = "you did it sooo many times."
	category = "Scores"

	var/track_high_scores = TRUE
	var/list/high_scores = list()

/datum/award/score/New()
	. = ..()
	if(track_high_scores)
		LoadHighScores()

/datum/award/score/default_value()
	return 0

/datum/award/score/get_metadata_row()
	. = ..()
	.["achievement_type"] = "score"

/datum/award/score/unlock(mob/user, datum/achievement_data/holder, value = 1)
	holder.data[type] += value

/datum/award/score/get_ui_data(list/award_data, datum/achievement_data/holder)
	. = ..()
	.["score"] = TRUE

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
			high_scores += list(list("ckey" = key, "value" = score))
		qdel(Q)

/datum/award/score/parse_value(raw_value)
	return isnum(raw_value) ? raw_value : 0

///Defining this here 'cause it's the first score a player should see in the Scores category.
/datum/award/score/achievements_score
	name = "Achievements Unlocked"
	desc = "Don't worry, metagaming is all that matters."
	icon_state = "elephant" //Obey the reference
	database_id = ACHIEVEMENTS_SCORE

/datum/award/score/achievements_score/get_ui_data(list/award_data, datum/achievement_data/holder)
	. = ..()
	var/datum/db_query/get_unlocked_count = SSdbcore.NewQuery(
		"SELECT COUNT(m.achievement_key) FROM [format_table_name("achievements")] AS a JOIN [format_table_name("achievement_metadata")] m ON a.achievement_key = m.achievement_key AND m.achievement_type = 'Achievement' WHERE a.ckey = :ckey",
		list("ckey" = holder.owner_ckey)
	)
	if(!get_unlocked_count.Execute(async = TRUE))
		qdel(get_unlocked_count)
		.["value"] = 0
		return .
	if(get_unlocked_count.NextRow())
		.["value"] = text2num(get_unlocked_count.item[1])
	qdel(get_unlocked_count)
	return .

/datum/award/score/achievements_score/LoadHighScores()
	var/datum/db_query/get_unlocked_highscore = SSdbcore.NewQuery(
		"SELECT ckey, COUNT(ckey) AS c FROM [format_table_name("achievements")] AS a JOIN [format_table_name("achievement_metadata")] m ON a.achievement_key = m.achievement_key AND m.achievement_type = 'Achievement' GROUP BY ckey ORDER BY c DESC LIMIT 50",
	)
	if(!get_unlocked_highscore.Execute(async = TRUE))
		qdel(get_unlocked_highscore)
		return
	else
		while(get_unlocked_highscore.NextRow())
			var/key = get_unlocked_highscore.item[1]
			var/score = text2num(get_unlocked_highscore.item[2])
			high_scores += list(list("ckey" = key, "value" = score))
		qdel(get_unlocked_highscore)

/datum/award/score/achievements_score/on_achievement_data_init(datum/achievement_data/holder, database_value)
	var/datum/db_query/get_unlocked_load = SSdbcore.NewQuery(
		"SELECT COUNT(m.achievement_key) FROM [format_table_name("achievements")] AS a JOIN [format_table_name("achievement_metadata")] m ON a.achievement_key = m.achievement_key AND m.achievement_type = 'Achievement' WHERE a.ckey = :ckey",
		list("ckey" = holder.owner_ckey)
	)
	if(!get_unlocked_load.Execute(async = TRUE))
		qdel(get_unlocked_load)
		return
	if(get_unlocked_load.NextRow())
		holder.data[type] = text2num(get_unlocked_load.item[1]) || 0
		holder.original_cached_data[type] = 0
	qdel(get_unlocked_load)

/**
 * A subtype of score linked to a schema table containing objects the player has caught, made, found or otherwise achieved.
 * The value of the score should equal to the length of objects that have been achieved.
 * It also has an unique tab in the UI that lets you review the progress.
 */
/datum/award/score/progress
	/**
	 * When get_changed_rows is called, this list gets filled with the entries to be mass-inserted
	 * in the table associated with this progress score.
	 */
	VAR_FINAL/list/changed_entries = list()

/datum/award/score/progress/New()
	. = ..()
	if(!get_table())
		CRASH("get_table() wasn't set for [type]!")
	RegisterSignal(SSachievements, COMSIG_ACHIEVEMENTS_SAVED_TO_DB, PROC_REF(insert_entries))

/**
 * Getter proc for the table used to save the entries - ckey association.
 * so we an be extra-safe that data won't be ever inserted in the wrong table.
 * Remember to set this
 */
/datum/award/score/progress/proc/get_table()
	return

/datum/award/score/progress/vv_edit_var(var_name, var_value)
	//These variable is associated for sql queries. We can't allow it to be edited.
	if(var_name == NAMEOF(src, changed_entries))
		return FALSE
	return ..()

/datum/award/score/progress/unlock(mob/user, datum/achievement_data/holder, value)
	var/list/entries = holder.data[type]
	if(!value)
		CRASH("empty value used as argument to progress this score award.")
	if(value in entries)
		return
	// This ensures that the original list and the new won't be the same any longer.
	// So that it'll pass the not-equal if statement and be saved in the db.
	if(entries == holder.original_cached_data[type])
		entries = entries?.Copy() || list()
		holder.data[type] = entries
	entries |= value

/datum/award/score/progress/load(datum/achievement_data/holder)
	var/list/results = ..()
	return validate_loaded_data(holder, results)

/datum/award/score/progress/on_achievement_data_init(datum/achievement_data/holder, database_value)
	var/list/results = parse_value(get_raw_value(holder.owner_ckey))
	validate_loaded_data(holder, results)

/datum/award/score/progress/proc/validate_loaded_data(datum/achievement_data/holder, list/results)
	holder.original_cached_data[type] = holder.data[type] = results
	if(!length(results))
		return results
	///This list will be populated on validate_entries()
	var/list/validated_results = list()
	if(!validate_entries(results, validated_results))
		holder.data[type] = validated_results
	return validated_results

///Along with the changed rows for the main table, this also populates changed_entries with the entries list
/datum/award/score/progress/get_changed_rows(datum/achievement_data/holder)
	if(!database_id || !holder || !name || !get_table())
		return
	var/list/entries = holder.data[type]
	for(var/entry in (entries - holder.original_cached_data[type]))
		changed_entries += list(list("ckey" = holder.owner_ckey, "progress_entry" = entry))
	return list(
		"ckey" = holder.owner_ckey,
		"achievement_key" = database_id,
		"value" = length(entries),
	)

/datum/award/score/progress/get_ui_data(list/award_data, datum/achievement_data/holder)
	. = ..()
	award_data["value"] = length(holder.data[type])

///We don't care much about the default value, which is only used for high scores. Instead, we get the entries string from the db.
/datum/award/score/progress/get_raw_value(key)
	var/list/entries = list()
	var/datum/db_query/get_entries_load = SSdbcore.NewQuery(
		"SELECT progress_entry FROM [format_table_name(get_table())] WHERE ckey = :ckey",
		list("ckey" = key)
	)
	if(!get_entries_load.Execute())
		qdel(get_entries_load)
		return entries
	while(get_entries_load.NextRow())
		entries |= get_entries_load.item[1]
	qdel(get_entries_load)
	return entries

/datum/award/score/progress/parse_value(raw_value)
	return islist(raw_value) ? raw_value : list()

//Proc that returns a value upon db connection failure, in case we need to new instances too
/datum/award/score/progress/default_value()
	return list()

/**
 * Validates the list of entries after it's parsed.
 * If TRUE is returned (entries list is valid), 'entries' will be stored in both
 * original_cached_data[type] and data[type] of the achievements holder.
 * Otherwise data[type] will be the new validated_entries list,
 * ensuring that the original data and the new data aren't the same, allowing the new data will be saved.
 */
/datum/award/score/progress/proc/validate_entries(list/entries, list/validated_entries)
	validated_entries = unique_list(entries)
	return length(validated_entries) == length(entries)

////Returns a list of data that we can use to make an index of contents that progress this award/score.
/datum/award/score/progress/proc/get_progress(datum/achievement_data/holder)
	CRASH("get_progress() undefined for [type]")

///Called once the achievements are saved in the DB, since we also have to insert the entries in the associated table.
/datum/award/score/progress/proc/insert_entries(datum/source)
	SIGNAL_HANDLER
	if(!length(changed_entries))
		return
	INVOKE_ASYNC(SSdbcore, TYPE_PROC_REF(/datum/controller/subsystem/dbcore, MassInsert), format_table_name(get_table()), changed_entries, duplicate_key = TRUE)
