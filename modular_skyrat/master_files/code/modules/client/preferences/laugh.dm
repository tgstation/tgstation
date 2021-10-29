/datum/preference/choiced/laugh
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "character_laugh"

/datum/preference/choiced/laugh/init_possible_values()
	return assoc_to_keys(GLOB.laugh_types)

/datum/preference/choiced/laugh/apply_to_human(mob/living/carbon/human/target, value)
	var/laugh_id = GLOB.laugh_types[value]
	if(laugh_id)
		var/datum/laugh_type/laugh_type = new laugh_id
		target.selected_laugh = laugh_type
