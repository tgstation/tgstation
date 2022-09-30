/// Handle the migrations necessary from pre-tgui prefs to post-tgui prefs
/datum/preferences/proc/migrate_preferences_to_tgui_prefs_menu()
	migrate_antagonists()
	migrate_key_bindings()

/// Handle the migrations necessary from pre-tgui prefs to post-tgui prefs, for characters
/datum/preferences/proc/migrate_character_to_tgui_prefs_menu()
	migrate_randomization()

// Key bindings used to be "key" -> list("action"),
// such as "X" -> list("swap_hands").
// This made it impossible to determine any order, meaning placing a new
// hotkey would produce non-deterministic order.
// tgui prefs menu moves this over to "swap_hands" -> list("X").
/datum/preferences/proc/migrate_key_bindings()
	var/new_key_bindings = list()

	for (var/unbound_hotkey in key_bindings["Unbound"])
		new_key_bindings[unbound_hotkey] = list()

	for (var/hotkey in key_bindings)
		if (hotkey == "Unbound")
			continue

		for (var/keybind in key_bindings[hotkey])
			if (keybind in new_key_bindings)
				new_key_bindings[keybind] |= hotkey
			else
				new_key_bindings[keybind] = list(hotkey)

	key_bindings = new_key_bindings

// Before tgui preferences menu, "traitor" would handle both roundstart, midround, and latejoin.
// These were split apart.
/datum/preferences/proc/migrate_antagonists()
	migrate_antagonist(ROLE_HERETIC, list(ROLE_HERETIC_SMUGGLER))
	migrate_antagonist(ROLE_MALF, list(ROLE_MALF_MIDROUND))
	migrate_antagonist(ROLE_OPERATIVE, list(ROLE_OPERATIVE_MIDROUND, ROLE_LONE_OPERATIVE))
	migrate_antagonist(ROLE_REV_HEAD, list(ROLE_PROVOCATEUR))
	migrate_antagonist(ROLE_TRAITOR, list(ROLE_SYNDICATE_INFILTRATOR, ROLE_SLEEPER_AGENT))
	migrate_antagonist(ROLE_WIZARD, list(ROLE_WIZARD_MIDROUND))

	// "Familes [sic] Antagonists" was the old name of the catch-all.
	migrate_antagonist("Familes Antagonists", list(ROLE_FAMILIES, ROLE_FAMILY_HEAD_ASPIRANT))

/datum/preferences/proc/migrate_antagonist(will_exist, list/to_add)
	if (will_exist in be_special)
		for (var/add in to_add)
			be_special += add

// Randomization used to be an assoc list of fields to TRUE.
// Antagonist randomization was not even available to all options.
// tgui prefs menu changes from list("random_socks" = TRUE, "random_name_antag" = TRUE)
// to list("socks" = "enabled", "name" = "antag")
// as well as removing anything that was set to FALSE, as this can be extrapolated.
/datum/preferences/proc/migrate_randomization()
	var/static/list/random_settings = list(
		"random_age" = "age",
		"random_backpack" = "backpack",
		"random_eye_color" = "eye_color",
		"random_facial_hair_color" = "facial_hair_color",
		"random_facial_hairstyle" = "facial_hairstyle",
		"random_gender" = "gender",
		"random_hair_color" = "hair_color",
		"random_hairstyle" = "hairstyle",
		"random_jumpsuit_style" = "jumpsuit_style",
		"random_skin_tone" = "skin_tone",
		"random_socks" = "socks",
		"random_species" = "species",
		"random_undershirt" = "undershirt",
		"random_underwear" = "underwear",
		"random_underwear_color" = "underwear_color",
	)

	var/static/list/random_antag_settings = list(
		"random_age_antag" = "age",
		"random_gender_antag" = "gender",
		"random_name_antag" = "name",
	)

	var/list/new_randomise = list()

	for (var/old_setting in random_settings)
		if (randomise[old_setting])
			new_randomise[random_settings[old_setting]] = RANDOM_ENABLED

	for (var/old_antag_setting in random_antag_settings)
		if (randomise[old_antag_setting])
			new_randomise[random_settings[old_antag_setting]] = RANDOM_ANTAG_ONLY

	migrate_randomization_to_new_pref(
		/datum/preference/choiced/random_body,
		"random_body",
		"random_body_antag",
	)

	migrate_randomization_to_new_pref(
		/datum/preference/choiced/random_name,
		"random_name",
		"random_name_antag",
	)

	if (randomise["random_hardcore"])
		write_preference(GLOB.preference_entries[/datum/preference/toggle/random_hardcore], TRUE)

	randomise = new_randomise

/datum/preferences/proc/migrate_randomization_to_new_pref(
	preference_type,
	key,
	key_antag,
)
	if (randomise[key_antag])
		write_preference(GLOB.preference_entries[preference_type], RANDOM_ANTAG_ONLY)
	else if (randomise[key])
		write_preference(GLOB.preference_entries[preference_type], RANDOM_ENABLED)
