/datum/quirk/traumatized
	name = "Traumatized"
	desc = "A terrible trauma has been inflicted on you from your past or birth."
	value = 0
	medical_record_text = "Patient's brain waves show signs of permanent neurological trauma"
	icon = FA_ICON_DIZZY

/datum/quirk/traumatized/post_add()
	. = ..()
	var/trauma_name = quirk_holder.client?.prefs.read_preference(/datum/preference/choiced/trauma_chosen) || "Random"
	var/datum/brain_trauma/actual_trauma
	var/mob/living/carbon/human/victim = quirk_holder

	trauma_name = trauma_name == "Random" ? pick(GLOB.quirk_trauma_choice) : trauma_name //quirked up ternary statement
	actual_trauma = GLOB.quirk_trauma_choice[trauma_name]

	victim.gain_trauma(actual_trauma, TRAUMA_RESILIENCE_ABSOLUTE)

//Pref stuff
/datum/quirk_constant_data/traumatized
	associated_typepath = /datum/quirk/traumatized
	customization_options = list(/datum/preference/choiced/trauma_chosen)

/datum/preference/choiced/trauma_chosen
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "trauma"
	savefile_identifier = PREFERENCE_CHARACTER
	should_generate_icons = FALSE

/datum/preference/choiced/trauma_chosen/init_possible_values()
	return assoc_to_keys(GLOB.quirk_trauma_choice) + "Random"

/datum/preference/choiced/trauma_chosen/create_default_value()
	return "Random"

/datum/preference/choiced/trauma_chosen/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Traumatized" in preferences.all_quirks

/datum/preference/choiced/trauma_chosen/apply_to_human(mob/living/carbon/human/target, value)
	return
