/// Middleware to handle quirks
/datum/preference_middleware/quirks
	action_delegations = list(
		"give_quirk" = .proc/give_quirk,
		"remove_quirk" = .proc/remove_quirk,
	)

/datum/preference_middleware/quirks/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/spritesheet/quirks),
		get_asset_datum(/datum/asset/json/quirk_info),
	)

// MOTHBLOCKS TODO: Only when requested
/datum/preference_middleware/quirks/get_ui_static_data(mob/user)
	var/list/data = list()

	data["selected_quirks"] = preferences.all_quirks

	return data

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
