// Adds common to the list of choices for the bilingual quirk
/datum/preference/choiced/language/init_possible_values()
	. = ..()
	var/datum/language/common/common_language = /datum/language/common
	. += initial(common_language.name)
