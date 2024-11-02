/datum/preference/limbs
	savefile_key = "limb_list"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/limbs/apply_to_human(mob/living/carbon/human/target, value)
	var/list/in_order_datums = list(
		// Apply bodyparts first, as organs / implants are housed in bodyparts - to prevent accidental overriding
		"Bodyparts" = list(),
		// Then apply organs into new bodyparts
		"Organs" = list(),
		// Then whatever is left
		"Other" = list(),
	)

	for(var/limb_zone in value)
		var/obj/item/limb_path = value[limb_zone]
		var/datum/limb_option_datum/equipping = GLOB.limb_loadout_options[limb_path]
		if(isnull(equipping))
			stack_trace("Invalid limb path in limb loadout preference: [limb_path]")
			continue

		if(ispath(limb_path, /obj/item/bodypart))
			in_order_datums["Bodyparts"] += equipping
		else if(ispath(limb_path, /obj/item/organ))
			in_order_datums["Organs"] += equipping
		else
			in_order_datums["Other"] += equipping

	for(var/to_apply_key in in_order_datums)
		for(var/datum/limb_option_datum/equipping_datum as anything in in_order_datums[to_apply_key])
			equipping_datum.apply_limb(target)

/datum/preference/limbs/deserialize(input, datum/preferences/preferences)
	var/list/corrected_list = list()
	for(var/limb_zone in input)
		var/obj/item/limb_path_as_text = input[limb_zone]
		if(istext(limb_path_as_text))
			// Loading from json loads as text rather than paths we love
			limb_path_as_text = text2path(limb_path_as_text)

		if(isnull(GLOB.limb_loadout_options[limb_path_as_text]))
			continue

		corrected_list[limb_zone] = limb_path_as_text

	return corrected_list

/datum/preference/limbs/create_default_value(datum/preferences/preferences)
	return null

/datum/preference/limbs/is_valid(value)
	return isnull(value) || islist(value)
