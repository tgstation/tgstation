/datum/preference/choiced/uplink_location
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "uplink_loc"
	can_randomize = FALSE

/datum/preference/choiced/uplink_location/init_possible_values()
	return list(UPLINK_PDA, UPLINK_RADIO, UPLINK_PEN, UPLINK_IMPLANT)

/datum/preference/choiced/uplink_location/compile_constant_data()
	var/list/data = ..()

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = list(
		UPLINK_PDA = "PDA",
		UPLINK_RADIO = "Radio",
		UPLINK_PEN = "Pen",
		UPLINK_IMPLANT = "Implant ([UPLINK_IMPLANT_TELECRYSTAL_COST]TC)",
	)

	return data

/datum/preference/choiced/uplink_location/create_default_value()
	return UPLINK_PDA

/datum/preference/choiced/uplink_location/apply_to_human(mob/living/carbon/human/target, value)
	return
