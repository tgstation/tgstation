/datum/quirk/fragile
	name = "Fragility"
	desc = "You feel incredibly fragile. Burns and bruises hurt you more than the average person!"
	value = -6
	medical_record_text = "Patient's body has adapted to low gravity. Sadly low-gravity environments are not conducive to strong bone development."
	icon = FA_ICON_TIRED
	var/brute_mod
	var/burn_mod

/datum/quirk_constant_data/fragile
	associated_typepath = /datum/quirk/fragile
	customization_options = list(
		/datum/preference/numeric/fragile_customization/brute,
		/datum/preference/numeric/fragile_customization/burn,
	)

/datum/preference/numeric/fragile_customization
	abstract_type = /datum/preference/numeric/fragile_customization
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_identifier = PREFERENCE_CHARACTER

	minimum = 1.25
	maximum = 5 // 5x damage, arbitrary

	step = 0.01

/datum/preference/numeric/fragile_customization/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE

/datum/preference/numeric/fragile_customization/create_default_value()
	return 1.25

/datum/preference/numeric/fragile_customization/brute
	savefile_key = "fragile_brute"

/datum/preference/numeric/fragile_customization/burn
	savefile_key = "fragile_burn"

/datum/quirk/fragile/add_unique(client/client_source)
	var/mob/living/carbon/human/user = quirk_holder
	var/datum/preferences/prefs = client_source?.prefs
	brute_mod = prefs?.read_preference(/datum/preference/numeric/fragile_customization/brute) || 1.25
	burn_mod = prefs?.read_preference(/datum/preference/numeric/fragile_customization/burn) || 1.25

	user.physiology.brute_mod *= brute_mod
	user.physiology.burn_mod *= burn_mod

/datum/quirk/fragile/remove()
	. = ..()

	var/mob/living/carbon/human/user = quirk_holder
	user.physiology.brute_mod /= brute_mod
	user.physiology.burn_mod /= burn_mod
