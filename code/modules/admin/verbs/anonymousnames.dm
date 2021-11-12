
///global reference to the current theme, if there is one.
GLOBAL_DATUM(current_anonymous_theme, /datum/anonymous_theme)

/*Anon names! A system to make all players have random names/aliases instead of their static, for admin events/fuckery!
	contains both the anon names proc and the datums for each.

	this is the setup, it handles announcing crew and other settings for the mode and then creating the datum singleton
*/
/client/proc/anon_names()
	set category = "Admin.Events"
	set name = "Setup Anonymous Names"

	if(GLOB.current_anonymous_theme)
		var/response = tgui_alert(usr, "Anon mode is currently enabled. Disable?", "cold feet", list("Disable Anon Names", "Keep it Enabled"))
		if(response != "Disable Anon Names")
			return
		message_admins(span_adminnotice("[key_name_admin(usr)] has disabled anonymous names."))
		QDEL_NULL(GLOB.current_anonymous_theme)
		return
	var/list/input_list = list("Cancel")
	for(var/_theme in typesof(/datum/anonymous_theme))
		var/datum/anonymous_theme/theme = _theme
		input_list[initial(theme.name)] = theme
	var/result = input(usr, "Choose an anonymous theme","going dark") as null|anything in input_list
	if(!usr || !result || result == "Cancel")
		return
	var/datum/anonymous_theme/chosen_theme = input_list[result]
	var/extras_enabled = "No"
	var/alert_players = "No"
	if(SSticker.current_state > GAME_STATE_PREGAME) //before anonnames is done, for asking a sleep
		if(initial(chosen_theme.extras_enabled))
			extras_enabled = tgui_alert(usr, extras_enabled, "extras", list("Yes", "No"))
		alert_players = tgui_alert(usr, "Alert crew? These are IC Themed FROM centcom.", "announcement", list("Yes", "No"))
	//turns "Yes" and "No" into TRUE and FALSE
	extras_enabled = extras_enabled == "Yes"
	alert_players = alert_players == "Yes"
	GLOB.current_anonymous_theme = new chosen_theme(extras_enabled, alert_players)
	message_admins(span_adminnotice("[key_name_admin(usr)] has enabled anonymous names. THEME: [GLOB.current_anonymous_theme]."))

/* Datum singleton initialized by the client proc to hold the naming generation */
/datum/anonymous_theme
	///name of the anonymous theme, seen by admins pressing buttons to enable this
	var/name = "Randomized Names"
	///if admins get the option to enable extras, this is the prompt to enable it.
	var/extras_prompt
	///extra non-name related fluff that is optional for admins to enable. One example is the wizard theme giving everyone random robes.
	var/extras_enabled

/datum/anonymous_theme/New(extras_enabled = FALSE, alert_players = TRUE)
	. = ..()
	src.extras_enabled = extras_enabled
	if(extras_enabled)
		theme_extras()
	if(alert_players)
		announce_to_all_players()
	anonymous_all_players()

/datum/anonymous_theme/Destroy(force)
	restore_all_players()
	. = ..()

/**
 * theme_extras: optional effects enabled here from a proc that will trigger once on creation of anon mode.
 */
/datum/anonymous_theme/proc/theme_extras()
	return

/**
 * player_extras: optional effects enabled here from a proc that will trigger for every player renamed.
 */
/datum/anonymous_theme/proc/player_extras(mob/living/player)
	return

/**
 * announce_to_all_players: sends an annonuncement.
 *
 * it's in a proc so it can be a non-constant expression.
 */
/datum/anonymous_theme/proc/announce_to_all_players()
	priority_announce("A recent bureaucratic error in the Organic Resources Department has resulted in a necessary full recall of all identities and names until further notice.", "Identity Loss", SSstation.announcer.get_rand_alert_sound())

/**
 * anonymous_all_players: sets all crewmembers on station anonymous.
 *
 * called when the anonymous theme is created regardless of extra theming
 */
/datum/anonymous_theme/proc/anonymous_all_players()
	for(var/mob/living/player in GLOB.player_list)
		if(!player.mind || (!ishuman(player) && !issilicon(player)) || player.mind.assigned_role.faction != FACTION_STATION)
			continue
		if(issilicon(player))
			player.fully_replace_character_name(player.real_name, anonymous_ai_name(isAI(player)))
			return
		var/mob/living/carbon/human/human_mob = player
		var/original_name = player.real_name //id will not be changed if you do not do this
		randomize_human(player) //do this first so the special name can be given
		player.fully_replace_character_name(original_name, anonymous_name(player))
		if(extras_enabled)
			player_extras(player)
		human_mob.dna.update_dna_identity()

/**
 * restore_all_players: sets all crewmembers on station back to their preference name.
 *
 * called when the anonymous theme is removed regardless of extra theming
 */
/datum/anonymous_theme/proc/restore_all_players()
	priority_announce("Names and Identities have been restored.", "Identity Restoration", SSstation.announcer.get_rand_alert_sound())
	for(var/mob/living/player in GLOB.player_list)
		if(!player.mind || (!ishuman(player) && !issilicon(player)) || player.mind.assigned_role.faction != FACTION_STATION)
			continue
		var/old_name = player.real_name //before restoration
		if(issilicon(player))
			INVOKE_ASYNC(player, /mob/proc/apply_pref_name, "[isAI(player) ? /datum/preference/name/ai : /datum/preference/name/cyborg]", player.client)
		else
			player.client.prefs.apply_prefs_to(player) // This is not sound logic, as the prefs may have changed since then.
			player.fully_replace_character_name(old_name, player.real_name) //this changes IDs and PDAs and whatnot

/**
 * anonymous_name: generates a random name, based off of whatever the round's anonymousnames is set to.
 *
 * examples:
 * Employee = "Employee Q5460Z"
 * Wizards = "Gulstaff of Void"
 * Spider Clan = "Initiate Hazuki"
 * Stations? = "Refactor Port One"
 * Arguments:
 * * target - mob for preferences and gender
 */
/datum/anonymous_theme/proc/anonymous_name(mob/target)
	var/datum/client_interface/client = GET_CLIENT(target)
	var/species_type = client.prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type
	return species.random_name(target.gender,1)

/**
 * anonymous_ai_name: generates a random name, based off of whatever the round's anonymousnames is set to (but for sillycones).
 *
 * examples:
 * Employee = "Employee Assistant Assuming Delta"
 * Wizards = "Crystallized Knowledge Nexus +23"
 * Spider Clan = "'Leaping Viper' MSO"
 * Stations? = "System Port 10"
 * Arguments:
 * * is_ai - boolean to decide whether the name has "Core" (AI) or "Assistant" (Cyborg)
 */
/datum/anonymous_theme/proc/anonymous_ai_name(is_ai = FALSE)
	return pick(GLOB.ai_names)

/datum/anonymous_theme/employees
	name = "Employees"

/datum/anonymous_theme/employees/announce_to_all_players()
	priority_announce("As punishment for this station's poor productivity when compared to neighbor stations, names and identities will be restricted until further notice.", "Finance Report", SSstation.announcer.get_rand_alert_sound())

/datum/anonymous_theme/employees/anonymous_name(mob/target)
	var/is_head_of_staff = target.mind.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND
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
	extras_prompt = "Give everyone random robes too?"

/datum/anonymous_theme/wizards/player_extras(mob/living/player)
	var/random_path = pick(
		/obj/item/storage/box/wizard_kit,
		/obj/item/storage/box/wizard_kit/red,
		/obj/item/storage/box/wizard_kit/yellow,
		/obj/item/storage/box/wizard_kit/magusred,
		/obj/item/storage/box/wizard_kit/magusblue,
		/obj/item/storage/box/wizard_kit/black,
	)
	player.put_in_hands(new random_path())

/datum/anonymous_theme/wizards/announce_to_all_players()
	priority_announce("Your station has been caught by a Wizard Federation Memetic Hazard. You are not y0urself, and yo% a2E 34!NOT4--- Welcome to the Academy, apprentices!", "Memetic Hazard", SSstation.announcer.get_rand_alert_sound())

/datum/anonymous_theme/wizards/anonymous_name(mob/target)
	var/wizard_name_first = pick(GLOB.wizard_first)
	var/wizard_name_second = pick(GLOB.wizard_second)
	return "[wizard_name_first] [wizard_name_second]"

/datum/anonymous_theme/wizards/anonymous_ai_name(is_ai = FALSE)
	return "Crystallized Knowledge [is_ai ? "Nexus" : "Sliver"] +[rand(1,99)]" //Could two people roll the same number? Yeah, probably. Do I CARE? Nawww

/obj/item/storage/box/wizard_kit
	name = "Generic Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/PopulateContents()
	new /obj/item/clothing/head/wizard(src)
	new /obj/item/clothing/suit/wizrobe(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/wizard_kit/red
	name = "Evocation Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/red/PopulateContents()
	new /obj/item/clothing/head/wizard/red(src)
	new /obj/item/clothing/suit/wizrobe/red(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/wizard_kit/yellow
	name = "Translocation Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/yellow/PopulateContents()
	new /obj/item/clothing/head/wizard/yellow(src)
	new /obj/item/clothing/suit/wizrobe/yellow(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/wizard_kit/magusred
	name = "Conjuration Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/yellow/PopulateContents()
	new /obj/item/clothing/head/wizard/magus(src)
	new /obj/item/clothing/suit/wizrobe/magusred(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/wizard_kit/magusblue
	name = "Transmutation Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/yellow/PopulateContents()
	new /obj/item/clothing/head/wizard/magus(src)
	new /obj/item/clothing/suit/wizrobe/magusblue(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/wizard_kit/black
	name = "Necromancy Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/black/PopulateContents()
	new /obj/item/clothing/head/wizard/black(src)
	new /obj/item/clothing/suit/wizrobe/black(src)
	new /obj/item/clothing/shoes/sandal(src)

/datum/anonymous_theme/spider_clan
	name = "Spider Clan"

/datum/anonymous_theme/spider_clan/anonymous_name(mob/target)
	return "[pick(GLOB.ninja_titles)] [pick(GLOB.ninja_names)]"

/datum/anonymous_theme/spider_clan/announce_to_all_players()
	priority_announce("Your station has been sold out to the Spider Clan. Your new designations will be applied now.", "New Management", SSstation.announcer.get_rand_alert_sound())

/datum/anonymous_theme/spider_clan/anonymous_ai_name(is_ai = FALSE)
	var/posibrain_name = pick(GLOB.posibrain_names)
	if(is_ai)
		return "Shaolin Templemaster [posibrain_name]"
	else
		var/martial_prefix = capitalize(pick(GLOB.martial_prefix))
		var/martial_style = pick("Monkey", "Tiger", "Viper", "Mantis", "Crane", "Panda", "Bat", "Bear", "Centipede", "Frog")
		return "\"[martial_prefix] [martial_style]\" [posibrain_name]"

/datum/anonymous_theme/station
	name = "Stations?"
	extras_prompt = "Also set station name to be a random human name?"

/datum/anonymous_theme/station/theme_extras()
	set_station_name("[pick(GLOB.first_names)] [pick(GLOB.last_names)]")

/datum/anonymous_theme/station/announce_to_all_players()
	priority_announce("Confirmed level 9 reality error event near [station_name()]. All personnel must try their best to carry on, as to not trigger more reality events by accident.", "Central Command Higher Dimensional Affairs", 'sound/misc/notice1.ogg')

/datum/anonymous_theme/station/anonymous_name(mob/target)
	return new_station_name()

/datum/anonymous_theme/station/anonymous_ai_name(is_ai = FALSE)
	return new_station_name()
