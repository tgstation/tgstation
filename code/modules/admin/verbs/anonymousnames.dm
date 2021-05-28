
/*Anon names! A system to make all players have random names/aliases instead of their static, for admin events/fuckery!
	contains both the anon names proc and the datums for each.

	this is the setup, it handles announcing crew and other settings for the mode and then creating the datum singleton
*/
/client/proc/anon_names()
	set category = "Admin.Events"
	set name = "Setup Anonymous Names"

	if(SSticker.anonymousnames)
		var/response = tgui_alert(usr, "Anon mode is currently enabled. Disable?", "cold feet", list("Disable Anon Names", "Keep it Enabled"))
		if(response != "Disable Anon Names")
			return
		QDEL_NULL(SSticker.anonymousnames)
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] has disabled anonymous names.</span>")
		if(SSticker.current_state < GAME_STATE_PREGAME)
			return
		priority_announce("Names and Identities have been restored.", "Identity Restoration", SSstation.announcer.get_rand_alert_sound())
		for(var/mob/living/player in GLOB.player_list)
			if(!player.mind || (!ishuman(player) && !issilicon(player)) || !SSjob.GetJob(player.mind.assigned_role))
				continue
			var/old_name = player.real_name //before restoration
			if(issilicon(player))
				var/is_AI = isAI(player)
				player.apply_pref_name("[is_AI ? "ai" : "cyborg"]", player.client)
			else
				player.client.prefs.copy_to(player, antagonist = (LAZYLEN(player.mind.antag_datums) > 0), is_latejoiner = FALSE)
				player.fully_replace_character_name(old_name, player.real_name) //this changes IDs and PDAs and whatnot
		return
	var/list/input_list = list("Cancel")
	for(var/_theme in typesof(/datum/anonymous_theme))
		var/datum/anonymous_theme/theme = _theme
		input_list[initial(theme.name)] = theme
	var/result = input(usr, "Choose an anonymous theme","going dark") as null|anything in input_list
	if(!usr || !result || result == "Cancel")
		return
	result = input_list[result]
	var/alert_players = "No"
	if(SSticker.current_state > GAME_STATE_PREGAME) //before anonnames is done, for asking a sleep
		alert_players = tgui_alert(usr, "Alert crew? These are IC Themed FROM centcom.", "2016 admins didn't miss roundstart", list("Yes", "No"))
	SSticker.anonymousnames = new result()
	if(alert_players == "Yes")
		priority_announce(SSticker.anonymousnames.announcement_alert, "Identity Loss", SSstation.announcer.get_rand_alert_sound())
	anonymous_all_players()

	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has enabled anonymous names. THEME: [SSticker.anonymousnames].</span>")

GLOBAL_DATUM(current_anonymous_theme, /datum/anonymous_theme)

/* Datum singleton initialized by the client proc to hold the naming generation */
/datum/anonymous_theme
	///name of the anonymous theme, seen by admins pressing buttons to enable this
	var/name = "Randomized Names"
	///announcement text that triggers when you turn on anonymous themes midround.
	var/announcement_alert = "A recent bureaucratic error in the Organic Resources Department has resulted in a necessary full recall of all identities and names until further notice."
	///extra non-name related fluff that is optional for admins to enable. One example is the wizard theme giving everyone random robes.
	var/extra_theming

/datum/anonymous_theme/New(extra_theming = FALSE)
	. = ..()
	src.extra_theming = extra_theming
	if(extra_theming)
		add_extra_theming()
	anonymous_all_players()

/datum/anonymous_theme/Destroy(force, ...)
	. = ..()
	if(extra_theming)
		remove_extra_theming()
	restore_all_players()

/**
 * anonymous_all_players: sets all crewmembers on station anonymous.
 *
 * called when the anonymous theme is created regardless of extra theming
 */
/datum/anonymous_theme/proc/anonymous_all_players()
	var/datum/anonymous_theme/theme = SSticker.anonymousnames
	for(var/mob/living/player in GLOB.player_list)
		if(!player.mind || (!ishuman(player) && !issilicon(player)) || !SSjob.GetJob(player.mind.assigned_role))
			continue
		if(issilicon(player))
			player.fully_replace_character_name(player.real_name, theme.anonymous_ai_name(isAI(player)))
		else
			var/original_name = player.real_name //id will not be changed if you do not do this
			randomize_human(player) //do this first so the special name can be given
			player.fully_replace_character_name(original_name, theme.anonymous_name(player))

/**
 * anonymous_all_players: sets all crewmembers on station anonymous.
 *
 * called when the anonymous theme is removed regardless of extra theming
 */
/datum/anonymous_theme/proc/restore_all_players()
	var/datum/anonymous_theme/theme = SSticker.anonymousnames
	for(var/mob/living/player in GLOB.player_list)
		if(!player.mind || (!ishuman(player) && !issilicon(player)) || !SSjob.GetJob(player.mind.assigned_role))
			continue
		if(issilicon(player))
			player.fully_replace_character_name(player.real_name, theme.anonymous_ai_name(isAI(player)))
		else
			var/original_name = player.real_name //id will not be changed if you do not do this
			randomize_human(player) //do this first so the special name can be given
			player.fully_replace_character_name(original_name, theme.anonymous_name(player))

/**
 * anonymous_name: generates a random name, based off of whatever the round's anonymousnames is set to.
 *
 * examples:
 * Employee = "Employee Q5460Z"
 * Wizards = "Gulstaff of Void"
 * Spider Clan = "Initiate Hazuki"
 * Arguments:
 * * target - mob for preferences and gender
 */
/datum/anonymous_theme/proc/anonymous_name(mob/target)
	return target.client.prefs.pref_species.random_name(target.gender,1)

/**
 * anonymous_ai_name: generates a random name, based off of whatever the round's anonymousnames is set to (but for sillycones).
 *
 * examples:
 * Employee = "Employee Assistant Assuming Delta"
 * Wizards = "Crystallized Knowledge Nexus +23"
 * Arguments:
 * * is_ai - boolean to decide whether the name has "Core" (AI) or "Assistant" (Cyborg)
 */
/datum/anonymous_theme/proc/anonymous_ai_name(is_ai = FALSE)
	return pick(GLOB.ai_names)

/datum/anonymous_theme/employees
	name = "Employees"
	announcement_alert = "As punishment for this station's poor productivity when compared to neighbor stations, names and identities will be restricted until further notice."

/datum/anonymous_theme/employees/anonymous_name(mob/target)
	var/is_head_of_staff = (target.mind.assigned_role in GLOB.command_positions)
	var/name = "[is_head_of_staff ? "Manager" : "Employee"] "
	for(var/i in 1 to 6)
		if(prob(30) || i == 1)
			name += ascii2text(rand(65, 90)) //A - Z
		else
			name += ascii2text(rand(48, 57)) //0 - 9
	return name

/datum/anonymous_theme/employees/anonymous_ai_name(is_ai = FALSE)
	var/verbs = capitalize(pick(GLOB.ing_verbs))
	var/phonetic = pick(GLOB.phonetic_alphabet)
	return "Employee [is_ai ? "Core" : "Assistant"] [verbs] [phonetic]"

/datum/anonymous_theme/wizards
	name = "Wizard Academy"
	announcement_alert = "Your station has been caught by a Wizard Federation Memetic Hazard. You are not y0urself, and yo% a2E 34!NOT4--- Welcome to the Academy, apprentices!"

/datum/anonymous_theme/wizards/anonymous_name(mob/target)
	var/wizard_name_first = pick(GLOB.wizard_first)
	var/wizard_name_second = pick(GLOB.wizard_second)
	return "[wizard_name_first] [wizard_name_second]"

/datum/anonymous_theme/wizards/anonymous_ai_name(is_ai = FALSE)
	return "Crystallized Knowledge [is_ai ? "Nexus" : "Sliver"] +[rand(1,99)]" //Could two people roll the same number? Yeah, probably. Do I CARE? Nawww

/datum/anonymous_theme/station
	name = "Stations?"
	announcement_alert = "Confirmed level 9 reality error event near [station_name()]. All personnel must try their best to carry on, as to not trigger more reality events by accident."

/datum/anonymous_theme/station/anonymous_name(mob/target)
	return "[pick(GLOB.ninja_titles)] [pick(GLOB.ninja_names)]"

/datum/anonymous_theme/station/anonymous_ai_name(is_ai = FALSE)
	var/posibrain_name = pick(GLOB.posibrain_names)
	if(is_ai)
		return "Shaolin Templemaster [posibrain_name]"
	else
		var/martial_prefix = capitalize(pick(GLOB.martial_prefix))
		var/martial_style = pick("Monkey", "Tiger", "Viper", "Mantis", "Crane", "Panda", "Bat", "Bear", "Centipede", "Frog")
		return "\"[martial_prefix] [martial_style]\" [posibrain_name]"
