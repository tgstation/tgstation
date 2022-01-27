/// Preference middleware is code that helps to decentralize complicated preference features.
/datum/preference_middleware
	/// The preferences datum
	var/datum/preferences/preferences

	/// The key that will be used for get_constant_data().
	/// If null, will use the typepath minus /datum/preference_middleware.
	var/key = null

	/// Map of ui_act actions -> proc paths to call.
	/// Signature is `(list/params, mob/user) -> TRUE/FALSE.
	/// Return output is the same as ui_act--TRUE if it should update, FALSE if it should not
	var/list/action_delegations = list()

/datum/preference_middleware/New(datum/preferences)
	src.preferences = preferences

	if (isnull(key))
		// + 2 coming from the off-by-one of copytext, and then another from the slash
		key = copytext("[type]", length("[parent_type]") + 2)

/datum/preference_middleware/Destroy()
	preferences = null
	return ..()

/// Append all of these into ui_data
/datum/preference_middleware/proc/get_ui_data(mob/user)
	return list()

/// Append all of these into ui_static_data
/datum/preference_middleware/proc/get_ui_static_data(mob/user)
	return list()

/// Append all of these into ui_assets
/datum/preference_middleware/proc/get_ui_assets()
	return list()

/// Append all of these into /datum/asset/json/preferences.
/datum/preference_middleware/proc/get_constant_data()
	return null

/// Merge this into the result of compile_character_preferences.
/datum/preference_middleware/proc/get_character_preferences(mob/user)
	return null

/// Called every set_preference, returns TRUE if this handled it.
/datum/preference_middleware/proc/pre_set_preference(mob/user, preference, value)
	return FALSE

/// Called when a character is changed.
/datum/preference_middleware/proc/on_new_character(mob/user)
	return
