/// Preferences that will be put into the 3rd list, and are not contextual.
#define PREFERENCE_CATEGORY_NON_CONTEXTUAL "non_contextual"

/// Will be put under the game preferences window.
#define PREFERENCE_CATEGORY_GAME_PREFERENCES "game_preferences"

/// An assoc list list of types to instantiated `/datum/preference` instances
GLOBAL_LIST_INIT(preference_entries, init_preference_entries())

/// An assoc list of preference entries by their `savefile_key`
GLOBAL_LIST_INIT(preference_entries_by_key, init_preference_entries_by_key())

/proc/init_preference_entries()
	var/list/output = list()
	for (var/datum/preference/preference_type as anything in subtypesof(/datum/preference))
		if (initial(preference_type.abstract_type) == preference_type)
			continue
		output[preference_type] = new preference_type
	return output

/proc/init_preference_entries_by_key()
	var/list/output = list()
	for (var/datum/preference/preference_type as anything in subtypesof(/datum/preference))
		if (initial(preference_type.abstract_type) == preference_type)
			continue
		output[initial(preference_type.savefile_key)] = GLOB.preference_entries[preference_type]
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

	/// Do not instantiate if type matches this.
	var/abstract_type = /datum/preference

	/// What savefile should this preference be read from?
	/// Valid values are PREFERENCE_CHARACTER and PREFERENCE_PLAYER.
	/// See the documentation in [code/__DEFINES/preferences.dm].
	// MOTHBLOCKS TODO: Verify all are set (and valid) in unit tests.
	var/savefile_identifier

/// Called on the saved input when retrieving.
/// Input is the value inside the savefile, output is to tell other code
/// what the value is.
/// This is useful either for more optimal data saving or for migrating
/// older data.
/// Must be overridden by subtypes.
/datum/preference/proc/deserialize(input)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("`deserialize()` was not implemented on [type]!")

/// Called on the input while saving.
/// Input is the current value, output is what to save in the savefile.
/datum/preference/proc/serialize(input)
	SHOULD_NOT_SLEEP(TRUE)
	return input

/// Produce a potentially random value for when no value for this preference is
/// found in the savefile.
/// Must be overriden by subtypes.
/datum/preference/proc/create_default_value()
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("`create_default_value()` was not implemented on [type]!")

/// Given a savefile, return either the saved data or an acceptable default.
/// This will write to the savefile if a value was not found with the new value.
/datum/preference/proc/read(savefile/savefile)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/value
	READ_FILE(savefile[savefile_key], value)

	if (isnull(value))
		var/new_value = create_default_value()
		write(savefile, new_value)
		return new_value
	else
		return deserialize(value)

/// Given a savefile, writes the inputted value.
/// Returns TRUE for a successful application.
/// Return FALSE if it is invalid.
/datum/preference/proc/write(savefile/savefile, value)
	SHOULD_NOT_OVERRIDE(TRUE)

	value = transform_value(value)

	if (!is_valid(value))
		return FALSE

	WRITE_FILE(savefile[savefile_key], value)
	return TRUE

/// Apply this preference onto the given client.
/// Must be overriden by subtypes.
// MOTHBLOCKS TODO: Unit test this
// MOTHBLOCKS TODO: Only those with PREFERENCE_PLAYER (and document)
/datum/preference/proc/apply_to_client(client/client, value)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("`apply_to_client()` was not implemented for [type]!")

/// Apply this preference onto the given human.
/// Must be overriden by subtypes.
// MOTHBLOCKS TODO: Unit test this
// MOTHBLOCKS TODO: Only those with PREFERENCE_CHARACTER (and document)
/datum/preference/proc/apply_to_human(mob/living/carbon/human/target, value)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("`apply_to_human()` was not implemented for [type]!")

/// Returns which savefile to use for a given savefile identifier
/datum/preferences/proc/get_savefile_for_savefile_identifier(savefile_identifier)
	RETURN_TYPE(/savefile)

	var/savefile/savefile = new /savefile(path)

	switch (savefile_identifier)
		if (PREFERENCE_CHARACTER)
			savefile.cd = "/character[default_slot]"
		if (PREFERENCE_PLAYER)
			savefile.cd = "/"
		else
			CRASH("Unknown savefile identifier [savefile_identifier]")

	return savefile

/// Read a /datum/preference type and return its value.
/// This will write to the savefile if a value was not found with the new value.
/datum/preferences/proc/read_preference(preference_type)
	var/datum/preference/preference_entry = GLOB.preference_entries[preference_type]
	if (isnull(preference_entry))
		CRASH("Preference type `[preference_type]` is invalid!")

	return preference_entry.read(get_savefile_for_savefile_identifier(preference_entry.savefile_identifier))

/// Set a /datum/preference type.
/// Returns TRUE for a successful preference application.
/// Returns FALSE if it is invalid.
/datum/preferences/proc/write_preference(datum/preference/preference, preference_value)
	return preference.write(get_savefile_for_savefile_identifier(preference.savefile_identifier), preference_value)

/// Checks that a given value is valid.
/// Must be overriden by subtypes.
/// Any type can be passed through.
/datum/preference/proc/is_valid(value)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)

	// MOTHBLOCKS TODO: Unit test this
	CRASH("`is_valid()` was not implemented for [type]!")

/// Transforms a value before writing it. Cannot assume the data is valid.
/// This is useful for things such as text -> number conversions.
/datum/preference/proc/transform_value(value)
	return value

/// Returns data to be sent to users in the menu
/datum/preference/proc/compile_ui_data(mob/user, value)
	SHOULD_NOT_SLEEP(TRUE)

	return serialize(value)

/// Returns data compiled into the preferences JSON asset
/datum/preference/proc/compile_constant_data()
	return null

/// A preference that is a choice of one option among a fixed set.
/// Used for preferences such as clothing.
/datum/preference/choiced
	/// If this is TRUE, icons will be generated.
	/// This is necessary for if your `init_possible_values()` override
	/// returns an assoc list of names to atoms/icons.
	var/should_generate_icons = FALSE

	var/list/cached_values

	abstract_type = /datum/preference/choiced

/// Returns a list of every possible value.
/// The first time this is called, will run `init_values()`.
/// Return value can be in the form of:
/// - A flat list of raw values, such as list(MALE, FEMALE, PLURAL).
/// - An assoc list of raw values to atoms/icons.
/datum/preference/choiced/proc/get_choices()
	// Override `init_values()` instead.
	SHOULD_NOT_OVERRIDE(TRUE)

	if (isnull(cached_values))
		cached_values = init_possible_values()
		ASSERT(cached_values.len)

	return cached_values

/// Returns a list of every possible value, serialized.
/// Return value can be in the form of:
/// - A flat list of serialized values, such as list(MALE, FEMALE, PLURAL).
/// - An assoc list of serialized values to atoms/icons.
/datum/preference/choiced/proc/get_choices_serialized()
	// Override `init_values()` instead.
	SHOULD_NOT_OVERRIDE(TRUE)

	var/list/serialized_choices = list()
	var/choices = get_choices()

	if (should_generate_icons)
		for (var/choice in choices)
			serialized_choices[serialize(choice)] = choices[choice]
	else
		for (var/choice in choices)
			serialized_choices += serialize(choice)

	return serialized_choices

/// Returns a list of every possible value.
/// This must be overriden by `/datum/preference/choiced` subtypes.
/// Return value can be in the form of:
/// - A flat list of raw values, such as list(MALE, FEMALE, PLURAL).
/// - An assoc list of raw values to atoms/icons, in which case
/// icons will be generated.
// MOTHBLOCKS TODO: Unit test this
/datum/preference/choiced/proc/init_possible_values()
	SHOULD_NOT_SLEEP(TRUE)
	CRASH("`init_possible_values()` was not implemented for [type]!")

/// Private.
/// Caches a list of every possible value.
/datum/preference/choiced/proc/cache_possible_values()
	SHOULD_NOT_OVERRIDE(TRUE)
	PRIVATE_PROC(TRUE)
	RETURN_TYPE(/list)

	if (isnull(cached_values))
		cached_values = init_possible_values()
		ASSERT(cached_values.len)

	return cached_values

/datum/preference/choiced/is_valid(value)
	return value in get_choices_serialized()

/datum/preference/choiced/deserialize(input)
	return sanitize_inlist(input, get_choices())

/datum/preference/choiced/create_default_value()
	return pick(get_choices())

/datum/preference/choiced/compile_ui_data(mob/user, value)
	if (should_generate_icons)
		return list(
			"icon" = get_spritesheet_key(value),
			"value" = serialize(value),
		)

	return ..()

/// A preference that represents an RGB color of something, crunched down to 3 hex numbers.
/// Was used heavily in the past, but doesn't provide as much range and only barely conserves space.
/datum/preference/color_legacy
	abstract_type = /datum/preference/color_legacy

/datum/preference/color_legacy/deserialize(input)
	return sanitize_hexcolor(input)

// MOTHBLOCKS TODO: Randomize, or make a var like numeric
/datum/preference/color_legacy/create_default_value()
	return "000"

/datum/preference/color_legacy/is_valid(value)
	return findtext(value, GLOB.is_color)

/datum/preference/color
	abstract_type = /datum/preference/color

/datum/preference/color/deserialize(input)
	return sanitize_ooccolor(input)

// MOTHBLOCKS TODO: Randomize, or make a var like numeric
/datum/preference/color/create_default_value()
	return COLOR_BLACK

/datum/preference/color/is_valid(value)
	return findtext(value, GLOB.is_color)

/// Takes an assoc list of names to /datum/sprite_accessory and returns a value
/// fit for `/datum/preference/init_possible_values()`
/proc/possible_values_for_sprite_accessory_list(list/datum/sprite_accessory/sprite_accessories)
	var/list/possible_values = list()
	for (var/name in sprite_accessories)
		var/datum/sprite_accessory/sprite_accessory = sprite_accessories[name]
		if (istype(sprite_accessory))
			possible_values[name] = icon(sprite_accessory.icon, sprite_accessory.icon_state)
		else
			// This means it didn't have an icon state
			possible_values[name] = icon('icons/mob/landmarks.dmi', "x")
	return possible_values

/// Takes an assoc list of names to /datum/sprite_accessory and returns a value
/// fit for `/datum/preference/init_possible_values()`
/// Different from `possible_values_for_sprite_accessory_list` in that it takes a list of layers
/// such as BEHIND, FRONT, and ADJ.
/// It also takes a "body part name", such as body_markings, moth_wings, etc
/// They are expected to be in order from lowest to top.
/proc/possible_values_for_sprite_accessory_list_for_body_part(
	list/datum/sprite_accessory/sprite_accessories,
	body_part,
	list/layers,
)
	var/list/possible_values = list()

	for (var/name in sprite_accessories)
		var/datum/sprite_accessory/sprite_accessory = sprite_accessories[name]

		var/icon/final_icon

		for (var/layer in layers)
			var/icon/icon = icon(sprite_accessory.icon, "m_[body_part]_[sprite_accessory.icon_state]_[layer]")

			if (isnull(final_icon))
				final_icon = icon
			else
				final_icon.Blend(icon, ICON_OVERLAY)

		possible_values[name] = final_icon

	return possible_values

/// A numeric preference with a minimum and maximum value
/datum/preference/numeric
	/// The minimum value
	var/minimum

	/// The maximum value
	var/maximum

	abstract_type = /datum/preference/numeric

/datum/preference/numeric/deserialize(input)
	return sanitize_integer(input, minimum, maximum, create_default_value())

/datum/preference/numeric/serialize(input)
	return sanitize_integer(input, minimum, maximum, create_default_value())

/datum/preference/numeric/create_default_value()
	return rand(minimum, maximum)

/datum/preference/numeric/transform_value(value)
	return text2num(value)

/datum/preference/numeric/is_valid(value)
	return !isnull(value) && value >= minimum && value <= maximum

/datum/preference/numeric/compile_constant_data()
	return list(
		"minimum" = minimum,
		"maximum" = maximum,
	)

/// A prefernece whose value is always TRUE or FALSE
/datum/preference/toggle
	abstract_type = /datum/preference/toggle

	/// The default value of the toggle, if create_default_value is not specified
	var/default_value = TRUE

/datum/preference/toggle/create_default_value()
	return default_value

/datum/preference/toggle/deserialize(input)
	return input

/datum/preference/toggle/transform_value(value)
	return value == TRUE

/datum/preference/toggle/is_valid(value)
	return value == TRUE || value == FALSE
