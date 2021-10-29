GLOBAL_LIST_INIT(bodyparts_to_convert, list("body_markings", \
"tail", \
"snout", \
"horns", \
"ears", \
"wings", \
"frills", \
"spines", \
"legs", \
"caps", \
"moth_antennae", \
"moth_markings", \
"fluff", \
"head_acc", \
"ipc_screen", \
"ipc_antenna", \
"ipc_chassis", \
"neck_acc", \
"skrell_hair", \
"taur", \
"xenodorsal", \
"xenohead", \
"penis", \
"testicles", \
"womb", \
"vagina", \
"breasts",))

/datum/preferences/proc/migrate_skyrat(savefile/S)
	if(features["flavor_text"])
		write_preference(GLOB.preference_entries[/datum/preference/text/flavor_text], features["flavor_text"])

	var/ooc_prefs
	READ_FILE(S["ooc_prefs"], ooc_prefs)
	if(ooc_prefs)
		write_preference(GLOB.preference_entries[/datum/preference/text/ooc_notes], ooc_prefs)

	var/list/mutant_colors = list()
	/// Intensive checking to ensure this process does not runtime. If it runtimes, goodbye savefiles.
	if(features["mcolor"])
		mutant_colors += sanitize_hexcolor(features["mcolor"])
	else
		mutant_colors += "#[random_color()]"

	if(features["mcolor2"])
		mutant_colors += sanitize_hexcolor(features["mcolor2"])
	else
		mutant_colors += "#[random_color()]"

	if(features["mcolor3"])
		mutant_colors += sanitize_hexcolor(features["mcolor2"])
	else
		mutant_colors += "#[random_color()]"

	write_preference(GLOB.preference_entries[/datum/preference/tri_color/mutant_colors], mutant_colors)

	for(var/body_part in GLOB.bodyparts_to_convert)
		if(mutant_bodyparts[body_part])
			var/type = mutant_bodyparts[body_part][MUTANT_INDEX_NAME]
			var/list/colors = mutant_bodyparts[body_part][MUTANT_INDEX_COLOR_LIST]
			if(type == "None")
				continue
			var/colors_length = colors.len
			/// Intensive checking to ensure this process does not runtime. If it runtimes, goodbye savefiles.
			switch(colors_length)
				if(0)
					colors += "#[random_color()]"
					colors += "#[random_color()]"
					colors += "#[random_color()]"
				if(1)
					colors[1] = sanitize_hexcolor(colors[1])
					colors += "#[random_color()]"
					colors += "#[random_color()]"
				if(2)
					colors[1] = sanitize_hexcolor(colors[1])
					colors[2] = sanitize_hexcolor(colors[2])
					colors += "#[random_color()]"
				else
					colors[1] = sanitize_hexcolor(colors[1])
					colors[2] = sanitize_hexcolor(colors[2])
					colors[3] = sanitize_hexcolor(colors[3])

			for(var/datum/preference/preference as anything in get_preferences_in_priority_order())
				if(!preference.relevant_mutant_bodypart || preference.relevant_mutant_bodypart != body_part)
					continue
				if(type)
					if(istype(preference, /datum/preference/toggle))
						write_preference(preference, TRUE)
						continue
					if(istype(preference, /datum/preference/choiced))
						write_preference(preference, type)
						continue
				if(colors)
					if(istype(preference, /datum/preference/tri_color))
						write_preference(preference, colors)
						continue

	to_chat(parent, examine_block(span_greentext("Preference migration successful! You may safely interact with the preferences menu.")))
	tgui_prefs_migration = TRUE
	WRITE_FILE(S["tgui_prefs_migration"], tgui_prefs_migration)
