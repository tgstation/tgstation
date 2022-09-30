/**
 * # Discord Subsystem
 *
 * This subsystem handles some integrations with discord
 *
 *
 * NOTES:
 * * There is a DB table to track ckeys and associated discord IDs. (discord_link)
 * * This system REQUIRES TGS for notifying users at end of the round
 * * The SS uses fire() instead of just pure shutdown, so people can be notified if it comes back after a crash, where the SS wasn't properly shutdown
 * * It only writes to the disk every 5 minutes, and it won't write to disk if the file is the same as it was the last time it was written. This is to save on disk writes
 * * The system is kept per-server (EG: Terry will not notify people who pressed notify on Sybil), but the accounts are between servers so you dont have to relink on each server.
 *
 *
 * ## HOW NOTIFYING WORKS
 *
 * ### ROUNDSTART:
 * 1) The file is loaded and the discord IDs are extracted
 * 2) A ping is sent to the discord with the IDs of people who wished to be notified
 * 3) The file is emptied
 *
 * ### MIDROUND:
 * 1) Someone usees the notify verb, it adds their discord ID to the list.
 * 2) On fire, it will write that to the disk, as long as conditions above are correct
 *
 * ### END ROUND:
 * 1) The file is force-saved, incase it hasn't fired at end round
 *
 * This is an absolute clusterfuck, but its my clusterfuck -aa07
 */
SUBSYSTEM_DEF(discord)
	name = "Discord"
	wait = 3000
	init_order = INIT_ORDER_DISCORD

	/// People to save to notify file
	var/list/notify_members = list()
	/// Copy of previous list, so the SS doesnt have to fire if no new members have been added
	var/list/notify_members_cache = list()
	/// People to notify on roundstart
	var/list/people_to_notify = list()

	/// People who have tried to verify this round already
	var/list/reverify_cache

	/// Common words list, used to generate one time tokens
	var/list/common_words

	/// The file where notification status is saved
	var/notify_file = file("data/notify.json")

	/// Is TGS enabled (If not we won't fire because otherwise this is useless)
	var/enabled = FALSE

/datum/controller/subsystem/discord/Initialize()
	common_words = world.file2list("strings/1000_most_common.txt")
	reverify_cache = list()
	// Check for if we are using TGS, otherwise return and disables firing
	if(world.TgsAvailable())
		enabled = TRUE // Allows other procs to use this (Account linking, etc)
	else
		can_fire = FALSE // We dont want excess firing
		return SS_INIT_NO_NEED

	try
		people_to_notify = json_decode(file2text(notify_file))
	catch
		pass() // The list can just stay as its default (blank). Pass() exists because it needs a catch
	var/notifymsg = jointext(people_to_notify, ", ")
	if(notifymsg)
		notifymsg += ", a new round is starting!"
		send2chat(trim(notifymsg), CONFIG_GET(string/chat_new_game_notifications)) // Sends the message to the discord, using same config option as the roundstart notification
	fdel(notify_file) // Deletes the file
	return SS_INIT_SUCCESS

/datum/controller/subsystem/discord/fire()
	if(!enabled)
		return // Dont do shit if its disabled
	if(notify_members == notify_members_cache)
		return // Dont re-write the file
	// If we are all clear
	write_notify_file()

/datum/controller/subsystem/discord/Shutdown()
	write_notify_file() // Guaranteed force-write on server close

/datum/controller/subsystem/discord/proc/write_notify_file()
	if(!enabled) // Dont do shit if its disabled
		return
	fdel(notify_file) // Deletes the file first to make sure it writes properly
	WRITE_FILE(notify_file, json_encode(notify_members)) // Writes the file
	notify_members_cache = notify_members // Updates the cache list

/**
 * Given a ckey, look up the discord user id attached to the user, if any
 *
 * This gets the most recent entry from the discord link table that is associated with the given ckey
 *
 * Arguments:
 * * lookup_ckey A string representing the ckey to search on
 */
/datum/controller/subsystem/discord/proc/lookup_id(lookup_ckey)
	var/datum/discord_link_record/link = find_discord_link_by_ckey(lookup_ckey)
	if(link)
		return link.discord_id

/**
 * Given a discord id as a string, look up the ckey attached to that account, if any
 *
 * This gets the most recent entry from the discord_link table that is associated with this discord id snowflake
 *
 * Arguments:
 * * lookup_id The discord id as a string
 */
/datum/controller/subsystem/discord/proc/lookup_ckey(lookup_id)
	var/datum/discord_link_record/link = find_discord_link_by_discord_id(lookup_id)
	if(link)
		return link.ckey

/datum/controller/subsystem/discord/proc/get_or_generate_one_time_token_for_ckey(ckey)
	// Is there an existing valid one time token
	var/datum/discord_link_record/link = find_discord_link_by_ckey(ckey, timebound = TRUE)
	if(link)
		return link.one_time_token

	// Otherwise we make one
	return generate_one_time_token(ckey)

/**
 * Generate a timebound token for discord verification
 *
 * This uses the common word list to generate a six word random token, this token can then be fed to a discord bot that has access
 * to the same database, and it can use it to link a ckey to a discord id, with minimal user effort
 *
 * It returns the token to the calling proc, after inserting an entry into the discord_link table of the following form
 *
 * ```
 * (unique_id, ckey, null, the current time, the one time token generated)
 * the null value will be filled out with the discord id by the integrated discord bot when a user verifies
 * ```
 *
 * Notes:
 * * The token is guaranteed to unique during it's validity period
 * * The validity period is currently set at 4 hours
 * * a token may not be unique outside it's validity window (to reduce conflicts)
 *
 * Arguments:
 * * ckey_for a string representing the ckey this token is for
 *
 * Returns a string representing the one time token
 */
/datum/controller/subsystem/discord/proc/generate_one_time_token(ckey_for)

	var/not_unique = TRUE
	var/one_time_token = ""
	// While there's a collision in the token, generate a new one (should rarely happen)
	while(not_unique)
		//Column is varchar 100, so we trim just in case someone does us the dirty later
		one_time_token = trim("[pick(common_words)]-[pick(common_words)]-[pick(common_words)]-[pick(common_words)]-[pick(common_words)]-[pick(common_words)]", 100)

		not_unique = find_discord_link_by_token(one_time_token, timebound = TRUE)

	// Insert into the table, null in the discord id, id and timestamp and valid fields so the db fills them out where needed
	var/datum/db_query/query_insert_link_record = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("discord_links")] (ckey, one_time_token) VALUES(:ckey, :token)",
		list("ckey" = ckey_for, "token" = one_time_token)
	)

	if(!query_insert_link_record.Execute())
		qdel(query_insert_link_record)
		return ""

	//Cleanup
	qdel(query_insert_link_record)
	return one_time_token

/**
 * Find discord link entry by the passed in user token
 *
 * This will look into the discord link table and return the *first* entry that matches the given one time token
 *
 * Remember, multiple entries can exist, as they are only guaranteed to be unique for their validity period
 *
 * Arguments:
 * * one_time_token the string of words representing the one time token
 * * timebound A boolean flag, that specifies if it should only look for entries within the last 4 hours, off by default
 *
 * Returns a [/datum/discord_link_record]
 */
/datum/controller/subsystem/discord/proc/find_discord_link_by_token(one_time_token, timebound = FALSE)
	var/timeboundsql = ""
	if(timebound)
		timeboundsql = "AND timestamp >= Now() - INTERVAL 4 HOUR"
	var/query = "SELECT CAST(discord_id AS CHAR(25)), ckey, MAX(timestamp), one_time_token FROM [format_table_name("discord_links")] WHERE one_time_token = :one_time_token [timeboundsql] GROUP BY ckey, discord_id, one_time_token LIMIT 1"
	var/datum/db_query/query_get_discord_link_record = SSdbcore.NewQuery(
		query,
		list("one_time_token" = one_time_token)
	)
	if(!query_get_discord_link_record.Execute())
		qdel(query_get_discord_link_record)
		return
	if(query_get_discord_link_record.NextRow())
		var/result = query_get_discord_link_record.item
		. = new /datum/discord_link_record(result[2], result[1], result[4], result[3])

	//Make sure we clean up the query
	qdel(query_get_discord_link_record)

/**
 * Find discord link entry by the passed in user ckey
 *
 * This will look into the discord link table and return the *first* entry that matches the given ckey
 *
 * Remember, multiple entries can exist
 *
 * Arguments:
 * * ckey the users ckey as a string
 * * timebound should we search only in the last 4 hours
 *
 * Returns a [/datum/discord_link_record]
 */
/datum/controller/subsystem/discord/proc/find_discord_link_by_ckey(ckey, timebound = FALSE)
	var/timeboundsql = ""
	if(timebound)
		timeboundsql = "AND timestamp >= Now() - INTERVAL 4 HOUR"

	var/query = "SELECT CAST(discord_id AS CHAR(25)), ckey, MAX(timestamp), one_time_token FROM [format_table_name("discord_links")] WHERE ckey = :ckey [timeboundsql] GROUP BY ckey, discord_id, one_time_token LIMIT 1"
	var/datum/db_query/query_get_discord_link_record = SSdbcore.NewQuery(
		query,
		list("ckey" = ckey)
	)
	if(!query_get_discord_link_record.Execute())
		qdel(query_get_discord_link_record)
		return

	if(query_get_discord_link_record.NextRow())
		var/result = query_get_discord_link_record.item
		. = new /datum/discord_link_record(result[2], result[1], result[4], result[3])

	//Make sure we clean up the query
	qdel(query_get_discord_link_record)


/**
 * Find discord link entry by the passed in user ckey
 *
 * This will look into the discord link table and return the *first* entry that matches the given ckey
 *
 * Remember, multiple entries can exist
 *
 * Arguments:
 * * discord_id The users discord id (string)
 * * timebound should we search only in the last 4 hours
 *
 * Returns a [/datum/discord_link_record]
 */
/datum/controller/subsystem/discord/proc/find_discord_link_by_discord_id(discord_id, timebound = FALSE)
	var/timeboundsql = ""
	if(timebound)
		timeboundsql = "AND timestamp >= Now() - INTERVAL 4 HOUR"

	var/query = "SELECT CAST(discord_id AS CHAR(25)), ckey, MAX(timestamp), one_time_token FROM [format_table_name("discord_links")] WHERE discord_id = :discord_id [timeboundsql] GROUP BY ckey, discord_id, one_time_token LIMIT 1"
	var/datum/db_query/query_get_discord_link_record = SSdbcore.NewQuery(
		query,
		list("discord_id" = discord_id)
	)
	if(!query_get_discord_link_record.Execute())
		qdel(query_get_discord_link_record)
		return

	if(query_get_discord_link_record.NextRow())
		var/result = query_get_discord_link_record.item
		. = new /datum/discord_link_record(result[2], result[1], result[4], result[3])

	//Make sure we clean up the query
	qdel(query_get_discord_link_record)
