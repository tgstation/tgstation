// Any preferences that will show to the sides of the character in the setup menu.
#define PREFERENCE_CATEGORY_CLOTHING "clothing"

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

/// Underwear preference
/datum/preference/underwear
	savefile_key = "underwear"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE

/datum/preference/underwear/init_possible_values()
	return possible_values_for_sprite_accessory_list(GLOB.underwear_list)

/datum/preference/underwear/apply(mob/living/carbon/human/target, value)
	target.underwear = value

#undef PREFERENCE_CATEGORY_CLOTHING
