/// Middleware to handle quirks
/datum/preference_middleware/quirks
	var/tainted = FALSE

	action_delegations = list(
		"give_quirk" = PROC_REF(give_quirk),
		"remove_quirk" = PROC_REF(remove_quirk),
	)

/datum/preference_middleware/quirks/get_ui_static_data(mob/user)
	if (preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()

	var/list/data = list()

	data["selected_quirks"] = get_selected_quirks()

	return data

/datum/preference_middleware/quirks/get_ui_data(mob/user)
	var/list/data = list()

	if (tainted)
		tainted = FALSE
		data["selected_quirks"] = get_selected_quirks()

	return data

/datum/preference_middleware/quirks/get_constant_data()
	var/list/quirk_info = list()

	var/list/quirks = SSquirks.get_quirks()

	for (var/quirk_name in quirks)
		var/datum/quirk/quirk = quirks[quirk_name]
		quirk_info[sanitize_css_class_name(quirk_name)] = list(
			"description" = initial(quirk.desc),
			"icon" = initial(quirk.icon),
			"name" = quirk_name,
			"value" = initial(quirk.value),
		)

	return list(
		"max_positive_quirks" = MAX_QUIRKS,
		"quirk_info" = quirk_info,
		"quirk_blacklist" = GLOB.quirk_string_blacklist,
	)

/datum/preference_middleware/quirks/on_new_character(mob/user)
	tainted = TRUE

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
	preferences.character_preview_view?.update_body()

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
	preferences.character_preview_view?.update_body()

	return TRUE

/datum/preference_middleware/quirks/proc/get_selected_quirks()
	var/list/selected_quirks = list()

	for (var/quirk in preferences.all_quirks)
		selected_quirks += sanitize_css_class_name(quirk)

	return selected_quirks
