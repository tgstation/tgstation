/datum/quirk/item_quirk/breather
	abstract_parent_type = /datum/quirk/item_quirk/breather
	icon = FA_ICON_LUNGS_VIRUS
	var/breath_type = "oxygen"

/datum/quirk/item_quirk/breather/add_unique(client/client_source)
	var/obj/item/organ/lungs/target_lungs = quirk_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!target_lungs)
		to_chat(quirk_holder, span_warning("Your [name] quirk couldn't properly execute due to your species/body lacking a pair of lungs!"))
		return FALSE
	return TRUE
