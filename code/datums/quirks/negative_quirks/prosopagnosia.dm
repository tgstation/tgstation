/datum/quirk/prosopagnosia
	name = "Prosopagnosia"
	desc = "You have a mental disorder that prevents you from being able to recognize faces at all."
	icon = FA_ICON_USER_SECRET
	value = -4
	mob_trait = TRAIT_PROSOPAGNOSIA
	medical_record_text = "Patient suffers from prosopagnosia and cannot recognize faces."
	hardcore_value = 5
	mail_goodies = list(/obj/item/skillchip/appraiser) // bad at recognizing faces but good at recognizing IDs

/datum/quirk/prosopagnosia/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_MOB_REQUESTING_SCREENTIP_NAME_FROM_USER, PROC_REF(screentip_name_override))
	quirk_holder.mob_flags |= MOB_HAS_SCREENTIPS_NAME_OVERRIDE

/datum/quirk/prosopagnosia/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_REQUESTING_SCREENTIP_NAME_FROM_USER)

/datum/quirk/prosopagnosia/proc/screentip_name_override(datum/source, list/returned_name, obj/item/held_item, atom/hovered)
	SIGNAL_HANDLER

	if(!ishuman(hovered))
		return NONE

	returned_name[1] = "Unknown"
	return SCREENTIP_NAME_SET
