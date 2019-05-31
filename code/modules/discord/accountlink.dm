// Verb to link discord accounts to BYOND accounts
/client/verb/linkdiscord()
	set category = "Special Verbs"
	set name = "Link Discord Account"
	set desc = "Link your discord account to your BYOND account."

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
		var/know_how = alert("Do you know how to get a discord user ID? This ID is NOT your discord username and numbers! (Pressing NO will open a guide)","Question","Yes","No")
		if(know_how == "No") // Opens discord support on how to collect IDs
			src << link("https://support.discordapp.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID")

		var/entered_id = input("Please enter your Discord ID (17 digits)", "Enter Discord ID", null, null) as text|null
		var/sql_id = sanitizeSQL(entered_id)
		var/datum/DBQuery/store_discord_id = SSdbcore.NewQuery("INSERT INTO [format_table_name("discord")] (ckey, discord_id) VALUES ('[user_ckey]', [sql_id])")
		store_discord_id.Execute()
		qdel(store_discord_id)
		to_chat(src, "<span class='notice'>Successfully linked discord account [entered_id] to [user_ckey]</span>")

	else // Account is already linked
		var/choice = alert("You already have the Discord Account [stored_id] linked to [user_ckey]. Would you like to unlink/replace the current account or cancel","Already Linked","Unlink","Replace","Cancel")
		switch(choice)
			if("Unlink")
				var/datum/DBQuery/unlink_discord_id = SSdbcore.NewQuery("DELETE FROM [format_table_name("discord")] WHERE ckey = '[user_ckey]'")
				unlink_discord_id.Execute()
				to_chat(src, "<span class='notice'>Successfully unlinked discord account</span>")
				qdel(unlink_discord_id)
				
			if("Replace")
				var/know_how = alert("Do you know how to get a discord user ID? This ID is NOT your discord username and numbers! (Pressing NO will open a guide)","Question","Yes","No")
				if(know_how == "No") // Opens discord support on how to collect IDs
					src << link("https://support.discordapp.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID")
				var/entered_id = input("Please enter your Discord ID (17 digits)", "Enter Discord ID", null, null) as text|null
				var/sql_id = sanitizeSQL(entered_id)
				var/datum/DBQuery/replace_discord_id = SSdbcore.NewQuery("UPDATE [format_table_name("discord")] SET discord_id = '[sql_id]' WHERE ckey='[user_ckey]'")
				replace_discord_id.Execute()
				qdel(replace_discord_id)
				to_chat(src, "<span class='notice'>Successfully linked discord account [entered_id] to [user_ckey]</span>")
		// This is so people cant fill the notify list with a fuckload of ckeys
		SSnotify.notify_members -= "[stored_id]" // The list uses strings because BYOND cannot handle a 17 digit integer
