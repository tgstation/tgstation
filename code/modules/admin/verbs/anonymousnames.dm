/client/proc/anon_names()
	set category = "Admin.Events"
	set name = "Setup Anonymous Names"

	if(SSticker.anonymousnames)
		var/response = alert(usr, "Anon mode is currently enabled. Disable?", "cold feet", "Disable Anon Names", "Keep it Enabled")
		if(response != "Disable Anon Names")
			return
		SSticker.anonymousnames = ANON_DISABLED
		to_chat(usr, "Disabled anonymous names.")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] has disabled anonymous names.</span>")
		if(SSticker.current_state > GAME_STATE_PREGAME)
			if(alert(usr, "Fix Current Crew?", "anon names", "Yes", "No") == "Yes")
				priority_announce("Names and Identities have been restored. Hopefully.", "Identity Restoration", 'sound/ai/attention.ogg')
				for(var/mob/living/player in GLOB.player_list)
					if(player.mind && (ishuman(player) || issilicon(player)) && SSjob.GetJob(player.mind.assigned_role))
						player.client.prefs.copy_to(player, antagonist = player.mind.antag_datums, is_latejoiner = FALSE)
		return
	var/list/names = list("Cancel", ANON_RANDOMNAMES, ANON_EMPLOYEENAMES)
	var/result = input(usr, "Choose an anonymous theme","going dark") as null|anything in names
	if(!usr || !result || result == "Cancel")
		return
	var/alert_players = "No"
	var/change_current_players = "No"
	if(SSticker.current_state > GAME_STATE_PREGAME) //before anonnames is done, for asking a sleep
		alert_players = alert(usr, "Alert crew? These are IC Themed FROM centcom.", "admins in 2016 wouldn't miss roundstart", "Yes", "No")
		change_current_players = alert(usr, "Change current players?", "admins in 2016 wouldn't miss roundstart", "Yes", "No")
	SSticker.anonymousnames = result
	if(alert_players == "Yes")
		var/announce_text
		switch(SSticker.anonymousnames)
			if(ANON_RANDOMNAMES)
				announce_text = "A recent bureaucratic error in the Organic Resources Department has resulted in a necessary full recall of all identities and names until further notice."
			if(ANON_EMPLOYEENAMES)
				announce_text = "As punishment for this station's poor productivity when compared to neighbor stations, names and identities will be restricted until further notice."
			if(ANON_WIZARDNAMES)
				announce_text = "Your station has been caught by a Wizard Federation Memetic Hazard. You are not y0urself, and yo% a2E 34!NOT4--- Welcome to the Academy, apprentices!"
		priority_announce(announce_text, "Identity Loss", 'sound/ai/attention.ogg')
	if(change_current_players == "Yes")
		for(var/mob/living/player in GLOB.player_list)
			if(player.mind && (ishuman(player) || issilicon(player)) && SSjob.GetJob(player.mind.assigned_role))
				if(issilicon(player))
					player.fully_replace_character_name(player.real_name, anonymous_ai_name(player))
				else
					player.fully_replace_character_name(player.real_name, anonymous_name(player))

	to_chat(usr, "Enabled anonymous names. THEME: [SSticker.anonymousnames].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has enabled anonymous names. THEME: [SSticker.anonymousnames].</span>")

/**
 * anonymous_name: generates a random name, based off of whatever the round's anonymousnames is set to. used in admin event tool anonymous names
 *
 * examples:
 * Employee = "Employee Q5460Z"
 * Wizards = "Gulstaff of Void"
 * Arguments:
 * * M - mob for preferences and gender
 */
/proc/anonymous_name(mob/M)
	switch(SSticker.anonymousnames)
		if(ANON_RANDOMNAMES)
			return M.client.prefs.pref_species.random_name(M.gender,1)
		if(ANON_EMPLOYEENAMES)
			var/list/heads = SSjob.get_all_heads()
			var/name = "[M.mind in heads ? "Manager" : "Employee"] "
			for(var/i in 1 to 6)
				if(prob(30) || i == 1)
					name += ascii2text(rand(65, 90)) //A - Z
				else
					name += ascii2text(rand(48, 57)) //0 - 9
			return name
		if(ANON_WIZARDNAMES)
			var/wizard_name_first = pick(GLOB.wizard_first)
			var/wizard_name_second = pick(GLOB.wizard_second)
			return "[wizard_name_first] [wizard_name_second]"

/**
 * anonymous_ai_name: generates a random name, based off of whatever the round's anonymousnames is set to (but for sillycones). used in admin event tool anonymous names
 *
 * examples:
 * Employee = "Employee Assistant Assuming Delta"
 * Wizards = "Crystallized Knowledge Nexus +23"
 * Arguments:
 * * is_ai - boolean to decide whether the name has "Core" (AI) or "Assistant" (Cyborg)
 */
/proc/anonymous_ai_name(is_ai = FALSE)
	switch(SSticker.anonymousnames)
		if(ANON_RANDOMNAMES)
			return pick(GLOB.ai_names)
		if(ANON_EMPLOYEENAMES)
			var/verbs = capitalize(pick(GLOB.ing_verbs))
			var/phonetic = pick(GLOB.phonetic_alphabet)
			return "Employee [is_ai ? "Core" : "Assistant"] [verbs] [phonetic]"
		if(ANON_WIZARDNAMES)
			return "Crystallized Knowledge [is_ai ? "Nexus" : "Sliver"] +[rand(1,99)]" //Could two people roll the same number? Yeah, probably. Do I CARE? Nawww
