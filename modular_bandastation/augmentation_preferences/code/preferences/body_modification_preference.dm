/obj/item/bodypart/generate_icon_key()
	. = ..()

	if(!should_draw_greyscale && icon_static)
		. += "[icon_static]"

/datum/preference/body_modifications
	savefile_key = "body_modifications"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	priority = PREFERENCE_PRIORITY_LOADOUT
	can_randomize = FALSE
	should_update_preview = TRUE

/datum/preference/body_modifications/deserialize(input, datum/preferences/preferences)
	if(!islist(input))
		return list()

	var/list/result = list()
	for(var/key, value in input)
		var/datum/body_modification/modification = GLOB.body_modifications[key]
		if(!istype(modification))
			continue

		if(!modification.preference_value_valid(value))
			continue

		result[key] = value

	return result

/datum/preference/body_modifications/create_default_value()
	return list()

/datum/preference/body_modifications/apply_to_human(mob/living/carbon/human/target, value)
	if(!istype(target))
		return

	if(!islist(value) || !length(value))
		return

	apply_body_modifications(target, value)

/datum/preference/body_modifications/is_valid(value, datum/preferences/preferences)
	if(!islist(value))
		return FALSE

	for(var/key in value)
		var/datum/body_modification/modification = GLOB.body_modifications[key]
		if(!istype(modification))
			return FALSE

		if(!modification.preference_value_valid(value[key]))
			return FALSE

	return TRUE

/datum/preference/body_modifications/proc/apply_body_modifications(mob/living/carbon/human/target, list/body_modifications)
	if(!istype(target) || !length(body_modifications))
		return

	for(var/key in body_modifications)
		var/datum/body_modification/modification = GLOB.body_modifications[key]
		if(!istype(modification))
			continue

		modification.apply_to_human(target, body_modifications[key])
