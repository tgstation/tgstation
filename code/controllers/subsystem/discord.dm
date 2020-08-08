/*
NOTES:
There is a DB table to track ckeys and associated discord IDs.
This system REQUIRES TGS, and will auto-disable if TGS is not present.
The SS uses fire() instead of just pure shutdown, so people can be notified if it comes back after a crash, where the SS wasn't properly shutdown
It only writes to the disk every 5 minutes, and it won't write to disk if the file is the same as it was the last time it was written. This is to save on disk writes
The system is kept per-server (EG: Terry will not notify people who pressed notify on Sybil), but the accounts are between servers so you dont have to relink on each server.

##################
# HOW THIS WORKS #
##################

ROUNDSTART:
1] The file is loaded and the discord IDs are extracted
2] A ping is sent to the discord with the IDs of people who wished to be notified
3] The file is emptied

MIDROUND:
1] Someone usees the notify verb, it adds their discord ID to the list.
2] On fire, it will write that to the disk, as long as conditions above are correct

END ROUND:
1] The file is force-saved, incase it hasn't fired at end round

This is an absolute clusterfuck, but its my clusterfuck -aa07
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
	/// List that holds accounts to link, used in conjunction with TGS
	var/list/account_link_cache = list()
	/// list of people who tried to reverify, so they can only do it once per round as a shitty slowdown
	var/list/reverify_cache = list()
	var/notify_file = file("data/notify.json")
	/// Is TGS enabled (If not we won't fire because otherwise this is useless)
	var/enabled = 0

/datum/controller/subsystem/discord/Initialize(start_timeofday)
	// Check for if we are using TGS, otherwise return and disables firing
	if(world.TgsAvailable())
		enabled = 1 // Allows other procs to use this (Account linking, etc)
	else
		can_fire = 0 // We dont want excess firing
		return ..() // Cancel

	try
		people_to_notify = json_decode(file2text(notify_file))
	catch
		pass() // The list can just stay as its default (blank). Pass() exists because it needs a catch
	var/notifymsg = jointext(people_to_notify, ", ")
	if(notifymsg)
		notifymsg += ", a new round is starting!"
		send2chat(trim(notifymsg), CONFIG_GET(string/chat_new_game_notifications)) // Sends the message to the discord, using same config option as the roundstart notification
	fdel(notify_file) // Deletes the file
	return ..()

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

// Returns ID from ckey
/datum/controller/subsystem/discord/proc/lookup_id(lookup_ckey)
	//We cast the discord ID to varchar to prevent BYOND mangling
	//it into it's scientific notation
	var/datum/db_query/query_get_discord_id = SSdbcore.NewQuery(
		"SELECT CAST(discord_id AS CHAR(25)) FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = lookup_ckey)
	)
	if(!query_get_discord_id.Execute())
		qdel(query_get_discord_id)
		return
	if(query_get_discord_id.NextRow())
		. = query_get_discord_id.item[1]
	qdel(query_get_discord_id)

// Returns ckey from ID
/datum/controller/subsystem/discord/proc/lookup_ckey(lookup_id)
	var/datum/db_query/query_get_discord_ckey = SSdbcore.NewQuery(
		"SELECT ckey FROM [format_table_name("player")] WHERE discord_id = :discord_id",
		list("discord_id" = lookup_id)
	)
	if(!query_get_discord_ckey.Execute())
		qdel(query_get_discord_ckey)
		return
	if(query_get_discord_ckey.NextRow())
		. = query_get_discord_ckey.item[1]
	qdel(query_get_discord_ckey)

// Finalises link
/datum/controller/subsystem/discord/proc/link_account(ckey)
	var/datum/db_query/link_account = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET discord_id = :discord_id WHERE ckey = :ckey",
		list("discord_id" = account_link_cache[ckey], "ckey" = ckey)
	)
	link_account.Execute()
	qdel(link_account)
	account_link_cache -= ckey

// Unlink account (Admin verb used)
/datum/controller/subsystem/discord/proc/unlink_account(ckey)
	var/datum/db_query/unlink_account = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET discord_id = NULL WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	unlink_account.Execute()
	qdel(unlink_account)

// Clean up a discord account mention
/datum/controller/subsystem/discord/proc/id_clean(input)
	var/regex/num_only = regex("\[^0-9\]", "g")
	return num_only.Replace(input, "")

/datum/controller/subsystem/discord/proc/grant_role(id)
	// Ignore this shit if config isn't enabled for it
	if(!CONFIG_GET(flag/enable_discord_autorole))
		return

	var/url = "https://discord.com/api/guilds/[CONFIG_GET(string/discord_guildid)]/members/[id]/roles/[CONFIG_GET(string/discord_roleid)]"

	// Make the request
	var/datum/http_request/req = new()
	req.prepare(RUSTG_HTTP_METHOD_PUT, url, "", list("Authorization" = "Bot [CONFIG_GET(string/discord_token)]"))
	req.begin_async()
	UNTIL(req.is_complete())
	var/datum/http_response/res = req.into_response()

	WRITE_LOG(GLOB.discord_api_log, "PUT [url] returned [res.status_code] [res.body]")
