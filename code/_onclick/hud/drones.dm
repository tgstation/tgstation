/datum/hud/dextrous/drone
	inventory_slots = /datum/inventory_slot/drone

/datum/inventory_slot/drone
	abstract_type = /datum/inventory_slot/drone

/datum/inventory_slot/drone/storage
	name = "internal storage"
	icon_state = "suit_storage"
	slot_id = ITEM_SLOT_DEX_STORAGE
	screen_loc = ui_drone_storage

/datum/inventory_slot/drone/storage/get_slot_item(mob/owner)
	if (!isdrone(owner))
		return

	var/mob/living/basic/drone/drone = owner
	return drone.internal_storage

/datum/inventory_slot/drone/head
	name = "head/mask"
	icon_state = "mask"
	slot_id = ITEM_SLOT_HEAD
	screen_loc = ui_drone_head

/datum/inventory_slot/drone/head/get_slot_item(mob/owner)
	if (!isdrone(owner))
		return

	var/mob/living/basic/drone/drone = owner
	return drone.head
