/// Middleware to handle quirks
/datum/preference_middleware/quirks
	action_delegations = list(
		"give_quirk" = .proc/give_quirk,
		"remove_quirk" = .proc/remove_quirk,
	)

/datum/preference_middleware/quirks/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/spritesheet/quirks),
	)

/datum/preference_middleware/quirks/get_ui_static_data(mob/user)
	if (preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()

	var/list/data = list()

	var/list/selected_quirks = list()

	for (var/quirk in preferences.all_quirks)
		selected_quirks += sanitize_css_class_name(quirk)

	data["selected_quirks"] = selected_quirks

	return data

/datum/preference_middleware/quirks/get_constant_data()
	var/list/quirk_info = list()

	for (var/quirk_name in SSquirks.quirks)
		var/datum/quirk/quirk = SSquirks.quirks[quirk_name]
		quirk_info[sanitize_css_class_name(quirk_name)] = list(
			"description" = initial(quirk.desc),
			"name" = quirk_name,
			"value" = initial(quirk.value),
		)

	return list(
		"max_positive_quirks" = MAX_QUIRKS,
		"quirk_info" = quirk_info,
		"quirk_blacklist" = SSquirks.quirk_blacklist,
	)

/datum/preference_middleware/quirks/proc/give_quirk(list/params, mob/user)
	var/quirk_name = params["quirk"]

	var/list/new_quirks = preferences.all_quirks | quirk_name
	if (SSquirks.filter_invalid_quirks(new_quirks) != new_quirks)
		// If the client is sending an invalid give_quirk, that means that
		// something went wrong with the client prediction, so we should
		// catch it back up to speed.
		preferences.update_static_data(user)
		return TRUE

	preferences.all_quirks = new_quirks

	return TRUE

/datum/preference_middleware/quirks/proc/remove_quirk(list/params, mob/user)
	var/quirk_name = params["quirk"]

	var/list/new_quirks = preferences.all_quirks - quirk_name
	if ( \
		!(quirk_name in preferences.all_quirks) \
		|| SSquirks.filter_invalid_quirks(new_quirks) != new_quirks \
	)
		// If the client is sending an invalid remove_quirk, that means that
		// something went wrong with the client prediction, so we should
		// catch it back up to speed.
		preferences.update_static_data(user)
		return TRUE

	preferences.all_quirks = new_quirks

	return TRUE

/// Spritesheet generated for the quirks menu
/datum/asset/spritesheet/quirks
	name = "quirks"

/datum/asset/spritesheet/quirks/register()
	var/list/to_insert = list()

	for (var/quirk_name in SSquirks.quirks)
		var/quirk_type = SSquirks.quirks[quirk_name]
		var/datum/quirk/quirk = new quirk_type

		var/icon/quirk_icon = icon(quirk.icon)
		quirk_icon.Scale(64, 64)
		to_insert[sanitize_css_class_name(quirk_name)] = quirk_icon

		qdel(quirk)

	for (var/spritesheet_key in to_insert)
		Insert(spritesheet_key, to_insert[spritesheet_key])

	return ..()
