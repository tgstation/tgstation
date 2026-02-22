/datum/quirk/prosopagnosia
	name = "Prosopagnosia"
	desc = "You have a mental disorder that prevents you from being able to recognize faces at all."
	icon = FA_ICON_USER_SECRET
	value = -4
	medical_record_text = "Patient suffers from prosopagnosia and cannot recognize faces."
	medical_symptom_text = "Unable to recognize familiar faces, often relying on alternative cues such as \
		voice, clothing, identification, or context to identify individuals."
	hardcore_value = 5
	mail_goodies = list(/obj/item/skillchip/appraiser) // bad at recognizing faces but good at recognizing IDs
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_TRAUMALIKE

/datum/quirk/prosopagnosia/add(client/client_source)
	. = ..()
	quirk_holder.apply_status_effect(/datum/status_effect/grouped/see_no_names/allow_ids, REF(src))

/datum/quirk/prosopagnosia/remove()
	. = ..()
	quirk_holder.remove_status_effect(/datum/status_effect/grouped/see_no_names/allow_ids, REF(src))

/// Conceals the names of other mobs
/datum/status_effect/grouped/see_no_names
	id = "see_no_names"
	alert_type = null
	/// If TRUE, the owner can still see ID names
	var/see_ids = FALSE

/datum/status_effect/grouped/see_no_names/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_REQUESTING_SCREENTIP_NAME_FROM_USER, PROC_REF(screentip_name_override))
	RegisterSignal(owner, COMSIG_LIVING_PERCEIVE_EXAMINE_NAME, PROC_REF(examine_name_override))
	owner.mob_flags |= MOB_HAS_SCREENTIPS_NAME_OVERRIDE

/datum/status_effect/grouped/see_no_names/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_MOB_REQUESTING_SCREENTIP_NAME_FROM_USER, COMSIG_LIVING_PERCEIVE_EXAMINE_NAME))

/datum/status_effect/grouped/see_no_names/proc/examine_name_override(datum/source, mob/living/carbon/human/examined, visible_name, list/name_override)
	SIGNAL_HANDLER

	if(!ishuman(examined) || source == examined)
		return NONE

	var/id_name =  see_ids && examined.get_id_name("", honorifics = TRUE)
	name_override[1] = id_name ? "[id_name]?" : "Unknown"
	return COMPONENT_EXAMINE_NAME_OVERRIDEN

/datum/status_effect/grouped/see_no_names/proc/screentip_name_override(datum/source, list/returned_name, obj/item/held_item, mob/living/carbon/human/hovered)
	SIGNAL_HANDLER

	if(!ishuman(hovered) || source == hovered)
		return NONE

	var/id_name = see_ids && hovered.get_id_name("", honorifics = TRUE)
	returned_name[1] = id_name ? "[id_name]?" : "Unknown"
	return SCREENTIP_NAME_SET

/// Conceals the names of other mobs, unless they are wearing an ID - then, that ID takes precedence
/datum/status_effect/grouped/see_no_names/allow_ids
	id = "see_no_names_allow_ids"
	see_ids = TRUE
