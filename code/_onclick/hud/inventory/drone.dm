/datum/inventory_slot/drone
	abstract_type = /datum/inventory_slot/drone

/datum/inventory_slot/drone/storage
	name = "internal storage"
	icon_state = "suit_storage"
	slot_id = ITEM_SLOT_SUITSTORE
	screen_loc = ui_drone_storage

/datum/inventory_slot/drone/storage/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	return TRUE

/datum/inventory_slot/drone/head
	name = "head/mask"
	icon_state = "mask"
	slot_id = ITEM_SLOT_HEAD
	screen_loc = ui_drone_head

/datum/inventory_slot/drone/head/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	return !!(target.slot_flags & (ITEM_SLOT_HEAD|ITEM_SLOT_MASK))
