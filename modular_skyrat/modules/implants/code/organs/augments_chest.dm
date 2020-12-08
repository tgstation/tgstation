/obj/item/organ/cyberimp/chest/scanner
	name = "internal health analyzer"
	desc = "An advanced health analyzer implant, designed to directly interface with a host's body and relay scan information to the brain on command."
	slot = ORGAN_SLOT_SCANNER
	icon = 'modular_skyrat/modules/implants/icons/item/internal_HA.dmi'
	icon_state = "internal_HA"
	implant_overlay = null
	implant_color = null
	actions_types = list(/datum/action/item_action/organ_action/use)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/organ/cyberimp/chest/scanner/ui_action_click(owner, action)
	if(istype(action, /datum/action/item_action/organ_action/use))
		if(organ_flags & ORGAN_FAILING)
			to_chat(owner, "<span class='warning'>Your health analyzer relays an error! It can't interface with your body in its current condition!</span>")
			return
		else
			healthscan(owner, owner, 1, TRUE)
			chemscan(owner, owner)
