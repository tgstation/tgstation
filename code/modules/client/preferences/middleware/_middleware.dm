/// Prefrence middleware is code that helps to decentralize complicated preference features.
/datum/preference_middleware
	/// The preferences datum
	var/datum/preferences/preferences

	/// Map of ui_act actions -> proc paths to call.
	/// Signature is `(list/params, mob/user) -> TRUE/FALSE.
	/// Return output is the same as ui_act--TRUE if it should update, FALSE if it should not
	var/list/action_delegations = list()

/datum/preference_middleware/New(datum/preferences)
	src.preferences = preferences

/// Append all of these into ui_data
/datum/preference_middleware/proc/get_ui_data(mob/user)
	return list()

/// Append all of these into ui_static_data
/datum/preference_middleware/proc/get_ui_static_data(mob/user)
	return list()

/// Append all of these into ui_assets
/datum/preference_middleware/proc/get_ui_assets()
	return list()
