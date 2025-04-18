/datum/quirk/heterochromatic
	name = "Heterochromatic"
	desc = "One of your eyes is a different color than the other!"
	icon = FA_ICON_EYE_LOW_VISION // Ignore the icon name, its actually a fairly good representation of different color eyes
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	medical_record_text = "Patient's irises are different colors."
	value = 0
	mail_goodies = list(/obj/item/clothing/glasses/eyepatch)

/datum/quirk/heterochromatic/add(client/client_source)
	var/color = client_source?.prefs.read_preference(/datum/preference/color/heterochromatic)
	if(!color)
		return

	apply_heterochromatic_eyes(color)

/// Applies the passed color to this mob's eyes
/datum/quirk/heterochromatic/proc/apply_heterochromatic_eyes(color)

	var/was_not_hetero = !quirk_holder.eye_color_heterochromatic
	quirk_holder.eye_color_heterochromatic = TRUE
	quirk_holder.eye_color_right = color
	quirk_holder.dna.update_ui_block(DNA_EYE_COLOR_RIGHT_BLOCK)

	var/obj/item/organ/eyes/eyes_of_the_holder = quirk_holder.get_organ_by_type(/obj/item/organ/eyes)
	if(!eyes_of_the_holder)
		return

	eyes_of_the_holder.eye_color_right = color
	eyes_of_the_holder.refresh()

	if(was_not_hetero)
		RegisterSignal(quirk_holder, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(check_eye_removal))

/datum/quirk/heterochromatic/remove()

	quirk_holder.eye_color_heterochromatic = FALSE
	quirk_holder.eye_color_right = quirk_holder.eye_color_left
	UnregisterSignal(quirk_holder, COMSIG_CARBON_LOSE_ORGAN)

/datum/quirk/heterochromatic/proc/check_eye_removal(datum/source, obj/item/organ/eyes/removed)
	SIGNAL_HANDLER

	if(!istype(removed))
		return

	// Eyes were removed, remove heterochromia from the human holder and bid them adieu

	quirk_holder.eye_color_heterochromatic = FALSE
	quirk_holder.eye_color_right = quirk_holder.eye_color_left
	UnregisterSignal(quirk_holder, COMSIG_CARBON_LOSE_ORGAN)
