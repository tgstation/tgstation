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
	/// List of all currently queued up NON-ADDITIVE achievement query arguments (for roundend purposes).
	var/list/achievement_query_arguments = list()
	/// List of all currently queued up ADDITIVE achievement query arguments (for roundend purposes).
	var/list/additive_achievement_query_arguments = list()
	/// Are we done handling all of the achievements of roundend? This is so we
	/// go back to individually updating the achievements again.
	var/post_roundend = FALSE


/datum/controller/subsystem/achievements/Initialize()
	if(!SSdbcore.Connect())
		return SS_INIT_NO_NEED
	achievements_enabled = TRUE

	for(var/T in subtypesof(/datum/award/achievement))
		var/instance = new T
		achievements[T] = instance
		awards[T] = instance

	for(var/T in subtypesof(/datum/award/score))
		var/instance = new T
		scores[T] = instance
		awards[T] = instance

	// update_metadata()

	for(var/i in GLOB.clients)
		var/client/achieving_client = i
		if(!achieving_client.player_details.achievements.initialized)
			achieving_client.player_details.achievements.InitializeData()

	return SS_INIT_SUCCESS

/datum/controller/subsystem/achievements/Shutdown()
	// save_achievements_to_db()

/datum/controller/subsystem/achievements/proc/save_achievements_to_db()
	var/list/cheevos_to_save = list()
	for(var/ckey in GLOB.player_details)
		var/datum/player_details/player_details = GLOB.player_details[ckey]
		if(!player_details || !player_details.achievements)
			continue

		cheevos_to_save += player_details.achievements.get_changed_data()

	if(!length(cheevos_to_save))
		return

	SSdbcore.MassInsert(format_table_name("achievements"), cheevos_to_save, duplicate_key = TRUE)


/**
 * Proc that updates an achievement's value in the database.
 *
 * Arguments:
 * * ckey - The ckey of the player whose achievement we're updating.
 * * achievement_key - The typepath of the achievement we're updating.
 * * new_value (optional) - The new value for the achievement, defaulting to TRUE.
 * * additive (optional) - Whether or not the achievement is additive, defaulting to `FALSE`.
 * If set to `FALSE`, will simply overwrite the value on the database using the `new_value`.
 * If set to `TRUE`, it will add `new_value` to the value already present in the database.
 * You should only be setting this to `TRUE` for scores, achievements are binary.
 */
/datum/controller/subsystem/achievements/proc/update_achievement(ckey, achievement_type, new_value = TRUE, additive = FALSE)
	if(!ckey || !achievement_type)
		return

	var/datum/award/award = awards[achievement_type]

	if(!award)
		return

	var/datum/db_query/query = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("achievements")] (ckey, achievement_key, value) VALUES(:ckey, :achievement_key, :value) ON DUPLICATE KEY UPDATE value = [additive ? "value + " : ""]VALUES(value)",
		award.get_changed_rows(ckey, new_value),
	)

	query.Execute(async = TRUE)


/**
 * Proc that queues an update of an achievement in the database. If we're not currently
 * in the part of roundend where many achievements are granted at once, the achievement
 * will be updated instantly. If we are, the achievement update will be queued to be
 * inserted in a MassInsert query a little later in the roundend process.
 *
 * Arguments:
 * * ckey - The ckey of the player whose achievement we're updating.
 * * achievement_type - The typepath of the achievement we're updating.
 * * new_value (optional) - The new value for the achievement, defaulting to TRUE.
 * * additive (optional) - Whether or not the achievement is additive, defaulting to `FALSE`.
 * If set to `FALSE`, will simply overwrite the value on the database using the `new_value`.
 * If set to `TRUE`, it will add `new_value` to the value already present in the database.
 * You should only be setting this to `TRUE` for scores, achievements are binary.
 */
/datum/controller/subsystem/achievements/proc/queue_achievement_update(ckey, achievement_type, new_value = TRUE, additive = FALSE)
	if(!ckey || !achievement_type)
		return

	if(SSticker.current_state != GAME_STATE_FINISHED || post_roundend)
		update_achievement(ckey, achievement_type, new_value, additive)
		return

	var/datum/award/award = awards[achievement_type]

	if(!award)
		return

	var/datum/award/score/score = scores[achievement_type]

	if(score && score.additive)
		additive_achievement_query_arguments += list(award.get_changed_rows(ckey, new_value))
	else
		achievement_query_arguments += list(award.get_changed_rows(ckey, new_value))


/**
 * Proc that runs the MassInsert queries for the roundend section of the round,
 * to avoid running possibly hundreds of queries all at once when we're ending
 * the round.
 */
/datum/controller/subsystem/achievements/proc/run_roundend_achievements_queries()
	if(SSticker.current_state != GAME_STATE_FINISHED || post_roundend || !length(achievement_query_arguments))
		return

	post_roundend = TRUE

	SSdbcore.MassInsert(format_table_name("achievements"), achievement_query_arguments, duplicate_key = TRUE, async = TRUE)

	if(!length(additive_achievement_query_arguments))
		return

	SSdbcore.MassInsert(format_table_name("achievements"), achievement_query_arguments, duplicate_key = "\nON DUPLICATE KEY UPDATE value = value + VALUES(value)", async = TRUE)
