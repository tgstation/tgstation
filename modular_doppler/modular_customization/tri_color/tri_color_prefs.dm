/// Tricolor prefs
/datum/preference/tri_color
	abstract_type = /datum/preference/tri_color

/datum/preference/tri_color/deserialize(input, datum/preferences/preferences)
	var/list/input_colors = input
	return list(sanitize_hexcolor(input_colors[1]), sanitize_hexcolor(input_colors[2]), sanitize_hexcolor(input_colors[3]))

/datum/preference/tri_color/create_default_value()
	return list("#[random_color()]", "#[random_color()]", "#[random_color()]")

/datum/preference/tri_color/is_valid(list/value)
	return islist(value) && value.len == 3 && (findtext(value[1], GLOB.is_color) && findtext(value[2], GLOB.is_color) && findtext(value[3], GLOB.is_color))

/datum/preference/tri_color/is_accessible(datum/preferences/preferences)
	return ..()

// Hey, you!
// Wondering how to get the colors from a tri-col pref?
// Look no further: list(sanitize_hexcolor(value[1]), sanitize_hexcolor(value[2]), sanitize_hexcolor(value[3]))
/datum/preference/tri_color/apply_to_human(mob/living/carbon/human/target, value)
	if (type == abstract_type)
		return ..()
