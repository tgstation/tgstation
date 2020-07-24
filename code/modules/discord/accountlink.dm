// Verb to link discord accounts to BYOND accounts
/client/verb/linkdiscord()
	set category = "OOC"
	set name = "Link Discord Account"
	set desc = "Link your discord account to your BYOND account."

	// Safety checks
	if(!CONFIG_GET(flag/sql_enabled))
		to_chat(src, "<span class='warning'>This feature requires the SQL backend to be running.</span>")
		return

	if(!SSdiscord) // SS is still starting
		to_chat(src, "<span class='notice'>The server is still starting up. Please wait before attempting to link your account!</span>")
		return

	if(!SSdiscord.enabled)
		to_chat(src, "<span class='warning'>This feature requires the server is running on the TGS toolkit.</span>")
		return

	var/stored_id = SSdiscord.lookup_id(usr.ckey)
	if(!stored_id) // Account is not linked
		var/know_how = alert("Do you know how to get a Discord user ID? This ID is NOT your Discord username and numbers! (Pressing NO will open a guide.)","Question","Yes","No","Cancel Linking")
		if(know_how == "No") // Opens discord support on how to collect IDs
			src << link("https://tgstation13.org/wiki/How_to_find_your_Discord_User_ID")
		if(know_how == "Cancel Linking")
			return
		var/entered_id = input("Please enter your Discord ID (18-ish digits)", "Enter Discord ID", null, null) as text|null
		SSdiscord.account_link_cache[replacetext(lowertext(usr.ckey), " ", "")] = "[entered_id]" // Prepares for TGS-side verification, also fuck spaces
		alert(usr, "Account link started. Please ping the bot of the server you\'re currently on, followed by \"verify [usr.ckey]\" in Discord to successfully verify your account (Example: @Mr_Terry verify [usr.ckey])")

	else // Account is already linked
		var/choice = alert("You already have the Discord Account [stored_id] linked to [usr.ckey]. Would you like to link a different account?","Already Linked","Yes","No")
		if(choice == "Yes")
			var/know_how = alert("Do you know how to get a Discord user ID? This ID is NOT your Discord username and numbers! (Pressing NO will open a guide.)","Question","Yes","No", "Cancel Linking")
			if(know_how == "No")
				src << link("https://tgstation13.org/wiki/How_to_find_your_Discord_User_ID")

			if(know_how == "Cancel Linking")
				return

			var/entered_id = input("Please enter your Discord ID (18-ish digits)", "Enter Discord ID", null, null) as text|null
			SSdiscord.account_link_cache[replacetext(lowertext(usr.ckey), " ", "")] = "[entered_id]" // Prepares for TGS-side verification, also fuck spaces
			alert(usr, "Account link started. Please ping the bot of the server you\'re currently on, followed by \"verify [usr.ckey]\" in Discord to successfully verify your account (Example: @Mr_Terry verify [usr.ckey])")
			// This is so people cant fill the notify list with a fuckload of ckeys
			SSdiscord.notify_members -= "[stored_id]" // The list uses strings because BYOND cannot handle a 17 digit integer

// IF you have linked your account, this will trigger a verify of the user
/client/verb/verify_in_discord()
	set category = "OOC"
	set name = "Verify Discord Account"
	set desc = "Verify or reverify your discord account against your linked ckey"

	// Safety checks
	if(!CONFIG_GET(flag/sql_enabled))
		to_chat(src, "<span class='warning'>This feature requires the SQL backend to be running.</span>")
		return

	// ss is still starting
	if(!SSdiscord)
		to_chat(src, "<span class='notice'>The server is still starting up. Please wait before attempting to link your account!</span>")
		return

	// check that tgs is alive and well
	if(!SSdiscord.enabled)
		to_chat(src, "<span class='warning'>This feature requires the server is running on the TGS toolkit.</span>")
		return

	// check that this is not an IDIOT mistaking us for an attack vector
	if(SSdiscord.reverify_cache[usr.ckey] == TRUE)
		to_chat(src, "<span class='warning'>Thou can only do this once a round, if you're stuck seek help.</span>")
		return
	SSdiscord.reverify_cache[usr.ckey] = TRUE

	// check that account is linked with discord
	var/stored_id = SSdiscord.lookup_id(usr.ckey)
	if(!stored_id) // Account is not linked
		to_chat(usr, "Link your discord account via the linkdiscord verb in the OOC tab first");
		return

	// check for living hours requirement
	var/required_living_minutes = CONFIG_GET(number/required_living_hours) * 60
	var/living_minutes = usr.client ? usr.client.get_exp_living(TRUE) : 0
	if(required_living_minutes <= 0)
		CRASH("The discord verification system is setup to require zero hours or less, this is likely a configuration bug")
		
	if(living_minutes < required_living_minutes)
		to_chat(usr, "<span class='warning'>You must have at least [required_living_minutes] minutes of living " \
			+ "playtime in a round to verify. You have [living_minutes] minutes. Play more!</span>")
		return

	// honey its time for your role flattening
	to_chat(usr, "<span class='notice'>Discord verified</span>")
	SSdiscord.grant_role(stored_id)
