/datum/preference/choiced/uplink_location
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "uplink_loc"

/datum/preference/choiced/uplink_location/init_possible_values()
	return list(UPLINK_PDA, UPLINK_RADIO, UPLINK_PEN, UPLINK_IMPLANT)

/datum/preference/choiced/uplink_location/apply(mob/living/carbon/human/target, value)
	// It's handled in /datum/mind/proc/equip_traitor
	return
