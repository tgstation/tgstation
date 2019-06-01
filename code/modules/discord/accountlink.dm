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

	if(!SSdiscord) // SS is still starting
		to_chat(src, "<span class='notice'>The server is still starting up. Please wait before attempting to link your account </span>")
		return

	if(!SSdiscord.enabled)
		to_chat(src, "<span class='warning'>This is feature requires the server is running on the TGS toolkit, </span>")
		return

	var/stored_id = SSdiscord.lookup_id(usr.ckey)
	if(!stored_id) // Account is not linked
		var/know_how = alert("Do you know how to get a discord user ID? This ID is NOT your discord username and numbers! (Pressing NO will open a guide)","Question","Yes","No")
		if(know_how == "No") // Opens discord support on how to collect IDs
			src << link("https://support.discordapp.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID")

		var/entered_id = input("Please enter your Discord ID (17 digits)", "Enter Discord ID", null, null) as text|null
		SSdiscord.account_link_cache[lowertext(usr.ckey)] = "[entered_id]" // Prepares for TGS-side verification
		alert(usr, "Account link started. Please do !tgs verify in the Discord to successfuly verify your account")

	else // Account is already linked
		var/choice = alert("You already have the Discord Account [stored_id] linked to [usr.ckey]. Would you like to link a different account?","Already Linked","Yes","No")
		if(choice == "Yes")
			var/know_how = alert("Do you know how to get a discord user ID? This ID is NOT your discord username and numbers! (Pressing NO will open a guide)","Question","Yes","No")
			if(know_how == "No") // Opens discord support on how to collect IDs
				src << link("https://support.discordapp.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID")

			var/entered_id = input("Please enter your Discord ID (17 digits)", "Enter Discord ID", null, null) as text|null
			SSdiscord.account_link_cache[lowertext(usr.ckey)] = "[entered_id]" // Prepares for TGS-side verification
			alert(usr, "Account link started. Please do !tgs verify in the Discord to successfuly verify your account")				
			// This is so people cant fill the notify list with a fuckload of ckeys
			SSdiscord.notify_members -= "[stored_id]" // The list uses strings because BYOND cannot handle a 17 digit integer
