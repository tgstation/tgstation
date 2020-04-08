/client/proc/anon_names()
	set category = "Admin - Events"
	set name = "Toggle Anonymous Names"

	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(usr, "This option is currently only usable during pregame.")
		return

	SSticker.anonymousnames = !SSticker.anonymousnames
	to_chat(usr, "Toggled anonymous names [SSticker.anonymousnames ? "ON" : "OFF"].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has toggled anonymous names [SSticker.anonymousnames ? "ON" : "OFF"].</span>")

/**
  * anonymous_name: generates a corporate random name. used in admin event tool anonymous names
  *
  * first letter is always a letter
  * Example name = "Employee Q5460Z"
  * Arguments:
  */

/proc/anonymous_name()
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
	var/verbs = capitalize(pick(GLOB.ing_verbs))
	var/phonetic = pick(GLOB.phonetic_alphabet)

	return "Employee [is_ai ? "Core" : "Assistant"] [verbs] [phonetic]"
