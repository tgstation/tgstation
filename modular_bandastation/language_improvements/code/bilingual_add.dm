/datum/preference/choiced/language/init_possible_values()
	var/list/values = ..()
	// Adding a new language to the bilingual trait options if it's not primary language for the roundstart race.
	values |= /datum/language/spinwarder::name
	return values
