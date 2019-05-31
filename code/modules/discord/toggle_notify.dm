// Verb to toggle restart notifications
/client/verb/notify_restart()
	set category = "Special Verbs"
	set name = "Notify Restart"
	set desc = "Notifies you on Discord when the server restarts."

	// Safety checks
	if(!CONFIG_GET(flag/sql_enabled))
		to_chat(src, "<span class='warning'>This is feature requires the SQL backend to be running.</span>")
		return

	if(!CONFIG_GET(string/chat_announce_new_game))
		to_chat(src, "<span class='warning'>Notify is not enabled in server configuration.</span>")
		return

	if(!SSnotify) // SS is still starting
		to_chat(src, "<span class='notice'>The server is still starting up. Please wait before attempting to link your account </span>")
		return

	if(!SSnotify.enabled)
		to_chat(src, "<span class='warning'>This is feature requires the server is running on the TGS toolkit, </span>")
		return

	var/user_ckey = sanitizeSQL(usr.ckey) // Probably not neccassary but better safe than sorry
	// Query to check if they are libked
	var/stored_id
	var/datum/DBQuery/get_discord_id = SSdbcore.NewQuery("SELECT discord_id FROM [format_table_name("discord")] WHERE ckey = '[user_ckey]'")
	if(get_discord_id.Execute())
		while(get_discord_id.NextRow())
			stored_id = get_discord_id.item[1]
	qdel(get_discord_id)
	if(!stored_id) // Account is not linked
		to_chat(src, "<span class='warning'>This requires you to link your Discord account with the \"Link Discord Account\" verb.</span>")
		return

	else // Linked
		for(var/member in SSnotify.notify_members) // If they are in the list, take them out
			if(member == "[stored_id]")
				SSnotify.notify_members -= "[stored_id]" // The list uses strings because BYOND cannot handle a 17 digit integer
				to_chat(src, "<span class='notice'>You will no longer be notified when the server restarts</span>")
				return // This is necassary so it doesnt get added again, as it relies on the for loop being unsuccessful to tell us if they are in the list or not
		
		// If we got here, they arent in the list. Chuck 'em in!
		to_chat(src, "<span class='notice'>You will now be notified when the server restarts</span>")
		SSnotify.notify_members += "[stored_id]" // The list uses strings because BYOND cannot handle a 17 digit integer
