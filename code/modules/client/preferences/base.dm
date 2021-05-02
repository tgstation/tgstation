/// An assoc list list of types to instantiated `/datum/preference` instances
GLOBAL_LIST_INIT(preference_entries, init_preference_entries())

/proc/init_preference_entries()
	var/list/output = list()
	for (var/preference_type in subtypesof(/datum/preference))
		output[preference_type] = new preference_type
	return output

/// Represents an individual preference.
/datum/preference
	/// The key inside the savefile to use.
	/// This is also sent to the UI.
	/// Once you pick this, don't change it.
	var/savefile_key

	/// The category of preference, for use by the PreferencesMenu.
	/// This isn't used for anything other than as a key for UI data.
	/// It is up to the PreferencesMenu UI itself to interpret it.
	var/category = "misc"

	/// If this is TRUE, icons will be generated.
	/// This is necessary for if your `init_possible_values()` override
	/// returns an assoc list of names to atoms/icons.
	var/should_generate_icons = FALSE

	var/list/cached_values
	var/list/sent_icons

/// Called on the saved input when retrieving.
/// Input is the value inside the savefile, output is to tell other code
/// what the value is.
/// This is useful either for more optimal data saving or for migrating
/// older data.
/datum/preference/proc/deserialize(input)
	SHOULD_NOT_SLEEP(TRUE)
	return sanitize_inlist(input, get_choices())

/// Called on the input while saving.
/// Input is the current value, output is what to save in the savefile.
/datum/preference/proc/serialize(input)
	SHOULD_NOT_SLEEP(TRUE)
	return input

/// Produce a potentially random value for when no value for this preference is
/// found in the savefile.
/// If not overridden, will choose a random filtered value.
/datum/preference/proc/create_default_value()
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	return pick(get_choices())

/// Returns a list of every possible value.
/// The first time this is called, will run `init_values()`.
/// `user` is passed so that icons can be delivered.
/// Return value can be in the form of:
/// - A flat list of raw values, such as list(MALE, FEMALE, PLURAL).
/// - An assoc list of raw values to generated icon URLs.
/// If the mob has no client, and icons are expected to be generated, then
/// empty strings will be given.
/// Due to the need to send icons, this proc is NOT pure.
/// Its calling should be deferred when possible.
// MOTHBLOCKS TODO: Let preferences be text-only.
/datum/preference/proc/generate_possible_values(mob/user)
	// Override `init_values()` instead.
	SHOULD_NOT_OVERRIDE(TRUE)

	var/list/values = cache_possible_values()

	if (should_generate_icons)
		if (user.client)
			var/sent_to_client = LAZYACCESS(sent_icons, user.client)
			if (sent_to_client)
				return sent_to_client

			var/list/generated_values = list()

			for (var/key in values)
				generated_values[key] = icon2html(values[key], user, sourceonly = TRUE)

			LAZYSET(sent_icons, user.client, generated_values)
			return generated_values
		else
			// There's no client to deliver to, so we can't run icon2html
			var/list/empty_values = list()
			for (var/key in empty_values)
				empty_values[key] = ""
			return empty_values

	return values

/// Returns the icon for a given key.
/// `generate_possible_values` is preferred if you know you want EVERY value.
/// This is used to only send the icon for your currently worn item.
/datum/preference/proc/get_icon_for(mob/user, key)
	SHOULD_NOT_SLEEP(TRUE)

	var/sent_to_client = LAZYACCESS(sent_icons, user.client)
	if (sent_to_client)
		return sent_to_client[key]
	else if (!user.client)
		// No client, so we can't perform icon2html
		return ""
	else
		return icon2html(cache_possible_values()[key], user, sourceonly = TRUE)

/// Returns a flat list of all choices.
/// This should be preferred when icon generation isn't necessary.
/datum/preference/proc/get_choices()
	SHOULD_NOT_OVERRIDE(TRUE)

	if (isnull(cached_values))
		cached_values = init_possible_values()
		ASSERT(cached_values.len)

	return cached_values

/// Returns a list of every possible value.
/// This must be overriden by `/datum/preference` subtypes.
/// Return value can be in the form of:
/// - A flat list of raw values, such as list(MALE, FEMALE, PLURAL).
/// - An assoc list of raw values to atoms/icons, in which case
/// icons will be generated.
// MOTHBLOCKS TODO: Unit test this
/datum/preference/proc/init_possible_values()
	SHOULD_NOT_SLEEP(TRUE)
	CRASH("`init_possible_values()` was not implemented for [type]!")

/// Private.
/// Caches a list of every possible value.
/datum/preference/proc/cache_possible_values()
	SHOULD_NOT_OVERRIDE(TRUE)
	PRIVATE_PROC(TRUE)
	RETURN_TYPE(/list)

	if (isnull(cached_values))
		cached_values = init_possible_values()
		ASSERT(cached_values.len)

	return cached_values

/// Given a savefile, return either the saved data or an acceptable default.
/datum/preference/proc/read(savefile/savefile)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/value
	READ_FILE(savefile[savefile_key], value)

	if (isnull(value))
		return create_default_value()
	else
		return deserialize(value)

/// Apply this preference onto the given human.
/// Must be overriden by subtypes.
// MOTHBLOCKS TODO: Unit test this
/datum/preference/proc/apply(mob/living/carbon/human/target, value)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("`apply()` was not implemented for [type]!")

/// Read a /datum/preference type and return its value
/datum/preferences/proc/read_preference(preference_type)
	var/datum/preference/preference_entry = GLOB.preference_entries[preference_type]
	if (isnull(preference_entry))
		CRASH("Preference type `[preference_type]` is invalid!")

	var/savefile/savefile = new /savefile(path)
	savefile.cd = "/character[default_slot]"
	return preference_entry.read(savefile)
