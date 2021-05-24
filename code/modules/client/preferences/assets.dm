/// Assets generated from `/datum/preference` icons
/datum/asset/spritesheet/preferences
	name = "preferences"

/datum/asset/spritesheet/preferences/register()
	for (var/preference_key in GLOB.preference_entries_by_key)
		var/datum/preference/preference = GLOB.preference_entries_by_key[preference_key]
		if (!preference.should_generate_icons)
			continue

		var/list/choices = preference.get_choices()
		for (var/preference_value in choices)
			var/create_icon_of = choices[preference_value]
			var/icon/icon

			if (isatom(create_icon_of))
				var/atom/atom_icon_source = create_icon_of
				icon = icon(atom_icon_source.icon, atom_icon_source.icon_state)
			else if (isicon(create_icon_of))
				icon = create_icon_of
			else
				// MOTHBLOCKS TODO: Unit test this
				CRASH("[create_icon_of] is an invalid preference value.")

			Insert(preference.get_spritesheet_key(preference_value), icon)

	return ..()

/// Returns the key that will be used in the spritesheet for a given value.
/datum/preference/proc/get_spritesheet_key(value)
	return "[savefile_key]___[sanitize_css_class_name(value)]"
