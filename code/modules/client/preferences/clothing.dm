// Any preferences that will show to the sides of the character in the setup menu.
#define PREFERENCE_CATEGORY_CLOTHING "clothing"

/// Takes an assoc list of names to /datum/sprite_accessory and returns a value
/// fit for `/datum/preference/init_possible_values()`
/proc/possible_values_for_sprite_accessory_list(list/datum/sprite_accessory/sprite_accessories)
	var/list/possible_values = list()
	for (var/name in possible_values)
		var/datum/sprite_accessory/sprite_accessory = sprite_accessories
		possible_values[name] = icon(sprite_accessory.icon, sprite_accessory.icon_state)
	return possible_values

/// Used for subtypes to easily implement `/datum/preference/get_filtered_values()`.
/// Takes a gender and 3 assoc lists of name -> /datum/sprite_accessory.
/// The first one is a list of non-binary accessories (this should always be the total list).
/// The second one is a list of male-only accessories.
/// The third one is a list of female-only accessories.
/proc/filter_values_for_gendered_sprite_accessory_list(
	gender,
	non_binary_accessories,
	male_accessories,
	female_accessories,
)
	var/list_to_use

	switch (gender)
		if (MALE)
			list_to_use = male_accessories
		if (FEMALE)
			list_to_use = female_accessories
		else
			list_to_use = non_binary_accessories

	var/list/values = list()
	for (var/name in list_to_use)
		values += name

	return values

/// Underwear preference
/datum/preference/underwear
	savefile_key = "underwear"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE

/datum/preference/underwear/deserialize(value, datum/preferences/preferences)
	var/gender = preferences.read_preference(/datum/preference/gender)
	switch (gender)
		if (MALE)
			return sanitize_inlist(value, GLOB.underwear_m)
		if (FEMALE)
			return sanitize_inlist(value, GLOB.underwear_f)
		else
			return sanitize_inlist(value, GLOB.underwear_list)

/datum/preference/underwear/create_default_value(datum/preferences/preferences)
	var/gender = preferences.read_preference(/datum/preference/gender)
	return random_underwear(gender)

/datum/preference/underwear/get_filtered_values(datum/preferences/preferences)
	return filter_values_for_gendered_sprite_accessory_list(
		preferences.read_preference(/datum/preference/gender),
		GLOB.underwear_list,
		GLOB.underwear_m,
		GLOB.underwear_f,
	)

/datum/preference/underwear/init_possible_values()
	return possible_values_for_sprite_accessory_list(GLOB.underwear_list)

/datum/preference/underwear/apply(mob/living/carbon/human/target, value)
	target.underwear = value

#undef PREFERENCE_CATEGORY_CLOTHING
