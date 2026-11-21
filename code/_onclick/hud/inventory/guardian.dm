/datum/inventory_slot/guardian_storage
	name = "internal storage"
	icon_state = "suit_storage"
	slot_id = ITEM_SLOT_SUITSTORE
	screen_loc = ui_back

/datum/inventory_slot/guardian_storage/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	return TRUE
