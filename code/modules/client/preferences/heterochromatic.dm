/datum/preference/color/heterochromatic
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "heterochromatic"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/color/heterochromatic/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return /datum/quirk/heterochromatic::name in preferences.all_quirks

/datum/preference/color/heterochromatic/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	if(!preferences || !(/datum/quirk/heterochromatic::name in preferences.all_quirks))
		return

	var/datum/quirk/heterochromatic/hetero_quirk = locate() in target.quirks
	if(!isnull(hetero_quirk))
		hetero_quirk.apply_heterochromatic_eyes(value)
		return

	target.eye_color_heterochromatic = TRUE
	target.eye_color_right = value
	if(target.dna)
		target.dna.update_ui_block(/datum/dna_block/identity/eye_colors)

	var/obj/item/organ/eyes/eyes_of_the_holder = target.get_organ_by_type(/obj/item/organ/eyes)
	if(!eyes_of_the_holder)
		return

	eyes_of_the_holder.eye_color_right = value
	eyes_of_the_holder.refresh()
