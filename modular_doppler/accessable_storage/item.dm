/obj/item/mob_can_equip(mob/living/M, slot, disable_warning, bypass_equip_delay_self, ignore_equipped, indirect_action)
	. = ..()

	if (!.)
		return FALSE

	if (SEND_SIGNAL(src, COMSIG_ITEM_MOB_CAN_EQUIP, M, slot, disable_warning, bypass_equip_delay_self, ignore_equipped, indirect_action) & COMPONENT_ITEM_CANT_EQUIP)
		return FALSE

	return TRUE
