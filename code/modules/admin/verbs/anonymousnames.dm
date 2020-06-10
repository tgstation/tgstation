/client/proc/anon_names()
	set category = "Admin - Events"
	set name = "Setup Anonymous Names"


	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(usr, "This option is currently only usable during pregame.")
		return

	if(SSticker.anonymousnames)
		SSticker.anonymousnames = ANON_DISABLED
		to_chat(usr, "Disabled anonymous names.")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] has disabled anonymous names.</span>")
		return
	var/list/names = list("Cancel", ANON_RANDOMNAMES, ANON_EMPLOYEENAMES)
	var/result = input(usr, "Choose an anonymous theme","going dark") as null|anything in names
	if(!usr || !result || result == "Cancel")
		return
	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(usr, "You took too long! The game has started.")
		return

	SSticker.anonymousnames = result
	to_chat(usr, "Enabled anonymous names. THEME: [SSticker.anonymousnames].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has enabled anonymous names. THEME: [SSticker.anonymousnames].</span>")

/**
  * anonymous_name: generates a corporate random name. used in admin event tool anonymous names
  *
  * first letter is always a letter
  * Example name = "Employee Q5460Z"
  * Arguments:
  * * M - mob for preferences and gender
  */
/proc/anonymous_name(mob/M)
	switch(SSticker.anonymousnames)
		if(ANON_RANDOMNAMES)
			return M.client.prefs.pref_species.random_name(M.gender,1)
		if(ANON_EMPLOYEENAMES)
			var/name = "Employee "

			for(var/i in 1 to 6)
				if(prob(30) || i == 1)
					name += ascii2text(rand(65, 90)) //A - Z
				else
					name += ascii2text(rand(48, 57)) //0 - 9
			return name

/**
  * anonymous_ai_name: generates a corporate random name (but for sillycones). used in admin event tool anonymous names
  *
  * first letter is always a letter
  * Example name = "Employee Assistant Assuming Delta"
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
